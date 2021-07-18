/* See LICENSE file for copyright and license details.
 *
 * dynamic window manager is designed like any other X client as well. It is
 * driven through handling X events. In contrast to other X clients, a window
 * manager selects for SubstructureRedirectMask on the root window, to receive
 * events about window (dis-)appearance. Only one X connection at a time is
 * allowed to select for this event mask.
 *
 * The event handlers of dwm are organized in an array which is accessed
 * whenever a new event has been fetched. This allows event dispatching
 * in O(1) time.
 *
 * Each child of the root window is called a client, except windows which have
 * set the override_redirect flag. Clients are organized in a linked client
 * list on each monitor, the focus history is remembered through a stack list
 * on each monitor. Each client contains a bit array to indicate the tags of a
 * client.
 *
 * Keys and tagging rules are organized as arrays and defined in config.h.
 *
 * To understand everything else, start reading main().
 */
#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/Xproto.h>
#include <X11/Xresource.h>
#include <X11/Xutil.h>
#include <X11/cursorfont.h>
#include <X11/keysym.h>
#include <errno.h>
#include <locale.h>
#include <regex.h>
#include <signal.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/epoll.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#ifdef XINERAMA
#include <X11/extensions/Xinerama.h>
#endif /* XINERAMA */
#include <X11/Xft/Xft.h>

#include "drw.h"
#include "util.h"

/* macros */
#define BUTTONMASK (ButtonPressMask | ButtonReleaseMask)
#define CLEANMASK(mask)                                                        \
  (mask & ~(numlockmask | LockMask) &                                          \
   (ShiftMask | ControlMask | Mod1Mask | Mod2Mask | Mod3Mask | Mod4Mask |      \
    Mod5Mask))
#define INTERSECT(x, y, w, h, m)                                               \
  (MAX(0, MIN((x) + (w), (m)->mx + (m)->mw) - MAX((x), (m)->mx)) *             \
   MAX(0, MIN((y) + (h), (m)->my + (m)->mh) - MAX((y), (m)->my)))
#define ISVISIBLEONTAG(C, T) ((C->tags & T))
#define ISVISIBLE(C) ISVISIBLEONTAG(C, C->mon->tagset[C->mon->seltags])
#define LENGTH(X) (sizeof X / sizeof X[0])
#define MOUSEMASK (BUTTONMASK | PointerMotionMask)
#define WIDTH(X) ((X)->w + 2 * (X)->bw + gappx)
#define HEIGHT(X) ((X)->h + 2 * (X)->bw + gappx)
#define TAGMASK ((1 << LENGTH(tags)) - 1)
#define TEXTW(X) (drw_fontset_getwidth(drw, (X)) + lrpad)
#define XRDB_LOAD_COLOR(R, V)                                                  \
  if (XrmGetResource(xrdb, R, NULL, &type, &value) == True) {                  \
    if (value.addr != NULL && strnlen(value.addr, 8) == 7 &&                   \
        value.addr[0] == '#') {                                                \
      int i = 1;                                                               \
      for (; i <= 6; i++) {                                                    \
        if (value.addr[i] < 48)                                                \
          break;                                                               \
        if (value.addr[i] > 57 && value.addr[i] < 65)                          \
          break;                                                               \
        if (value.addr[i] > 70 && value.addr[i] < 97)                          \
          break;                                                               \
        if (value.addr[i] > 102)                                               \
          break;                                                               \
      }                                                                        \
      if (i == 7) {                                                            \
        strncpy(V, value.addr, 7);                                             \
        V[7] = '\0';                                                           \
      }                                                                        \
    }                                                                          \
  }

/* enums */
enum { CurNormal, CurResize, CurMove, CurLast }; /* cursor */
enum { SchemeNorm, SchemeSel };                  /* color schemes */
enum {
  NetSupported,
  NetWMName,
  NetWMState,
  NetWMCheck,
  NetWMFullscreen,
  NetActiveWindow,
  NetWMWindowType,
  NetWMWindowTypeDialog,
  NetClientList,
  NetLast
}; /* EWMH atoms */
enum {
  WMProtocols,
  WMDelete,
  WMState,
  WMTakeFocus,
  WMLast
}; /* default atoms */
enum {
  ClkTagBar,
  ClkTabBar,
  ClkLtSymbol,
  ClkStatusText,
  ClkWinTitle,
  ClkClientWin,
  ClkRootWin,
  ClkLast
}; /* clicks */

typedef struct TagState TagState;
struct TagState {
  int selected;
  int occupied;
  int urgent;
};

typedef struct ClientState ClientState;
struct ClientState {
  int isfixed, isfloating, isurgent, neverfocus, oldstate, isfullscreen;
};

typedef union {
  long i;
  unsigned long ui;
  float f;
  const void *v;
} Arg;

typedef struct {
  unsigned int click;
  unsigned int mask;
  unsigned int button;
  void (*func)(const Arg *arg);
  const Arg arg;
} Button;

typedef struct Monitor Monitor;
typedef struct Client Client;
struct Client {
  char name[256];
  float mina, maxa;
  int x, y, w, h;
  int oldx, oldy, oldw, oldh;
  int basew, baseh, incw, inch, maxw, maxh, minw, minh;
  int bw, oldbw;
  unsigned int tags;
  int isfixed, isfloating, isurgent, neverfocus, oldstate, isfullscreen;
  int issteam;
  Client *next;
  Client *snext;
  Monitor *mon;
  Window win;
  ClientState prevstate;
};

typedef struct {
  unsigned int mod;
  KeySym keysym;
  void (*func)(const Arg *);
  const Arg arg;
} Key;

typedef struct {
  const char *symbol;
  void (*arrange)(Monitor *);
} Layout;

#define MAXTABS 50

typedef struct Pertag Pertag;
struct Monitor {
  char ltsymbol[16];
  char lastltsymbol[16];
  float mfact;
  int nmaster;
  int num;
  int by, bh;         /* bar geometry */
  int tx, tw;         /* bar tray geometry */
  int ty;             /* tab bar geometry */
  int mx, my, mw, mh; /* screen size */
  int wx, wy, ww, wh; /* window area  */
  unsigned int seltags;
  unsigned int sellt;
  unsigned int tagset[2];
  TagState tagstate;
  int showbar;
  int showtab;
  int topbar;
  int toptab;
  Client *clients;
  Client *sel;
  Client *lastsel;
  Client *stack;
  Monitor *next;
  Window barwin;
  Window tabwin;
  Window traywin;
  int ntabs;
  int tab_widths[MAXTABS];
  const Layout *lt[2];
  const Layout *lastlt;
  Pertag *pertag;
};

typedef struct {
  const char *class;
  const char *instance;
  const char *title;
  unsigned int tags;
  int isfloating;
  int monitor;
} Rule;

/* function declarations */
static void applyrules(Client *c);
static int applysizehints(Client *c, int *x, int *y, int *w, int *h,
                          int interact);
static void arrange(Monitor *m);
static void arrangemon(Monitor *m);
static void attach(Client *c);
static void attachBelow(Client *c);
static void attachstack(Client *c);
static void buttonpress(XEvent *e);
static void compileregexes(void);
static void checkotherwm(void);
static void cleanup(void);
static void cleanupmon(Monitor *mon);
static void clientmessage(XEvent *e);
static void configure(Client *c);
static void configurenotify(XEvent *e);
static void configurerequest(XEvent *e);
static Monitor *createmon(void);
static void destroynotify(XEvent *e);
static void detach(Client *c);
static void detachstack(Client *c);
static Monitor *dirtomon(int dir);
static void drawbar(Monitor *m);
static void drawbars(void);
static int drawstatusbar(Monitor *m, int bh, char *text);
static void drawtab(Monitor *m);
static void drawtabs(void);
static void enternotify(XEvent *e);
static void expose(XEvent *e);
static void focus(Client *c);
static void focusin(XEvent *e);
static void focusmon(const Arg *arg);
static void focusstack(const Arg *arg);
static void focuswin(const Arg *arg);
static int getrootptr(int *x, int *y);
static long getstate(Window w);
static int gettextprop(Window w, Atom atom, char *text, unsigned int size);
static void grabbuttons(Client *c, int focused);
static void grabkeys(void);
static int handlexevent(struct epoll_event *ev);
static void incnmaster(const Arg *arg);
static void keypress(XEvent *e);
static void killclient(const Arg *arg);
static void loadxrdb(void);
static void manage(Window w, XWindowAttributes *wa);
static void managealtbar(Window win, XWindowAttributes *wa);
static void managetray(Window win, XWindowAttributes *wa);
static void mappingnotify(XEvent *e);
static void maprequest(XEvent *e);
static void monocle(Monitor *m);
static void motionnotify(XEvent *e);
static void movemouse(const Arg *arg);
static Client *nexttagged(Client *c);
static Client *nexttiled(Client *c);
static void pop(Client *);
static void propertynotify(XEvent *e);
static void quit(const Arg *arg);
static Monitor *recttomon(int x, int y, int w, int h);
static void resize(Client *c, int x, int y, int w, int h, int interact);
static void resizeclient(Client *c, int x, int y, int w, int h);
static void resizemouse(const Arg *arg);
static void restack(Monitor *m);
static void run(void);
static void runautostart(void);
static void scan(void);
static void scantray(void);
static int sendevent(Client *c, Atom proto);
static void sendmon(Client *c, Monitor *m);
static void setclientstate(Client *c, long state);
static void setfocus(Client *c);
static void setfullscreen(Client *c, int fullscreen);
static void fullscreen(const Arg *arg);
static void setlayout(const Arg *arg);
static void setlayoutsafe(const Arg *arg);
static void setmfact(const Arg *arg);
static void setup(void);
static void setupepoll(void);
static void seturgent(Client *c, int urg);
static void showhide(Client *c);
static void sigchld(int unused);
static void sighup(int unused);
static void sigterm(int unused);
static void spawn(const Arg *arg);
static void spawnbar();
static void tabmode(const Arg *arg);
static void tag(const Arg *arg);
static void tagmon(const Arg *arg);
static void tile(Monitor *);
static void togglebar(const Arg *arg);
static void togglefloating(const Arg *arg);
static void toggletag(const Arg *arg);
static void toggleview(const Arg *arg);
static void unfocus(Client *c, int setfocus);
static void unmanage(Client *c, int destroyed);
static void unmanagealtbar(Window w);
static void unmanagetray(Window w);
static void unmapnotify(XEvent *e);
static void updatebarpos(Monitor *m);
static void updatebars(void);
static void updateclientlist(void);
static int updategeom(void);
static void updatenumlockmask(void);
static void updatesizehints(Client *c);
static void updatestatus(void);
static void updatetitle(Client *c);
static void updatewindowtype(Client *c);
static void updatewmhints(Client *c);
static void view(const Arg *arg);
static Client *wintoclient(Window w);
static Monitor *wintomon(Window w);
static int wmclasscontains(Window win, const char *class, const char *name);
static int xerror(Display *dpy, XErrorEvent *ee);
static int xerrordummy(Display *dpy, XErrorEvent *ee);
static int xerrorstart(Display *dpy, XErrorEvent *ee);
static void xrdb(const Arg *arg);
static void zoom(const Arg *arg);
static void bstack(Monitor *m);
static void bstackhoriz(Monitor *m);

static void focusmaster(const Arg *arg);

/* variables */
static const char autostartblocksh[] = "autostart_blocking.sh";
static const char autostartsh[] = "autostart.sh";
static const char broken[] = "broken";
static const char dwmdir[] = "dwm";
static const char localshare[] = ".local/share";
static char stext[1024];
static int screen;
static int sw, sh;      /* X display screen geometry width, height */
static int bh, blw = 0; /* bar geometry */
static int th = 0;      /* tab bar geometry */
static int lrpad;       /* sum of left and right padding for text */
static int (*xerrorxlib)(Display *, XErrorEvent *);
static unsigned int numlockmask = 0;
static void (*handler[LASTEvent])(XEvent *) = {
    [ButtonPress] = buttonpress,
    [ClientMessage] = clientmessage,
    [ConfigureRequest] = configurerequest,
    [ConfigureNotify] = configurenotify,
    [DestroyNotify] = destroynotify,
    [EnterNotify] = enternotify,
    [Expose] = expose,
    [FocusIn] = focusin,
    [KeyPress] = keypress,
    [MappingNotify] = mappingnotify,
    [MapRequest] = maprequest,
    [MotionNotify] = motionnotify,
    [PropertyNotify] = propertynotify,
    [UnmapNotify] = unmapnotify};
static Atom wmatom[WMLast], netatom[NetLast];
static int epoll_fd;
static int dpy_fd;
static int restart = 0;
static int running = 1;
static Cur *cursor[CurLast];
static Clr **scheme;
static Display *dpy;
static Drw *drw;
static Monitor *mons, *selmon, *lastselmon;
static Window root, wmcheckwin;

#include "ipc.h"

/* configuration, allows nested code to access above variables */
#include "config.h"

#ifdef VERSION
#include "IPCClient.c"
#include "ipc.c"
#include "yajl_dumps.c"
#endif

struct Pertag {
  unsigned int curtag, prevtag;          /* current and previous tag */
  int nmasters[LENGTH(tags) + 1];        /* number of windows in master area */
  float mfacts[LENGTH(tags) + 1];        /* mfacts per tag */
  unsigned int sellts[LENGTH(tags) + 1]; /* selected layouts */
  const Layout
      *ltidxs[LENGTH(tags) + 1][2]; /* matrix of tags and layouts indexes  */
  int showbars[LENGTH(tags) + 1];   /* display bar for the current tag */
};

/* compile-time check if all tags fit into an unsigned int bit array. */
struct NumTags {
  char limitexceeded[LENGTH(tags) > 31 ? -1 : 1];
};

static regex_t regexcache[LENGTH(rules)][3];

/* function implementations */
void applyrules(Client *c) {
  const char *class, *instance;
  unsigned int i;
  const Rule *r;
  Monitor *m;
  XClassHint ch = {NULL, NULL};

  /* rule matching */
  c->isfloating = 0;
  c->tags = 0;
  XGetClassHint(dpy, c->win, &ch);
  class = ch.res_class ? ch.res_class : broken;
  instance = ch.res_name ? ch.res_name : broken;

  if (strstr(class, "Steam") || strstr(class, "steam_app_"))
    c->issteam = 1;

  for (i = 0; i < LENGTH(rules); i++) {
    r = &rules[i];
    if ((!r->title || !regexec(&regexcache[i][2], c->name, 0, NULL, 0)) &&
        (!r->class || !regexec(&regexcache[i][0], class, 0, NULL, 0)) &&
        (!r->instance || !regexec(&regexcache[i][1], instance, 0, NULL, 0))) {

      c->isfloating = r->isfloating;
      c->tags |= r->tags;
      for (m = mons; m && m->num != r->monitor; m = m->next)
        ;
      if (m)
        c->mon = m;
    }
  }
  if (ch.res_class)
    XFree(ch.res_class);
  if (ch.res_name)
    XFree(ch.res_name);
  c->tags =
      c->tags & TAGMASK ? c->tags & TAGMASK : c->mon->tagset[c->mon->seltags];
}

int applysizehints(Client *c, int *x, int *y, int *w, int *h, int interact) {
  int baseismin;
  Monitor *m = c->mon;

  /* set minimum possible */
  *w = MAX(1, *w);
  *h = MAX(1, *h);
  if (interact) {
    if (*x > sw)
      *x = sw - WIDTH(c);
    if (*y > sh)
      *y = sh - HEIGHT(c);
    if (*x + *w + 2 * c->bw < 0)
      *x = 0;
    if (*y + *h + 2 * c->bw < 0)
      *y = 0;
  } else {
    if (*x >= m->wx + m->ww)
      *x = m->wx + m->ww - WIDTH(c);
    if (*y >= m->wy + m->wh)
      *y = m->wy + m->wh - HEIGHT(c);
    if (*x + *w + 2 * c->bw <= m->wx)
      *x = m->wx;
    if (*y + *h + 2 * c->bw <= m->wy)
      *y = m->wy;
  }
  if (*h < bh)
    *h = bh;
  if (*w < bh)
    *w = bh;
  if (resizehints || c->isfloating || !c->mon->lt[c->mon->sellt]->arrange) {
    /* see last two sentences in ICCCM 4.1.2.3 */
    baseismin = c->basew == c->minw && c->baseh == c->minh;
    if (!baseismin) { /* temporarily remove base dimensions */
      *w -= c->basew;
      *h -= c->baseh;
    }
    /* adjust for aspect limits */
    if (c->mina > 0 && c->maxa > 0) {
      if (c->maxa < (float)*w / *h)
        *w = *h * c->maxa + 0.5;
      else if (c->mina < (float)*h / *w)
        *h = *w * c->mina + 0.5;
    }
    if (baseismin) { /* increment calculation requires this */
      *w -= c->basew;
      *h -= c->baseh;
    }
    /* adjust for increment value */
    if (c->incw)
      *w -= *w % c->incw;
    if (c->inch)
      *h -= *h % c->inch;
    /* restore base dimensions */
    *w = MAX(*w + c->basew, c->minw);
    *h = MAX(*h + c->baseh, c->minh);
    if (c->maxw)
      *w = MIN(*w, c->maxw);
    if (c->maxh)
      *h = MIN(*h, c->maxh);
  }
  return *x != c->x || *y != c->y || *w != c->w || *h != c->h;
}

void arrange(Monitor *m) {
  if (m)
    showhide(m->stack);
  else
    for (m = mons; m; m = m->next)
      showhide(m->stack);
  if (m) {
    arrangemon(m);
    restack(m);
  } else
    for (m = mons; m; m = m->next)
      arrangemon(m);
}

void arrangemon(Monitor *m) {
  updatebarpos(m);
  XMoveResizeWindow(dpy, m->tabwin, m->wx, m->ty, m->ww, th);
  strncpy(m->ltsymbol, m->lt[m->sellt]->symbol, sizeof m->ltsymbol);
  if (m->lt[m->sellt]->arrange)
    m->lt[m->sellt]->arrange(m);
}

void attach(Client *c) {
  c->next = c->mon->clients;
  c->mon->clients = c;
}
void attachBelow(Client *c) {
  // If there is nothing on the monitor or the selected client is floating,
  // attach as normal
  if (c->mon->sel == NULL || c->mon->sel->isfloating) {
    Client *at = nexttagged(c);
    if (!at) {
      attach(c);
      return;
    }
    c->next = at->next;
    at->next = c;
    return;
  }

  // Set the new client's next property to the same as the currently selected
  // clients next
  c->next = c->mon->sel->next;
  // Set the currently selected clients next property to the new client
  c->mon->sel->next = c;
}

void attachstack(Client *c) {
  c->snext = c->mon->stack;
  c->mon->stack = c;
}

void buttonpress(XEvent *e) {
  unsigned int i, x, click;
  Arg arg = {0};
  Client *c;
  Monitor *m;
  XButtonPressedEvent *ev = &e->xbutton;

  click = ClkRootWin;
  /* focus monitor if necessary */
  if ((m = wintomon(ev->window)) && m != selmon) {
    unfocus(selmon->sel, 1);
    selmon = m;
    focus(NULL);
  }
  if (ev->window == selmon->barwin) {
    i = x = 0;
    do
      x += TEXTW(tags[i]);
    while (ev->x >= x && ++i < LENGTH(tags));
    if (i < LENGTH(tags)) {
      click = ClkTagBar;
      arg.ui = 1 << i;
    } else if (ev->x < x + blw)
      click = ClkLtSymbol;
    else if (ev->x > selmon->ww - TEXTW(stext))
      click = ClkStatusText;
    else
      click = ClkWinTitle;
  }
  if (ev->window == selmon->tabwin) {
    i = 0;
    x = 0;
    for (c = selmon->clients; c; c = c->next) {
      if (!ISVISIBLE(c))
        continue;
      x += selmon->tab_widths[i];
      if (ev->x > x)
        ++i;
      else
        break;
      if (i >= m->ntabs)
        break;
    }
    if (c) {
      click = ClkTabBar;
      arg.ui = i;
    }
  } else if ((c = wintoclient(ev->window))) {
    focus(c);
    restack(selmon);
    XAllowEvents(dpy, ReplayPointer, CurrentTime);
    click = ClkClientWin;
  }
  for (i = 0; i < LENGTH(buttons); i++)
    if (click == buttons[i].click && buttons[i].func &&
        buttons[i].button == ev->button &&
        CLEANMASK(buttons[i].mask) == CLEANMASK(ev->state)) {
      buttons[i].func(
          ((click == ClkTagBar || click == ClkTabBar) && buttons[i].arg.i == 0)
              ? &arg
              : &buttons[i].arg);
    }
}

void checkotherwm(void) {
  xerrorxlib = XSetErrorHandler(xerrorstart);
  /* this causes an error if some other window manager is running */
  XSelectInput(dpy, DefaultRootWindow(dpy), SubstructureRedirectMask);
  XSync(dpy, False);
  XSetErrorHandler(xerror);
  XSync(dpy, False);
}

void cleanup(void) {
  Arg a = {.ui = ~0};
  Layout foo = {"", NULL};
  Monitor *m;
  size_t i;

  view(&a);
  selmon->lt[selmon->sellt] = &foo;
  for (m = mons; m; m = m->next)
    while (m->stack)
      unmanage(m->stack, 0);
  XUngrabKey(dpy, AnyKey, AnyModifier, root);
  while (mons)
    cleanupmon(mons);
  for (i = 0; i < CurLast; i++)
    drw_cur_free(drw, cursor[i]);
  for (i = 0; i < LENGTH(colors) + 1; i++)
    free(scheme[i]);
  XDestroyWindow(dpy, wmcheckwin);
  drw_free(drw);
  XSync(dpy, False);
  XSetInputFocus(dpy, PointerRoot, RevertToPointerRoot, CurrentTime);
  XDeleteProperty(dpy, root, netatom[NetActiveWindow]);

  ipc_cleanup();

  if (close(epoll_fd) < 0) {
    fprintf(stderr, "Failed to close epoll file descriptor\n");
  }
}

void cleanupmon(Monitor *mon) {
  Monitor *m;

  if (mon == mons)
    mons = mons->next;
  else {
    for (m = mons; m && m->next != mon; m = m->next)
      ;
    m->next = mon->next;
  }
  if (!usealtbar) {
    XUnmapWindow(dpy, mon->barwin);
    XDestroyWindow(dpy, mon->barwin);
  }
  XUnmapWindow(dpy, mon->tabwin);
  XDestroyWindow(dpy, mon->tabwin);
  free(mon);
}

void clientmessage(XEvent *e) {
  XClientMessageEvent *cme = &e->xclient;
  Client *c = wintoclient(cme->window);
  unsigned int i;

  if (!c)
    return;
  if (cme->message_type == netatom[NetWMState]) {
    if (cme->data.l[1] == netatom[NetWMFullscreen] ||
        cme->data.l[2] == netatom[NetWMFullscreen])
      setfullscreen(c, (cme->data.l[0] == 1 /* _NET_WM_STATE_ADD    */
                        || (cme->data.l[0] == 2 /* _NET_WM_STATE_TOGGLE */ &&
                            !c->isfullscreen)));
  } else if (cme->message_type == netatom[NetActiveWindow]) {
    for (i = 0; i < LENGTH(tags) && !((1 << i) & c->tags); i++)
      ;
    if (i < LENGTH(tags)) {
      const Arg a = {.ui = 1 << i};
      selmon = c->mon;
      view(&a);
      focus(c);
      restack(selmon);
    }
  }
}

void compileregexes(void) {
  char regex_error_buffer[256];
  int i;
  int status;
  const Rule *r;
  for (i = 0; i < LENGTH(rules); i++) {
    r = &rules[i];
    if (r->class) {
      if ((status = regcomp(&regexcache[i][0], r->class,
                            REG_EXTENDED | REG_NOSUB))) {
        regerror(status, &regexcache[i][0], regex_error_buffer,
                 sizeof(regex_error_buffer));
        die("Error compiling /%s/: %s", r->class, regex_error_buffer);
      }
    }
    if (r->instance) {
      if ((status = regcomp(&regexcache[i][1], r->instance,
                            REG_EXTENDED | REG_NOSUB))) {
        regerror(status, &regexcache[i][1], regex_error_buffer,
                 sizeof(regex_error_buffer));
        die("Error compiling /%s/: %s", r->instance, regex_error_buffer);
      }
    }
    if (r->title) {
      if ((status = regcomp(&regexcache[i][2], r->title,
                            REG_EXTENDED | REG_NOSUB))) {
        regerror(status, &regexcache[i][2], regex_error_buffer,
                 sizeof(regex_error_buffer));
        die("Error compiling /%s/: %s", r->title, regex_error_buffer);
      }
    }
  }
}

void configure(Client *c) {
  XConfigureEvent ce;

  ce.type = ConfigureNotify;
  ce.display = dpy;
  ce.event = c->win;
  ce.window = c->win;
  ce.x = c->x;
  ce.y = c->y;
  ce.width = c->w;
  ce.height = c->h;
  ce.border_width = c->bw;
  ce.above = None;
  ce.override_redirect = False;
  XSendEvent(dpy, c->win, False, StructureNotifyMask, (XEvent *)&ce);
}

void configurenotify(XEvent *e) {
  Monitor *m;
  Client *c;
  XConfigureEvent *ev = &e->xconfigure;
  int dirty;

  /* TODO: updategeom handling sucks, needs to be simplified */
  if (ev->window == root) {
    dirty = (sw != ev->width || sh != ev->height);
    sw = ev->width;
    sh = ev->height;
    if (updategeom() || dirty) {
      drw_resize(drw, sw, bh);
      updatebars();
      for (m = mons; m; m = m->next) {
        for (c = m->clients; c; c = c->next)
          if (c->isfullscreen)
            resizeclient(c, m->mx, m->my, m->mw, m->mh);
        XMoveResizeWindow(dpy, m->barwin, m->wx, m->by, m->ww, m->bh);
      }
      focus(NULL);
      arrange(NULL);
    }
  }
}

void configurerequest(XEvent *e) {
  Client *c;
  Monitor *m;
  XConfigureRequestEvent *ev = &e->xconfigurerequest;
  XWindowChanges wc;

  if ((c = wintoclient(ev->window))) {
    if (ev->value_mask & CWBorderWidth)
      c->bw = ev->border_width;
    else if (c->isfloating || !selmon->lt[selmon->sellt]->arrange) {
      m = c->mon;
      if (!c->issteam) {
        if (ev->value_mask & CWX) {
          c->oldx = c->x;
          c->x = m->mx + ev->x;
        }
        if (ev->value_mask & CWY) {
          c->oldy = c->y;
          c->y = m->my + ev->y;
        }
      }
      if (ev->value_mask & CWWidth) {
        c->oldw = c->w;
        c->w = ev->width;
      }
      if (ev->value_mask & CWHeight) {
        c->oldh = c->h;
        c->h = ev->height;
      }
      if ((c->x + c->w) > m->mx + m->mw && c->isfloating)
        c->x = m->mx + (m->mw / 2 - WIDTH(c) / 2); /* center in x direction */
      if ((c->y + c->h) > m->my + m->mh && c->isfloating)
        c->y = m->my + (m->mh / 2 - HEIGHT(c) / 2); /* center in y direction */
      if ((ev->value_mask & (CWX | CWY)) &&
          !(ev->value_mask & (CWWidth | CWHeight)))
        configure(c);
      if (ISVISIBLE(c))
        XMoveResizeWindow(dpy, c->win, c->x, c->y, c->w, c->h);
    } else
      configure(c);
  } else {
    wc.x = ev->x;
    wc.y = ev->y;
    wc.width = ev->width;
    wc.height = ev->height;
    wc.border_width = ev->border_width;
    wc.sibling = ev->above;
    wc.stack_mode = ev->detail;
    XConfigureWindow(dpy, ev->window, ev->value_mask, &wc);
  }
  XSync(dpy, False);
}

Monitor *createmon(void) {
  Monitor *m;
  unsigned int i;

  m = ecalloc(1, sizeof(Monitor));
  m->tagset[0] = m->tagset[1] = 1;
  m->mfact = mfact;
  m->nmaster = nmaster;
  m->showbar = showbar;
  m->showtab = showtab;
  m->topbar = topbar;
  m->toptab = toptab;
  m->bh = bh;
  m->ntabs = 0;
  m->lt[0] = &layouts[0];
  m->lt[1] = &layouts[1 % LENGTH(layouts)];
  strncpy(m->ltsymbol, layouts[0].symbol, sizeof m->ltsymbol);
  m->pertag = ecalloc(1, sizeof(Pertag));
  m->pertag->curtag = m->pertag->prevtag = 1;

  for (i = 0; i <= LENGTH(tags); i++) {
    m->pertag->nmasters[i] = m->nmaster;
    m->pertag->mfacts[i] = m->mfact;

    m->pertag->ltidxs[i][0] = m->lt[0];
    m->pertag->ltidxs[i][1] = m->lt[1];
    m->pertag->sellts[i] = m->sellt;

    m->pertag->showbars[i] = m->showbar;
  }

  return m;
}

void destroynotify(XEvent *e) {
  Client *c;
  Monitor *m;
  XDestroyWindowEvent *ev = &e->xdestroywindow;

  if ((c = wintoclient(ev->window)))
    unmanage(c, 1);
  else if ((m = wintomon(ev->window)) && m->barwin == ev->window)
    unmanagealtbar(ev->window);
  else if (m->traywin == ev->window)
    unmanagetray(ev->window);
}

void detach(Client *c) {
  Client **tc;

  for (tc = &c->mon->clients; *tc && *tc != c; tc = &(*tc)->next)
    ;
  *tc = c->next;
}

void detachstack(Client *c) {
  Client **tc, *t;

  for (tc = &c->mon->stack; *tc && *tc != c; tc = &(*tc)->snext)
    ;
  *tc = c->snext;

  if (c == c->mon->sel) {
    for (t = c->mon->stack; t && !ISVISIBLE(t); t = t->snext)
      ;
    c->mon->sel = t;
  }
}

Monitor *dirtomon(int dir) {
  Monitor *m = NULL;

  if (dir > 0) {
    if (!(m = selmon->next))
      m = mons;
  } else if (selmon == mons)
    for (m = mons; m->next; m = m->next)
      ;
  else
    for (m = mons; m->next != selmon; m = m->next)
      ;
  return m;
}

int drawstatusbar(Monitor *m, int bh, char *stext) {
  int ret, i, w, x, len;
  short isCode = 0;
  char *text;
  char *p;

  len = strlen(stext) + 1;
  if (!(text = (char *)malloc(sizeof(char) * len)))
    die("malloc");
  p = text;
  memcpy(text, stext, len);

  /* compute width of the status text */
  w = 0;
  i = -1;
  while (text[++i]) {
    if (text[i] == '^') {
      if (!isCode) {
        isCode = 1;
        text[i] = '\0';
        w += TEXTW(text) - lrpad;
        text[i] = '^';
        if (text[++i] == 'f')
          w += atoi(text + ++i);
      } else {
        isCode = 0;
        text = text + i + 1;
        i = -1;
      }
    }
  }
  if (!isCode)
    w += TEXTW(text) - lrpad;
  else
    isCode = 0;
  text = p;

  w += 2; /* 1px padding on both sides */
  ret = x = m->ww - w;

  drw_setscheme(drw, scheme[LENGTH(colors)]);
  drw->scheme[ColFg] = scheme[SchemeNorm][ColFg];
  drw->scheme[ColBg] = scheme[SchemeNorm][ColBg];
  drw_rect(drw, x, 0, w, bh, 1, 1);
  x++;

  /* process status text */
  i = -1;
  while (text[++i]) {
    if (text[i] == '^' && !isCode) {
      isCode = 1;

      text[i] = '\0';
      w = TEXTW(text) - lrpad;
      drw_text(drw, x, 0, w, bh, 0, text, 0);

      x += w;

      /* process code */
      while (text[++i] != '^') {
        if (text[i] == 'c') {
          char buf[8];
          memcpy(buf, (char *)text + i + 1, 7);
          buf[7] = '\0';
          drw_clr_create(drw, &drw->scheme[ColFg], buf);
          i += 7;
        } else if (text[i] == 'b') {
          char buf[8];
          memcpy(buf, (char *)text + i + 1, 7);
          buf[7] = '\0';
          drw_clr_create(drw, &drw->scheme[ColBg], buf);
          i += 7;
        } else if (text[i] == 'C') {
          int c = atoi(text + ++i);
          drw_clr_create(drw, &drw->scheme[ColFg], termcolor[c]);
        } else if (text[i] == 'B') {
          int c = atoi(text + ++i);
          drw_clr_create(drw, &drw->scheme[ColBg], termcolor[c]);
        } else if (text[i] == 'd') {
          drw->scheme[ColFg] = scheme[SchemeNorm][ColFg];
          drw->scheme[ColBg] = scheme[SchemeNorm][ColBg];
        } else if (text[i] == 'r') {
          int rx = atoi(text + ++i);
          while (text[++i] != ',')
            ;
          int ry = atoi(text + ++i);
          while (text[++i] != ',')
            ;
          int rw = atoi(text + ++i);
          while (text[++i] != ',')
            ;
          int rh = atoi(text + ++i);

          drw_rect(drw, rx + x, ry, rw, rh, 1, 0);
        } else if (text[i] == 'f') {
          x += atoi(text + ++i);
        }
      }

      text = text + i + 1;
      i = -1;
      isCode = 0;
    }
  }

  if (!isCode) {
    w = TEXTW(text) - lrpad;
    drw_text(drw, x, 0, w, bh, 0, text, 0);
  }

  drw_setscheme(drw, scheme[SchemeNorm]);
  free(p);

  return ret;
}

void drawbar(Monitor *m) {
  if (usealtbar)
    return;

  int x, w, sw = 0;
  int boxs = drw->fonts->h / 9;
  int boxw = drw->fonts->h / 6 + 2;
  unsigned int i, occ = 0, urg = 0;
  Client *c;

  /* draw status first so it can be overdrawn by tags later */
  if (m == selmon) { /* status is only drawn on selected monitor */
    sw = m->ww - drawstatusbar(m, bh, stext);
  }

  for (c = m->clients; c; c = c->next) {
    occ |= c->tags;
    if (c->isurgent)
      urg |= c->tags;
  }
  x = 0;
  for (i = 0; i < LENGTH(tags); i++) {
    w = TEXTW(tags[i]);
    drw_setscheme(
        drw, scheme[m->tagset[m->seltags] & 1 << i ? SchemeSel : SchemeNorm]);
    drw_text(drw, x, 0, w, bh, lrpad / 2, tags[i], urg & 1 << i);
    if (occ & 1 << i)
      drw_rect(drw, x + boxs, boxs, boxw, boxw,
               m == selmon && selmon->sel && selmon->sel->tags & 1 << i,
               urg & 1 << i);
    x += w;
  }
  w = blw = TEXTW(m->ltsymbol);
  drw_setscheme(drw, scheme[SchemeNorm]);
  x = drw_text(drw, x, 0, w, bh, lrpad / 2, m->ltsymbol, 0);

  if ((w = m->ww - sw - x) > bh) {
    if (m->sel) {
      drw_setscheme(drw, scheme[m == selmon ? SchemeSel : SchemeNorm]);
      drw_text(drw, x, 0, w, bh, lrpad / 2, m->sel->name, 0);
      if (m->sel->isfloating)
        drw_rect(drw, x + boxs, boxs, boxw, boxw, m->sel->isfixed, 0);
    } else {
      drw_setscheme(drw, scheme[SchemeNorm]);
      drw_rect(drw, x, 0, w, bh, 1, 1);
    }
  }
  drw_map(drw, m->barwin, 0, 0, m->ww, bh);
}

void drawbars(void) {
  Monitor *m;

  for (m = mons; m; m = m->next)
    drawbar(m);
}

void drawtabs(void) {
  Monitor *m;

  for (m = mons; m; m = m->next)
    drawtab(m);
}

static int cmpint(const void *p1, const void *p2) {
  /* The actual arguments to this function are "pointers to
     pointers to char", but strcmp(3) arguments are "pointers
     to char", hence the following cast plus dereference */
  return *((int *)p1) > *(int *)p2;
}

void drawtab(Monitor *m) {
  Client *c;
  int i;
  int itag = -1;
  char view_info[50];
  int view_info_w = 0;
  int sorted_label_widths[MAXTABS];
  int tot_width;
  int maxsize = bh;
  int x = 0;
  int w = 0;

  // view_info: indicate the tag which is displayed in the view
  for (i = 0; i < LENGTH(tags); ++i) {
    if ((selmon->tagset[selmon->seltags] >> i) & 1) {
      if (itag >= 0) { // more than one tag selected
        itag = -1;
        break;
      }
      itag = i;
    }
  }

  if (0 <= itag && itag < LENGTH(tags)) {
    snprintf(view_info, sizeof view_info, "[%s]", tags[itag]);
  } else {
    strncpy(view_info, "[...]", sizeof view_info);
  }
  view_info[sizeof(view_info) - 1] = 0;
  view_info_w = TEXTW(view_info);
  tot_width = view_info_w;

  /* Calculates number of labels and their width */
  m->ntabs = 0;
  for (c = m->clients; c; c = c->next) {
    if (!ISVISIBLE(c))
      continue;
    m->tab_widths[m->ntabs] = TEXTW(c->name);
    tot_width += m->tab_widths[m->ntabs];
    ++m->ntabs;
    if (m->ntabs >= MAXTABS)
      break;
  }

  if (tot_width > m->ww) { // not enough space to display the labels, they need
                           // to be truncated
    memcpy(sorted_label_widths, m->tab_widths, sizeof(int) * m->ntabs);
    qsort(sorted_label_widths, m->ntabs, sizeof(int), cmpint);
    tot_width = view_info_w;
    for (i = 0; i < m->ntabs; ++i) {
      if (tot_width + (m->ntabs - i) * sorted_label_widths[i] > m->ww)
        break;
      tot_width += sorted_label_widths[i];
    }
    maxsize = (m->ww - tot_width) / (m->ntabs - i);
  } else {
    maxsize = m->ww;
  }
  i = 0;
  for (c = m->clients; c; c = c->next) {
    if (!ISVISIBLE(c))
      continue;
    if (i >= m->ntabs)
      break;
    if (m->tab_widths[i] > maxsize)
      m->tab_widths[i] = maxsize;
    w = m->tab_widths[i];
    drw_setscheme(drw, scheme[(c == m->sel) ? SchemeSel : SchemeNorm]);
    drw_text(drw, x, 0, w, th, 0, c->name, 0);
    x += w;
    ++i;
  }

  drw_setscheme(drw, scheme[SchemeNorm]);

  /* cleans interspace between window names and current viewed tag label */
  w = m->ww - view_info_w - x;
  drw_text(drw, x, 0, w, th, 0, "", 0);

  /* view info */
  x += w;
  w = view_info_w;
  drw_text(drw, x, 0, w, th, 0, view_info, 0);

  drw_map(drw, m->tabwin, 0, 0, m->ww, th);
}

void enternotify(XEvent *e) {
  Client *c;
  Monitor *m;
  XCrossingEvent *ev = &e->xcrossing;

  if ((ev->mode != NotifyNormal || ev->detail == NotifyInferior) &&
      ev->window != root)
    return;
  c = wintoclient(ev->window);
  m = c ? c->mon : wintomon(ev->window);
  if (m != selmon) {
    unfocus(selmon->sel, 1);
    selmon = m;
  } else if (!c || c == selmon->sel)
    return;
  focus(c);
}

void expose(XEvent *e) {
  Monitor *m;
  XExposeEvent *ev = &e->xexpose;

  if (ev->count == 0 && (m = wintomon(ev->window))) {
    drawbar(m);
    drawtab(m);
  }
}

void focus(Client *c) {
  if (!c || !ISVISIBLE(c))
    for (c = selmon->stack; c && !ISVISIBLE(c); c = c->snext)
      ;
  if (selmon->sel && selmon->sel != c)
    unfocus(selmon->sel, 0);
  if (c) {
    if (c->mon != selmon)
      selmon = c->mon;
    if (c->isurgent)
      seturgent(c, 0);
    detachstack(c);
    attachstack(c);
    grabbuttons(c, 1);
    XSetWindowBorder(dpy, c->win, scheme[SchemeSel][ColBorder].pixel);
    setfocus(c);
  } else {
    XSetInputFocus(dpy, root, RevertToPointerRoot, CurrentTime);
    XDeleteProperty(dpy, root, netatom[NetActiveWindow]);
  }
  selmon->sel = c;
  drawbars();
  drawtabs();
}

/* there are some broken focus acquiring clients needing extra handling */
void focusin(XEvent *e) {
  XFocusChangeEvent *ev = &e->xfocus;

  if (selmon->sel && ev->window != selmon->sel->win)
    setfocus(selmon->sel);
}

void focusmon(const Arg *arg) {
  Monitor *m;

  if (!mons->next)
    return;
  if ((m = dirtomon(arg->i)) == selmon)
    return;
  unfocus(selmon->sel, 0);
  selmon = m;
  focus(NULL);
}

void focusstack(const Arg *arg) {
  Client *c = NULL, *i;

  if (!selmon->sel)
    return;
  if (arg->i > 0) {
    for (c = selmon->sel->next; c && !ISVISIBLE(c); c = c->next)
      ;
    if (!c)
      for (c = selmon->clients; c && !ISVISIBLE(c); c = c->next)
        ;
  } else {
    for (i = selmon->clients; i != selmon->sel; i = i->next)
      if (ISVISIBLE(i))
        c = i;
    if (!c)
      for (; i; i = i->next)
        if (ISVISIBLE(i))
          c = i;
  }
  if (c) {
    focus(c);
    restack(selmon);
  }
}

void focuswin(const Arg *arg) {
  int iwin = arg->i;
  Client *c = NULL;
  for (c = selmon->clients; c && (iwin || !ISVISIBLE(c)); c = c->next) {
    if (ISVISIBLE(c))
      --iwin;
  };
  if (c) {
    focus(c);
    restack(selmon);
  }
}

Atom getatomprop(Client *c, Atom prop) {
  int di;
  unsigned long dl;
  unsigned char *p = NULL;
  Atom da, atom = None;

  if (XGetWindowProperty(dpy, c->win, prop, 0L, sizeof atom, False, XA_ATOM,
                         &da, &di, &dl, &dl, &p) == Success &&
      p) {
    atom = *(Atom *)p;
    XFree(p);
  }
  return atom;
}

int getrootptr(int *x, int *y) {
  int di;
  unsigned int dui;
  Window dummy;

  return XQueryPointer(dpy, root, &dummy, &dummy, x, y, &di, &di, &dui);
}

long getstate(Window w) {
  int format;
  long result = -1;
  unsigned char *p = NULL;
  unsigned long n, extra;
  Atom real;

  if (XGetWindowProperty(dpy, w, wmatom[WMState], 0L, 2L, False,
                         wmatom[WMState], &real, &format, &n, &extra,
                         (unsigned char **)&p) != Success)
    return -1;
  if (n != 0)
    result = *p;
  XFree(p);
  return result;
}

int gettextprop(Window w, Atom atom, char *text, unsigned int size) {
  char **list = NULL;
  int n;
  XTextProperty name;

  if (!text || size == 0)
    return 0;
  text[0] = '\0';
  if (!XGetTextProperty(dpy, w, &name, atom) || !name.nitems)
    return 0;
  if (name.encoding == XA_STRING)
    strncpy(text, (char *)name.value, size - 1);
  else {
    if (XmbTextPropertyToTextList(dpy, &name, &list, &n) >= Success && n > 0 &&
        *list) {
      strncpy(text, *list, size - 1);
      XFreeStringList(list);
    }
  }
  text[size - 1] = '\0';
  XFree(name.value);
  return 1;
}

void grabbuttons(Client *c, int focused) {
  updatenumlockmask();
  {
    unsigned int i, j;
    unsigned int modifiers[] = {0, LockMask, numlockmask,
                                numlockmask | LockMask};
    XUngrabButton(dpy, AnyButton, AnyModifier, c->win);
    if (!focused)
      XGrabButton(dpy, AnyButton, AnyModifier, c->win, False, BUTTONMASK,
                  GrabModeSync, GrabModeSync, None, None);
    for (i = 0; i < LENGTH(buttons); i++)
      if (buttons[i].click == ClkClientWin)
        for (j = 0; j < LENGTH(modifiers); j++)
          XGrabButton(dpy, buttons[i].button, buttons[i].mask | modifiers[j],
                      c->win, False, BUTTONMASK, GrabModeAsync, GrabModeSync,
                      None, None);
  }
}

void grabkeys(void) {
  updatenumlockmask();
  {
    unsigned int i, j;
    unsigned int modifiers[] = {0, LockMask, numlockmask,
                                numlockmask | LockMask};
    KeyCode code;

    XUngrabKey(dpy, AnyKey, AnyModifier, root);
    for (i = 0; i < LENGTH(keys); i++)
      if ((code = XKeysymToKeycode(dpy, keys[i].keysym)))
        for (j = 0; j < LENGTH(modifiers); j++)
          XGrabKey(dpy, code, keys[i].mod | modifiers[j], root, True,
                   GrabModeAsync, GrabModeAsync);
  }
}

int handlexevent(struct epoll_event *ev) {
  if (ev->events & EPOLLIN) {
    XEvent ev;
    while (running && XPending(dpy)) {
      XNextEvent(dpy, &ev);
      if (handler[ev.type]) {
        handler[ev.type](&ev); /* call handler */
        ipc_send_events(mons, &lastselmon, selmon);
      }
    }
  } else if (ev->events & EPOLLHUP) {
    return -1;
  }

  return 0;
}

void incnmaster(const Arg *arg) {
  unsigned int i;
  selmon->nmaster = MAX(selmon->nmaster + arg->i, 0);
  for (i = 0; i < LENGTH(tags); ++i)
    if (selmon->tagset[selmon->seltags] & 1 << i)
      selmon->pertag->nmasters[i + 1] = selmon->nmaster;

  if (selmon->pertag->curtag == 0) {
    selmon->pertag->nmasters[0] = selmon->nmaster;
  }
  arrange(selmon);
}

#ifdef XINERAMA
static int isuniquegeom(XineramaScreenInfo *unique, size_t n,
                        XineramaScreenInfo *info) {
  while (n--)
    if (unique[n].x_org == info->x_org && unique[n].y_org == info->y_org &&
        unique[n].width == info->width && unique[n].height == info->height)
      return 0;
  return 1;
}
#endif /* XINERAMA */

void keypress(XEvent *e) {
  unsigned int i;
  KeySym keysym;
  XKeyEvent *ev;

  ev = &e->xkey;
  keysym = XKeycodeToKeysym(dpy, (KeyCode)ev->keycode, 0);
  for (i = 0; i < LENGTH(keys); i++)
    if (keysym == keys[i].keysym &&
        CLEANMASK(keys[i].mod) == CLEANMASK(ev->state) && keys[i].func)
      keys[i].func(&(keys[i].arg));
}

void killclient(const Arg *arg) {
  if (!selmon->sel)
    return;
  if (!sendevent(selmon->sel, wmatom[WMDelete])) {
    XGrabServer(dpy);
    XSetErrorHandler(xerrordummy);
    XSetCloseDownMode(dpy, DestroyAll);
    XKillClient(dpy, selmon->sel->win);
    XSync(dpy, False);
    XSetErrorHandler(xerror);
    XUngrabServer(dpy);
  }
}

void loadxrdb() {
  Display *display;
  char *resm;
  XrmDatabase xrdb;
  char *type;
  XrmValue value;

  display = XOpenDisplay(NULL);

  if (display != NULL) {
    resm = XResourceManagerString(display);

    if (resm != NULL) {
      xrdb = XrmGetStringDatabase(resm);

      if (xrdb != NULL) {
        XRDB_LOAD_COLOR("dwm.normbordercolor", normbordercolor);
        XRDB_LOAD_COLOR("dwm.normbgcolor", normbgcolor);
        XRDB_LOAD_COLOR("dwm.normfgcolor", normfgcolor);
        XRDB_LOAD_COLOR("dwm.selbordercolor", selbordercolor);
        XRDB_LOAD_COLOR("dwm.selbgcolor", selbgcolor);
        XRDB_LOAD_COLOR("dwm.selfgcolor", selfgcolor);
        XRDB_LOAD_COLOR("color0", termcol0);
        XRDB_LOAD_COLOR("color1", termcol1);
        XRDB_LOAD_COLOR("color2", termcol2);
        XRDB_LOAD_COLOR("color3", termcol3);
        XRDB_LOAD_COLOR("color4", termcol4);
        XRDB_LOAD_COLOR("color5", termcol5);
        XRDB_LOAD_COLOR("color6", termcol6);
        XRDB_LOAD_COLOR("color7", termcol7);
        XRDB_LOAD_COLOR("color8", termcol8);
        XRDB_LOAD_COLOR("color9", termcol9);
        XRDB_LOAD_COLOR("color10", termcol10);
        XRDB_LOAD_COLOR("color11", termcol11);
        XRDB_LOAD_COLOR("color12", termcol12);
        XRDB_LOAD_COLOR("color13", termcol13);
        XRDB_LOAD_COLOR("color14", termcol14);
        XRDB_LOAD_COLOR("color15", termcol15);
      }
    }
  }

  XCloseDisplay(display);
}

void manage(Window w, XWindowAttributes *wa) {
  Client *c, *t = NULL;
  Window trans = None;
  XWindowChanges wc;

  c = ecalloc(1, sizeof(Client));
  c->win = w;
  /* geometry */
  c->x = c->oldx = wa->x;
  c->y = c->oldy = wa->y;
  c->w = c->oldw = wa->width;
  c->h = c->oldh = wa->height;
  c->oldbw = wa->border_width;

  updatetitle(c);
  if (XGetTransientForHint(dpy, w, &trans) && (t = wintoclient(trans))) {
    c->mon = t->mon;
    c->tags = t->tags;
  } else {
    c->mon = selmon;
    applyrules(c);
  }

  if (c->x + WIDTH(c) > c->mon->mx + c->mon->mw)
    c->x = c->mon->mx + c->mon->mw - WIDTH(c);
  if (c->y + HEIGHT(c) > c->mon->my + c->mon->mh)
    c->y = c->mon->my + c->mon->mh - HEIGHT(c);
  c->x = MAX(c->x, c->mon->mx);
  /* only fix client y-offset, if the client center might cover the bar */
  c->y = MAX(c->y,
             ((c->mon->by == c->mon->my) && (c->x + (c->w / 2) >= c->mon->wx) &&
              (c->x + (c->w / 2) < c->mon->wx + c->mon->ww))
                 ? bh
                 : c->mon->my);
  c->bw = borderpx;

  wc.border_width = c->bw;
  XConfigureWindow(dpy, w, CWBorderWidth, &wc);
  XSetWindowBorder(dpy, w, scheme[SchemeNorm][ColBorder].pixel);
  configure(c); /* propagates border_width, if size doesn't change */
  updatewindowtype(c);
  updatesizehints(c);
  updatewmhints(c);
  XSelectInput(dpy, w,
               EnterWindowMask | FocusChangeMask | PropertyChangeMask |
                   StructureNotifyMask);
  grabbuttons(c, 0);
  if (!c->isfloating)
    c->isfloating = c->oldstate = trans != None || c->isfixed;
  if (c->isfloating)
    XRaiseWindow(dpy, c->win);
  attachBelow(c);
  attachstack(c);
  XChangeProperty(dpy, root, netatom[NetClientList], XA_WINDOW, 32,
                  PropModeAppend, (unsigned char *)&(c->win), 1);
  XMoveResizeWindow(dpy, c->win, c->x + 2 * sw, c->y, c->w,
                    c->h); /* some windows require this */
  setclientstate(c, NormalState);
  if (c->mon == selmon)
    unfocus(selmon->sel, 0);
  c->mon->sel = c;
  arrange(c->mon);
  XMapWindow(dpy, c->win);
  focus(NULL);
}

void managealtbar(Window win, XWindowAttributes *wa) {
  Monitor *m;
  if (!(m = recttomon(wa->x, wa->y, wa->width, wa->height)))
    return;

  m->barwin = win;
  m->by = wa->y;
  bh = m->bh = wa->height;
  updatebarpos(m);
  arrange(m);
  XSelectInput(dpy, win,
               EnterWindowMask | FocusChangeMask | PropertyChangeMask |
                   StructureNotifyMask);
  XMoveResizeWindow(dpy, win, wa->x, wa->y, wa->width, wa->height);
  XMapWindow(dpy, win);
  XChangeProperty(dpy, root, netatom[NetClientList], XA_WINDOW, 32,
                  PropModeAppend, (unsigned char *)&win, 1);
}

void managetray(Window win, XWindowAttributes *wa) {
  Monitor *m;
  if (!(m = recttomon(wa->x, wa->y, wa->width, wa->height)))
    return;

  m->traywin = win;
  m->tx = wa->x;
  m->tw = wa->width;
  updatebarpos(m);
  arrange(m);
  XSelectInput(dpy, win,
               EnterWindowMask | FocusChangeMask | PropertyChangeMask |
                   StructureNotifyMask);
  XMoveResizeWindow(dpy, win, wa->x, wa->y, wa->width, wa->height);
  XMapWindow(dpy, win);
  XChangeProperty(dpy, root, netatom[NetClientList], XA_WINDOW, 32,
                  PropModeAppend, (unsigned char *)&win, 1);
}

void mappingnotify(XEvent *e) {
  XMappingEvent *ev = &e->xmapping;

  XRefreshKeyboardMapping(ev);
  if (ev->request == MappingKeyboard)
    grabkeys();
}

void maprequest(XEvent *e) {
  static XWindowAttributes wa;
  XMapRequestEvent *ev = &e->xmaprequest;

  if (!XGetWindowAttributes(dpy, ev->window, &wa))
    return;
  if (wa.override_redirect)
    return;
  if (wmclasscontains(ev->window, altbarclass, ""))
    managealtbar(ev->window, &wa);
  else if (!wintoclient(ev->window))
    manage(ev->window, &wa);
}

void monocle(Monitor *m) {
  unsigned int n = 0;
  Client *c;

  for (c = m->clients; c; c = c->next)
    if (ISVISIBLE(c))
      n++;
  if (n > 0) /* override layout symbol */
    snprintf(m->ltsymbol, sizeof m->ltsymbol, "[%d]", n);
  for (c = nexttiled(m->clients); c; c = nexttiled(c->next))
    resize(c, m->wx, m->wy, m->ww - 2 * c->bw, m->wh - 2 * c->bw, 0);
}

void motionnotify(XEvent *e) {
  static Monitor *mon = NULL;
  Monitor *m;
  XMotionEvent *ev = &e->xmotion;

  if (ev->window != root)
    return;
  if ((m = recttomon(ev->x_root, ev->y_root, 1, 1)) != mon && mon) {
    unfocus(selmon->sel, 1);
    selmon = m;
    focus(NULL);
  }
  mon = m;
}

void movemouse(const Arg *arg) {
  int x, y, ocx, ocy, nx, ny;
  Client *c;
  Monitor *m;
  XEvent ev;
  Time lasttime = 0;

  if (!(c = selmon->sel))
    return;
  if (c->isfullscreen) /* no support moving fullscreen windows by mouse */
    return;
  restack(selmon);
  ocx = c->x;
  ocy = c->y;
  if (XGrabPointer(dpy, root, False, MOUSEMASK, GrabModeAsync, GrabModeAsync,
                   None, cursor[CurMove]->cursor, CurrentTime) != GrabSuccess)
    return;
  if (!getrootptr(&x, &y))
    return;
  do {
    XMaskEvent(dpy, MOUSEMASK | ExposureMask | SubstructureRedirectMask, &ev);
    switch (ev.type) {
    case ConfigureRequest:
    case Expose:
    case MapRequest:
      handler[ev.type](&ev);
      break;
    case MotionNotify:
      if ((ev.xmotion.time - lasttime) <= (1000 / 60))
        continue;
      lasttime = ev.xmotion.time;

      nx = ocx + (ev.xmotion.x - x);
      ny = ocy + (ev.xmotion.y - y);
      if (abs(selmon->wx - nx) < snap)
        nx = selmon->wx;
      else if (abs((selmon->wx + selmon->ww) - (nx + WIDTH(c))) < snap)
        nx = selmon->wx + selmon->ww - WIDTH(c);
      if (abs(selmon->wy - ny) < snap)
        ny = selmon->wy;
      else if (abs((selmon->wy + selmon->wh) - (ny + HEIGHT(c))) < snap)
        ny = selmon->wy + selmon->wh - HEIGHT(c);
      if (!c->isfloating && selmon->lt[selmon->sellt]->arrange &&
          (abs(nx - c->x) > snap || abs(ny - c->y) > snap))
        togglefloating(NULL);
      if (!selmon->lt[selmon->sellt]->arrange || c->isfloating)
        resize(c, nx, ny, c->w, c->h, 1);
      break;
    }
  } while (ev.type != ButtonRelease);
  XUngrabPointer(dpy, CurrentTime);
  if ((m = recttomon(c->x, c->y, c->w, c->h)) != selmon) {
    sendmon(c, m);
    selmon = m;
    focus(NULL);
  }
}

Client *nexttagged(Client *c) {
  Client *walked = c->mon->clients;
  for (; walked && (walked->isfloating || !ISVISIBLEONTAG(walked, c->tags));
       walked = walked->next)
    ;
  return walked;
}

Client *nexttiled(Client *c) {
  for (; c && (c->isfloating || !ISVISIBLE(c)); c = c->next)
    ;
  return c;
}

void pop(Client *c) {
  detach(c);
  attach(c);
  focus(c);
  arrange(c->mon);
}

void propertynotify(XEvent *e) {
  Client *c;
  Window trans;
  XPropertyEvent *ev = &e->xproperty;

  if ((ev->window == root) && (ev->atom == XA_WM_NAME))
    updatestatus();
  else if (ev->state == PropertyDelete)
    return; /* ignore */
  else if ((c = wintoclient(ev->window))) {
    switch (ev->atom) {
    default:
      break;
    case XA_WM_TRANSIENT_FOR:
      if (!c->isfloating && (XGetTransientForHint(dpy, c->win, &trans)) &&
          (c->isfloating = (wintoclient(trans)) != NULL))
        arrange(c->mon);
      break;
    case XA_WM_NORMAL_HINTS:
      updatesizehints(c);
      break;
    case XA_WM_HINTS:
      updatewmhints(c);
      drawbars();
      drawtabs();
      break;
    }
    if (ev->atom == XA_WM_NAME || ev->atom == netatom[NetWMName]) {
      updatetitle(c);
      if (c == c->mon->sel)
        drawbar(c->mon);
      drawtab(c->mon);
    }
    if (ev->atom == netatom[NetWMWindowType])
      updatewindowtype(c);
  }
}

void quit(const Arg *arg) {
  if (arg->i)
    restart = 1;
  running = 0;
}

Monitor *recttomon(int x, int y, int w, int h) {
  Monitor *m, *r = selmon;
  int a, area = 0;

  for (m = mons; m; m = m->next)
    if ((a = INTERSECT(x, y, w, h, m)) > area) {
      area = a;
      r = m;
    }
  return r;
}

void resize(Client *c, int x, int y, int w, int h, int interact) {
  if (applysizehints(c, &x, &y, &w, &h, interact))
    resizeclient(c, x, y, w, h);
}

void resizeclient(Client *c, int x, int y, int w, int h) {
  XWindowChanges wc;
  unsigned int n;
  unsigned int gapoffset;
  unsigned int gapincr;
  Client *nbc;

  wc.border_width = c->bw;

  /* Get number of clients for the selected monitor */
  for (n = 0, nbc = nexttiled(selmon->clients); nbc;
       nbc = nexttiled(nbc->next), n++)
    ;

  /* Do nothing if layout is floating */
  if (c->isfloating || selmon->lt[selmon->sellt]->arrange == NULL) {
    gapincr = gapoffset = 0;
  } else {
    /* Remove border and gap if layout is monocle or only one client */
    if (selmon->lt[selmon->sellt]->arrange == monocle || n == 1) {
      gapoffset = 0;
      gapincr = -2 * borderpx;
      wc.border_width = 0;
    } else {
      gapoffset = gappx;
      gapincr = 2 * gappx;
    }
  }

  c->oldx = c->x;
  c->x = wc.x = x + gapoffset;
  c->oldy = c->y;
  c->y = wc.y = y + gapoffset;
  c->oldw = c->w;
  c->w = wc.width = w - gapincr;
  c->oldh = c->h;
  c->h = wc.height = h - gapincr;

  XConfigureWindow(dpy, c->win, CWX | CWY | CWWidth | CWHeight | CWBorderWidth,
                   &wc);
  configure(c);
  XSync(dpy, False);
}

void resizemouse(const Arg *arg) {
  int ocx, ocy, nw, nh;
  Client *c;
  Monitor *m;
  XEvent ev;
  Time lasttime = 0;

  if (!(c = selmon->sel))
    return;
  if (c->isfullscreen) /* no support resizing fullscreen windows by mouse */
    return;
  restack(selmon);
  ocx = c->x;
  ocy = c->y;
  if (XGrabPointer(dpy, root, False, MOUSEMASK, GrabModeAsync, GrabModeAsync,
                   None, cursor[CurResize]->cursor, CurrentTime) != GrabSuccess)
    return;
  XWarpPointer(dpy, None, c->win, 0, 0, 0, 0, c->w + c->bw - 1,
               c->h + c->bw - 1);
  do {
    XMaskEvent(dpy, MOUSEMASK | ExposureMask | SubstructureRedirectMask, &ev);
    switch (ev.type) {
    case ConfigureRequest:
    case Expose:
    case MapRequest:
      handler[ev.type](&ev);
      break;
    case MotionNotify:
      if ((ev.xmotion.time - lasttime) <= (1000 / 60))
        continue;
      lasttime = ev.xmotion.time;

      nw = MAX(ev.xmotion.x - ocx - 2 * c->bw + 1, 1);
      nh = MAX(ev.xmotion.y - ocy - 2 * c->bw + 1, 1);
      if (c->mon->wx + nw >= selmon->wx &&
          c->mon->wx + nw <= selmon->wx + selmon->ww &&
          c->mon->wy + nh >= selmon->wy &&
          c->mon->wy + nh <= selmon->wy + selmon->wh) {
        if (!c->isfloating && selmon->lt[selmon->sellt]->arrange &&
            (abs(nw - c->w) > snap || abs(nh - c->h) > snap))
          togglefloating(NULL);
      }
      if (!selmon->lt[selmon->sellt]->arrange || c->isfloating)
        resize(c, c->x, c->y, nw, nh, 1);
      break;
    }
  } while (ev.type != ButtonRelease);
  XWarpPointer(dpy, None, c->win, 0, 0, 0, 0, c->w + c->bw - 1,
               c->h + c->bw - 1);
  XUngrabPointer(dpy, CurrentTime);
  while (XCheckMaskEvent(dpy, EnterWindowMask, &ev))
    ;
  if ((m = recttomon(c->x, c->y, c->w, c->h)) != selmon) {
    sendmon(c, m);
    selmon = m;
    focus(NULL);
  }
}

void restack(Monitor *m) {
  Client *c;
  XEvent ev;
  XWindowChanges wc;

  drawbar(m);
  drawtab(m);
  if (!m->sel)
    return;
  if (m->sel->isfloating || !m->lt[m->sellt]->arrange)
    XRaiseWindow(dpy, m->sel->win);
  if (m->lt[m->sellt]->arrange) {
    wc.stack_mode = Below;
    wc.sibling = m->barwin;
    for (c = m->stack; c; c = c->snext)
      if (!c->isfloating && ISVISIBLE(c)) {
        XConfigureWindow(dpy, c->win, CWSibling | CWStackMode, &wc);
        wc.sibling = c->win;
      }
  }
  XSync(dpy, False);
  while (XCheckMaskEvent(dpy, EnterWindowMask, &ev))
    ;
}

void run(void) {
  int event_count = 0;
  const int MAX_EVENTS = 10;
  struct epoll_event events[MAX_EVENTS];

  XSync(dpy, False);

  /* main event loop */
  while (running) {
    event_count = epoll_wait(epoll_fd, events, MAX_EVENTS, -1);

    for (int i = 0; i < event_count; i++) {
      int event_fd = events[i].data.fd;
      DEBUG("Got event from fd %d\n", event_fd);

      if (event_fd == dpy_fd) {
        // -1 means EPOLLHUP
        if (handlexevent(events + i) == -1)
          return;
      } else if (event_fd == ipc_get_sock_fd()) {
        ipc_handle_socket_epoll_event(events + i);
      } else if (ipc_is_client_registered(event_fd)) {
        if (ipc_handle_client_epoll_event(events + i, mons, &lastselmon, selmon,
                                          tags, LENGTH(tags), layouts,
                                          LENGTH(layouts)) < 0) {
          fprintf(stderr, "Error handling IPC event on fd %d\n", event_fd);
        }
      } else {
        fprintf(stderr, "Got event from unknown fd %d, ptr %p, u32 %d, u64 %lu",
                event_fd, events[i].data.ptr, events[i].data.u32,
                events[i].data.u64);
        fprintf(stderr, " with events %d\n", events[i].events);
        return;
      }
    }
  }
}

void runautostart(void) {
  char *pathpfx;
  char *path;
  char *xdgdatahome;
  char *home;
  struct stat sb;

  if ((home = getenv("HOME")) == NULL)
    /* this is almost impossible */
    return;

  /* if $XDG_DATA_HOME is set and not empty, use $XDG_DATA_HOME/dwm,
   * otherwise use ~/.local/share/dwm as autostart script directory
   */
  xdgdatahome = getenv("XDG_DATA_HOME");
  if (xdgdatahome != NULL && *xdgdatahome != '\0') {
    /* space for path segments, separators and nul */
    pathpfx = ecalloc(1, strlen(xdgdatahome) + strlen(dwmdir) + 2);

    if (sprintf(pathpfx, "%s/%s", xdgdatahome, dwmdir) <= 0) {
      free(pathpfx);
      return;
    }
  } else {
    /* space for path segments, separators and nul */
    pathpfx =
        ecalloc(1, strlen(home) + strlen(localshare) + strlen(dwmdir) + 3);

    if (sprintf(pathpfx, "%s/%s/%s", home, localshare, dwmdir) < 0) {
      free(pathpfx);
      return;
    }
  }

  /* check if the autostart script directory exists */
  if (!(stat(pathpfx, &sb) == 0 && S_ISDIR(sb.st_mode))) {
    /* the XDG conformant path does not exist or is no directory
     * so we try ~/.dwm instead
     */
    char *pathpfx_new = realloc(pathpfx, strlen(home) + strlen(dwmdir) + 3);
    if (pathpfx_new == NULL) {
      free(pathpfx);
      return;
    }
    pathpfx = pathpfx_new;

    if (sprintf(pathpfx, "%s/.%s", home, dwmdir) <= 0) {
      free(pathpfx);
      return;
    }
  }

  /* try the blocking script first */
  path = ecalloc(1, strlen(pathpfx) + strlen(autostartblocksh) + 2);
  if (sprintf(path, "%s/%s", pathpfx, autostartblocksh) <= 0) {
    free(path);
    free(pathpfx);
  }

  if (access(path, X_OK) == 0)
    system(path);

  /* now the non-blocking script */
  if (sprintf(path, "%s/%s", pathpfx, autostartsh) <= 0) {
    free(path);
    free(pathpfx);
  }

  if (access(path, X_OK) == 0)
    system(strcat(path, " &"));

  free(pathpfx);
  free(path);
}

void scan(void) {
  unsigned int i, num;
  Window d1, d2, *wins = NULL;
  XWindowAttributes wa;

  if (XQueryTree(dpy, root, &d1, &d2, &wins, &num)) {
    for (i = 0; i < num; i++) {
      if (!XGetWindowAttributes(dpy, wins[i], &wa) || wa.override_redirect ||
          XGetTransientForHint(dpy, wins[i], &d1))
        continue;
      if (wmclasscontains(wins[i], altbarclass, ""))
        managealtbar(wins[i], &wa);
      else if (wa.map_state == IsViewable || getstate(wins[i]) == IconicState)
        manage(wins[i], &wa);
    }
    for (i = 0; i < num; i++) { /* now the transients */
      if (!XGetWindowAttributes(dpy, wins[i], &wa))
        continue;
      if (XGetTransientForHint(dpy, wins[i], &d1) &&
          (wa.map_state == IsViewable || getstate(wins[i]) == IconicState))
        manage(wins[i], &wa);
    }
    if (wins)
      XFree(wins);
  }
}

void scantray(void) {
  unsigned int num;
  Window d1, d2, *wins = NULL;
  XWindowAttributes wa;

  if (XQueryTree(dpy, root, &d1, &d2, &wins, &num)) {
    for (unsigned int i = 0; i < num; i++) {
      if (wmclasscontains(wins[i], altbarclass, alttrayname)) {
        if (!XGetWindowAttributes(dpy, wins[i], &wa))
          break;
        managetray(wins[i], &wa);
      }
    }
  }

  if (wins)
    XFree(wins);
}

void sendmon(Client *c, Monitor *m) {
  if (c->mon == m)
    return;
  unfocus(c, 1);
  detach(c);
  detachstack(c);
  c->mon = m;
  c->tags = m->tagset[m->seltags]; /* assign tags of target monitor */
  attachBelow(c);
  attachstack(c);
  focus(NULL);
  arrange(NULL);
}

void setclientstate(Client *c, long state) {
  long data[] = {state, None};

  XChangeProperty(dpy, c->win, wmatom[WMState], wmatom[WMState], 32,
                  PropModeReplace, (unsigned char *)data, 2);
}

int sendevent(Client *c, Atom proto) {
  int n;
  Atom *protocols;
  int exists = 0;
  XEvent ev;

  if (XGetWMProtocols(dpy, c->win, &protocols, &n)) {
    while (!exists && n--)
      exists = protocols[n] == proto;
    XFree(protocols);
  }
  if (exists) {
    ev.type = ClientMessage;
    ev.xclient.window = c->win;
    ev.xclient.message_type = wmatom[WMProtocols];
    ev.xclient.format = 32;
    ev.xclient.data.l[0] = proto;
    ev.xclient.data.l[1] = CurrentTime;
    XSendEvent(dpy, c->win, False, NoEventMask, &ev);
  }
  return exists;
}

void setfocus(Client *c) {
  if (!c->neverfocus) {
    XSetInputFocus(dpy, c->win, RevertToPointerRoot, CurrentTime);
    XChangeProperty(dpy, root, netatom[NetActiveWindow], XA_WINDOW, 32,
                    PropModeReplace, (unsigned char *)&(c->win), 1);
  }
  sendevent(c, wmatom[WMTakeFocus]);
}

void setfullscreen(Client *c, int fullscreen) {
  if (fullscreen && !c->isfullscreen) {
    XChangeProperty(dpy, c->win, netatom[NetWMState], XA_ATOM, 32,
                    PropModeReplace, (unsigned char *)&netatom[NetWMFullscreen],
                    1);
    c->isfullscreen = 1;
    c->oldstate = c->isfloating;
    c->oldbw = c->bw;
    c->bw = 0;
    c->isfloating = 1;
    resizeclient(c, c->mon->mx, c->mon->my, c->mon->mw, c->mon->mh);
    XRaiseWindow(dpy, c->win);
  } else if (!fullscreen && c->isfullscreen) {
    XChangeProperty(dpy, c->win, netatom[NetWMState], XA_ATOM, 32,
                    PropModeReplace, (unsigned char *)0, 0);
    c->isfullscreen = 0;
    c->isfloating = c->oldstate;
    c->bw = c->oldbw;
    c->x = c->oldx;
    c->y = c->oldy;
    c->w = c->oldw;
    c->h = c->oldh;
    resizeclient(c, c->x, c->y, c->w, c->h);
    arrange(c->mon);
  }
}

Layout *last_layout;
void fullscreen(const Arg *arg) {
  if (selmon->showbar) {
    for (last_layout = (Layout *)layouts;
         last_layout != selmon->lt[selmon->sellt]; last_layout++)
      ;
    setlayout(&((Arg){.v = &layouts[2]}));
  } else {
    setlayout(&((Arg){.v = last_layout}));
  }
  togglebar(arg);
}

void setlayout(const Arg *arg) {
  unsigned int i;
  if (!arg || !arg->v || arg->v != selmon->lt[selmon->sellt])
    selmon->sellt ^= 1;
  if (arg && arg->v)
    selmon->lt[selmon->sellt] = (Layout *)arg->v;
  strncpy(selmon->ltsymbol, selmon->lt[selmon->sellt]->symbol,
          sizeof selmon->ltsymbol);

  for (i = 0; i < LENGTH(tags); ++i)
    if (selmon->tagset[selmon->seltags] & 1 << i) {
      selmon->pertag->ltidxs[i + 1][selmon->sellt] = selmon->lt[selmon->sellt];
      selmon->pertag->sellts[i + 1] = selmon->sellt;
    }

  if (selmon->pertag->curtag == 0) {
    selmon->pertag->ltidxs[0][selmon->sellt] = selmon->lt[selmon->sellt];
    selmon->pertag->sellts[0] = selmon->sellt;
  }

  if (selmon->sel)
    arrange(selmon);
  else
    drawbar(selmon);
}

void setlayoutsafe(const Arg *arg) {
  const Layout *ltptr = (Layout *)arg->v;
  if (ltptr == 0)
    setlayout(arg);
  for (int i = 0; i < LENGTH(layouts); i++) {
    if (ltptr == &layouts[i])
      setlayout(arg);
  }
}

/* arg > 1.0 will set mfact absolutely */
void setmfact(const Arg *arg) {
  float f;
  unsigned int i;

  if (!arg || !selmon->lt[selmon->sellt]->arrange)
    return;
  f = arg->f < 1.0 ? arg->f + selmon->mfact : arg->f - 1.0;
  if (arg->f == 0.0)
    f = mfact;
  if (f < 0.05 || f > 0.95)
    return;
  selmon->mfact = f;
  for (i = 0; i < LENGTH(tags); ++i)
    if (selmon->tagset[selmon->seltags] & 1 << i)
      selmon->pertag->mfacts[i + 1] = f;

  if (selmon->pertag->curtag == 0) {
    selmon->pertag->mfacts[0] = f;
  }
  arrange(selmon);
}

void setup(void) {
  int i;
  XSetWindowAttributes wa;
  Atom utf8string;

  /* clean up any zombies immediately */
  sigchld(0);

  signal(SIGHUP, sighup);
  signal(SIGTERM, sigterm);

  /* init screen */
  screen = DefaultScreen(dpy);
  sw = DisplayWidth(dpy, screen);
  sh = DisplayHeight(dpy, screen);
  root = RootWindow(dpy, screen);
  drw = drw_create(dpy, screen, root, sw, sh);
  if (!drw_fontset_create(drw, fonts, LENGTH(fonts)))
    die("no fonts could be loaded.");
  lrpad = drw->fonts->h;
  bh = usealtbar ? 0 : drw->fonts->h + 2;
  th = bh;
  updategeom();
  /* init atoms */
  utf8string = XInternAtom(dpy, "UTF8_STRING", False);
  wmatom[WMProtocols] = XInternAtom(dpy, "WM_PROTOCOLS", False);
  wmatom[WMDelete] = XInternAtom(dpy, "WM_DELETE_WINDOW", False);
  wmatom[WMState] = XInternAtom(dpy, "WM_STATE", False);
  wmatom[WMTakeFocus] = XInternAtom(dpy, "WM_TAKE_FOCUS", False);
  netatom[NetActiveWindow] = XInternAtom(dpy, "_NET_ACTIVE_WINDOW", False);
  netatom[NetSupported] = XInternAtom(dpy, "_NET_SUPPORTED", False);
  netatom[NetWMName] = XInternAtom(dpy, "_NET_WM_NAME", False);
  netatom[NetWMState] = XInternAtom(dpy, "_NET_WM_STATE", False);
  netatom[NetWMCheck] = XInternAtom(dpy, "_NET_SUPPORTING_WM_CHECK", False);
  netatom[NetWMFullscreen] =
      XInternAtom(dpy, "_NET_WM_STATE_FULLSCREEN", False);
  netatom[NetWMWindowType] = XInternAtom(dpy, "_NET_WM_WINDOW_TYPE", False);
  netatom[NetWMWindowTypeDialog] =
      XInternAtom(dpy, "_NET_WM_WINDOW_TYPE_DIALOG", False);
  netatom[NetClientList] = XInternAtom(dpy, "_NET_CLIENT_LIST", False);
  /* init cursors */
  cursor[CurNormal] = drw_cur_create(drw, XC_left_ptr);
  cursor[CurResize] = drw_cur_create(drw, XC_sizing);
  cursor[CurMove] = drw_cur_create(drw, XC_fleur);
  /* init appearance */
  scheme = ecalloc(LENGTH(colors) + 1, sizeof(Clr *));
  scheme[LENGTH(colors)] = drw_scm_create(drw, colors[0], 3);
  for (i = 0; i < LENGTH(colors); i++)
    scheme[i] = drw_scm_create(drw, colors[i], 3);
  /* init bars */
  updatebars();
  updatestatus();
  /* supporting window for NetWMCheck */
  wmcheckwin = XCreateSimpleWindow(dpy, root, 0, 0, 1, 1, 0, 0, 0);
  XChangeProperty(dpy, wmcheckwin, netatom[NetWMCheck], XA_WINDOW, 32,
                  PropModeReplace, (unsigned char *)&wmcheckwin, 1);
  XChangeProperty(dpy, wmcheckwin, netatom[NetWMName], utf8string, 8,
                  PropModeReplace, (unsigned char *)"dwm", 3);
  XChangeProperty(dpy, root, netatom[NetWMCheck], XA_WINDOW, 32,
                  PropModeReplace, (unsigned char *)&wmcheckwin, 1);
  /* EWMH support per view */
  XChangeProperty(dpy, root, netatom[NetSupported], XA_ATOM, 32,
                  PropModeReplace, (unsigned char *)netatom, NetLast);
  XDeleteProperty(dpy, root, netatom[NetClientList]);
  /* select events */
  wa.cursor = cursor[CurNormal]->cursor;
  wa.event_mask = SubstructureRedirectMask | SubstructureNotifyMask |
                  ButtonPressMask | PointerMotionMask | EnterWindowMask |
                  LeaveWindowMask | StructureNotifyMask | PropertyChangeMask;
  XChangeWindowAttributes(dpy, root, CWEventMask | CWCursor, &wa);
  XSelectInput(dpy, root, wa.event_mask);
  grabkeys();
  focus(NULL);
  spawnbar();
  setupepoll();
}

void setupepoll(void) {
  epoll_fd = epoll_create1(0);
  dpy_fd = ConnectionNumber(dpy);
  struct epoll_event dpy_event;

  // Initialize struct to 0
  memset(&dpy_event, 0, sizeof(dpy_event));

  DEBUG("Display socket is fd %d\n", dpy_fd);

  if (epoll_fd == -1) {
    fputs("Failed to create epoll file descriptor", stderr);
  }

  dpy_event.events = EPOLLIN;
  dpy_event.data.fd = dpy_fd;
  if (epoll_ctl(epoll_fd, EPOLL_CTL_ADD, dpy_fd, &dpy_event)) {
    fputs("Failed to add display file descriptor to epoll", stderr);
    close(epoll_fd);
    exit(1);
  }

  if (ipc_init(ipcsockpath, epoll_fd, ipccommands, LENGTH(ipccommands)) < 0) {
    fputs("Failed to initialize IPC\n", stderr);
  }
}

void seturgent(Client *c, int urg) {
  XWMHints *wmh;

  c->isurgent = urg;
  if (!(wmh = XGetWMHints(dpy, c->win)))
    return;
  wmh->flags = urg ? (wmh->flags | XUrgencyHint) : (wmh->flags & ~XUrgencyHint);
  XSetWMHints(dpy, c->win, wmh);
  XFree(wmh);
}

void showhide(Client *c) {
  if (!c)
    return;
  if (ISVISIBLE(c)) {
    /* show clients top down */
    XMoveWindow(dpy, c->win, c->x, c->y);
    if ((!c->mon->lt[c->mon->sellt]->arrange || c->isfloating) &&
        !c->isfullscreen)
      resize(c, c->x, c->y, c->w, c->h, 0);
    showhide(c->snext);
  } else {
    /* hide clients bottom up */
    showhide(c->snext);
    XMoveWindow(dpy, c->win, WIDTH(c) * -2, c->y);
  }
}

void sigchld(int unused) {
  if (signal(SIGCHLD, sigchld) == SIG_ERR)
    die("can't install SIGCHLD handler:");
  while (0 < waitpid(-1, NULL, WNOHANG))
    ;
}

void sighup(int unused) {
  Arg a = {.i = 1};
  quit(&a);
}

void sigterm(int unused) {
  Arg a = {.i = 0};
  quit(&a);
}

void spawn(const Arg *arg) {
  if (arg->v == dmenucmd)
    dmenumon[0] = '0' + selmon->num;
  if (fork() == 0) {
    if (dpy)
      close(ConnectionNumber(dpy));
    setsid();
    execvp(((char **)arg->v)[0], (char **)arg->v);
    fprintf(stderr, "dwm: execvp %s", ((char **)arg->v)[0]);
    perror(" failed");
    exit(EXIT_SUCCESS);
  }
}

void spawnbar() {
  if (*altbarcmd)
    system(altbarcmd);
}

void tag(const Arg *arg) {
  if (selmon->sel && arg->ui & TAGMASK) {
    selmon->sel->tags = arg->ui & TAGMASK;
    focus(NULL);
    arrange(selmon);
  }
}

void tagmon(const Arg *arg) {
  if (!selmon->sel || !mons->next)
    return;
  sendmon(selmon->sel, dirtomon(arg->i));
}

void tile(Monitor *m) {
  unsigned int i, n, h, mw, my, ty;
  Client *c;

  for (n = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), n++)
    ;
  if (n == 0)
    return;

  if (n > m->nmaster)
    mw = m->nmaster ? m->ww * m->mfact : 0;
  else
    mw = m->ww;
  for (i = my = ty = 0, c = nexttiled(m->clients); c;
       c = nexttiled(c->next), i++)
    if (i < m->nmaster) {
      h = (m->wh - my) / (MIN(n, m->nmaster) - i);
      resize(c, m->wx, m->wy + my, mw - (2 * c->bw), h - (2 * c->bw), 0);
      my += HEIGHT(c);
    } else {
      h = (m->wh - ty) / (n - i);
      resize(c, m->wx + mw, m->wy + ty, m->ww - mw - (2 * c->bw),
             h - (2 * c->bw), 0);
      ty += HEIGHT(c);
    }
}

void togglebar(const Arg *arg) {
  /**
   * Polybar tray does not raise maprequest event. It must be manually scanned
   * for. Scanning it too early while the tray is being populated would give
   * wrong dimensions.
   */
  if (!selmon->traywin)
    scantray();

  unsigned int i;
  selmon->showbar = !selmon->showbar;
  for (i = 0; i < LENGTH(tags); ++i)
    if (selmon->tagset[selmon->seltags] & 1 << i)
      selmon->pertag->showbars[i + 1] = selmon->showbar;

  if (selmon->pertag->curtag == 0) {
    selmon->pertag->showbars[0] = selmon->showbar;
  }
  updatebarpos(selmon);
  XMoveResizeWindow(dpy, selmon->barwin, selmon->wx, selmon->by, selmon->ww,
                    selmon->bh);
  XMoveResizeWindow(dpy, selmon->traywin, selmon->tx, selmon->by, selmon->tw,
                    selmon->bh);
  arrange(selmon);
}

void tabmode(const Arg *arg) {
  if (arg && arg->i >= 0)
    selmon->showtab = arg->ui % showtab_nmodes;
  else
    selmon->showtab = (selmon->showtab + 1) % showtab_nmodes;
  arrange(selmon);
}

void togglefloating(const Arg *arg) {
  if (!selmon->sel)
    return;
  if (selmon->sel->isfullscreen) /* no support for fullscreen windows */
    return;
  selmon->sel->isfloating = !selmon->sel->isfloating || selmon->sel->isfixed;
  if (selmon->sel->isfloating)
    resize(selmon->sel, selmon->sel->x, selmon->sel->y, selmon->sel->w,
           selmon->sel->h, 0);
  arrange(selmon);
}

void toggletag(const Arg *arg) {
  unsigned int newtags;

  if (!selmon->sel)
    return;
  newtags = selmon->sel->tags ^ (arg->ui & TAGMASK);
  if (newtags) {
    selmon->sel->tags = newtags;
    focus(NULL);
    arrange(selmon);
  }
}

void toggleview(const Arg *arg) {
  unsigned int newtagset =
      selmon->tagset[selmon->seltags] ^ (arg->ui & TAGMASK);
  int i;

  if (newtagset) {
    selmon->tagset[selmon->seltags] = newtagset;

    if (newtagset == ~0) {
      selmon->pertag->prevtag = selmon->pertag->curtag;
      selmon->pertag->curtag = 0;
    }

    /* test if the user did not select the same tag */
    if (!(newtagset & 1 << (selmon->pertag->curtag - 1))) {
      selmon->pertag->prevtag = selmon->pertag->curtag;
      for (i = 0; !(newtagset & 1 << i); i++)
        ;
      selmon->pertag->curtag = i + 1;
    }

    /* apply settings for this view */
    selmon->nmaster = selmon->pertag->nmasters[selmon->pertag->curtag];
    selmon->mfact = selmon->pertag->mfacts[selmon->pertag->curtag];
    selmon->sellt = selmon->pertag->sellts[selmon->pertag->curtag];
    selmon->lt[selmon->sellt] =
        selmon->pertag->ltidxs[selmon->pertag->curtag][selmon->sellt];
    selmon->lt[selmon->sellt ^ 1] =
        selmon->pertag->ltidxs[selmon->pertag->curtag][selmon->sellt ^ 1];

    if (selmon->showbar != selmon->pertag->showbars[selmon->pertag->curtag])
      togglebar(NULL);

    focus(NULL);
    arrange(selmon);
  }
}

void unfocus(Client *c, int setfocus) {
  if (!c)
    return;
  grabbuttons(c, 0);
  XSetWindowBorder(dpy, c->win, scheme[SchemeNorm][ColBorder].pixel);
  if (setfocus) {
    XSetInputFocus(dpy, root, RevertToPointerRoot, CurrentTime);
    XDeleteProperty(dpy, root, netatom[NetActiveWindow]);
  }
}

void unmanage(Client *c, int destroyed) {
  Monitor *m = c->mon;
  XWindowChanges wc;

  detach(c);
  detachstack(c);
  if (!destroyed) {
    wc.border_width = c->oldbw;
    XGrabServer(dpy); /* avoid race conditions */
    XSetErrorHandler(xerrordummy);
    XConfigureWindow(dpy, c->win, CWBorderWidth, &wc); /* restore border */
    XUngrabButton(dpy, AnyButton, AnyModifier, c->win);
    setclientstate(c, WithdrawnState);
    XSync(dpy, False);
    XSetErrorHandler(xerror);
    XUngrabServer(dpy);
  }
  free(c);
  focus(NULL);
  updateclientlist();
  arrange(m);
}

void unmanagealtbar(Window w) {
  Monitor *m = wintomon(w);

  if (!m)
    return;

  m->barwin = 0;
  m->by = 0;
  m->bh = 0;
  updatebarpos(m);
  arrange(m);
}

void unmanagetray(Window w) {
  Monitor *m = wintomon(w);

  if (!m)
    return;

  m->traywin = 0;
  m->tx = 0;
  m->tw = 0;
  updatebarpos(m);
  arrange(m);
}

void unmapnotify(XEvent *e) {
  Client *c;
  Monitor *m;
  XUnmapEvent *ev = &e->xunmap;

  if ((c = wintoclient(ev->window))) {
    if (ev->send_event)
      setclientstate(c, WithdrawnState);
    else
      unmanage(c, 0);
  } else if ((m = wintomon(ev->window)) && m->barwin == ev->window)
    unmanagealtbar(ev->window);
  else if (m->traywin == ev->window)
    unmanagetray(ev->window);
}

void updatebars(void) {
  if (usealtbar)
    return;

  Monitor *m;
  XSetWindowAttributes wa = {.override_redirect = True,
                             .background_pixmap = ParentRelative,
                             .event_mask = ButtonPressMask | ExposureMask};
  XClassHint ch = {"dwm", "dwm"};
  for (m = mons; m; m = m->next) {
    if (m->barwin)
      continue;
    m->barwin = XCreateWindow(
        dpy, root, m->wx, m->by, m->ww, bh, 0, DefaultDepth(dpy, screen),
        CopyFromParent, DefaultVisual(dpy, screen),
        CWOverrideRedirect | CWBackPixmap | CWEventMask, &wa);
    XDefineCursor(dpy, m->barwin, cursor[CurNormal]->cursor);
    XMapRaised(dpy, m->barwin);
    m->tabwin = XCreateWindow(
        dpy, root, m->wx, m->ty, m->ww, th, 0, DefaultDepth(dpy, screen),
        CopyFromParent, DefaultVisual(dpy, screen),
        CWOverrideRedirect | CWBackPixmap | CWEventMask, &wa);
    XDefineCursor(dpy, m->tabwin, cursor[CurNormal]->cursor);
    XMapRaised(dpy, m->tabwin);
    XSetClassHint(dpy, m->barwin, &ch);
  }
}

void updatebarpos(Monitor *m) {
  Client *c;
  int nvis = 0;

  m->wy = m->my;
  m->wh = m->mh;
  if (m->showbar) {
    m->wh -= m->bh;
    m->by = m->topbar ? m->wy : m->wy + m->wh;
    if (m->topbar)
      m->wy += m->bh;
  } else {
    m->by = -m->bh;
  }

  for (c = m->clients; c; c = c->next) {
    if (ISVISIBLE(c))
      ++nvis;
  }

  if (m->showtab == showtab_always ||
      ((m->showtab == showtab_auto) && (nvis > 1) &&
       (m->lt[m->sellt]->arrange == monocle))) {
    m->wh -= th;
    m->ty = m->toptab ? m->wy : m->wy + m->wh;
    if (m->toptab)
      m->wy += th;
  } else {
    m->ty = -th;
  }
}

void updateclientlist() {
  Client *c;
  Monitor *m;

  XDeleteProperty(dpy, root, netatom[NetClientList]);
  for (m = mons; m; m = m->next)
    for (c = m->clients; c; c = c->next)
      XChangeProperty(dpy, root, netatom[NetClientList], XA_WINDOW, 32,
                      PropModeAppend, (unsigned char *)&(c->win), 1);
}

int updategeom(void) {
  int dirty = 0;

#ifdef XINERAMA
  if (XineramaIsActive(dpy)) {
    int i, j, n, nn;
    Client *c;
    Monitor *m;
    XineramaScreenInfo *info = XineramaQueryScreens(dpy, &nn);
    XineramaScreenInfo *unique = NULL;

    for (n = 0, m = mons; m; m = m->next, n++)
      ;
    /* only consider unique geometries as separate screens */
    unique = ecalloc(nn, sizeof(XineramaScreenInfo));
    for (i = 0, j = 0; i < nn; i++)
      if (isuniquegeom(unique, j, &info[i]))
        memcpy(&unique[j++], &info[i], sizeof(XineramaScreenInfo));
    XFree(info);
    nn = j;
    if (n <= nn) { /* new monitors available */
      for (i = 0; i < (nn - n); i++) {
        for (m = mons; m && m->next; m = m->next)
          ;
        if (m)
          m->next = createmon();
        else
          mons = createmon();
      }
      for (i = 0, m = mons; i < nn && m; m = m->next, i++)
        if (i >= n || unique[i].x_org != m->mx || unique[i].y_org != m->my ||
            unique[i].width != m->mw || unique[i].height != m->mh) {
          dirty = 1;
          m->num = i;
          m->mx = m->wx = unique[i].x_org;
          m->my = m->wy = unique[i].y_org;
          m->mw = m->ww = unique[i].width;
          m->mh = m->wh = unique[i].height;
          updatebarpos(m);
        }
    } else { /* less monitors available nn < n */
      for (i = nn; i < n; i++) {
        for (m = mons; m && m->next; m = m->next)
          ;
        while ((c = m->clients)) {
          dirty = 1;
          m->clients = c->next;
          detachstack(c);
          c->mon = mons;
          attach(c);
          attachBelow(c);
          attachstack(c);
        }
        if (m == selmon)
          selmon = mons;
        cleanupmon(m);
      }
    }
    free(unique);
  } else
#endif /* XINERAMA */
  {    /* default monitor setup */
    if (!mons)
      mons = createmon();
    if (mons->mw != sw || mons->mh != sh) {
      dirty = 1;
      mons->mw = mons->ww = sw;
      mons->mh = mons->wh = sh;
      updatebarpos(mons);
    }
  }
  if (dirty) {
    selmon = mons;
    selmon = wintomon(root);
  }
  return dirty;
}

void updatenumlockmask(void) {
  unsigned int i, j;
  XModifierKeymap *modmap;

  numlockmask = 0;
  modmap = XGetModifierMapping(dpy);
  for (i = 0; i < 8; i++)
    for (j = 0; j < modmap->max_keypermod; j++)
      if (modmap->modifiermap[i * modmap->max_keypermod + j] ==
          XKeysymToKeycode(dpy, XK_Num_Lock))
        numlockmask = (1 << i);
  XFreeModifiermap(modmap);
}

void updatesizehints(Client *c) {
  long msize;
  XSizeHints size;

  if (!XGetWMNormalHints(dpy, c->win, &size, &msize))
    /* size is uninitialized, ensure that size.flags aren't used */
    size.flags = PSize;
  if (size.flags & PBaseSize) {
    c->basew = size.base_width;
    c->baseh = size.base_height;
  } else if (size.flags & PMinSize) {
    c->basew = size.min_width;
    c->baseh = size.min_height;
  } else
    c->basew = c->baseh = 0;
  if (size.flags & PResizeInc) {
    c->incw = size.width_inc;
    c->inch = size.height_inc;
  } else
    c->incw = c->inch = 0;
  if (size.flags & PMaxSize) {
    c->maxw = size.max_width;
    c->maxh = size.max_height;
  } else
    c->maxw = c->maxh = 0;
  if (size.flags & PMinSize) {
    c->minw = size.min_width;
    c->minh = size.min_height;
  } else if (size.flags & PBaseSize) {
    c->minw = size.base_width;
    c->minh = size.base_height;
  } else
    c->minw = c->minh = 0;
  if (size.flags & PAspect) {
    c->mina = (float)size.min_aspect.y / size.min_aspect.x;
    c->maxa = (float)size.max_aspect.x / size.max_aspect.y;
  } else
    c->maxa = c->mina = 0.0;
  c->isfixed = (c->maxw && c->maxh && c->maxw == c->minw && c->maxh == c->minh);
}

void updatestatus(void) {
  if (!gettextprop(root, XA_WM_NAME, stext, sizeof(stext)))
    strcpy(stext, "dwm-" VERSION);
  drawbar(selmon);
}

void updatetitle(Client *c) {
  char oldname[sizeof(c->name)];
  strcpy(oldname, c->name);

  if (!gettextprop(c->win, netatom[NetWMName], c->name, sizeof c->name))
    gettextprop(c->win, XA_WM_NAME, c->name, sizeof c->name);
  if (c->name[0] == '\0') /* hack to mark broken clients */
    strcpy(c->name, broken);

  for (Monitor *m = mons; m; m = m->next) {
    if (m->sel == c && strcmp(oldname, c->name) != 0)
      ipc_focused_title_change_event(m->num, c->win, oldname, c->name);
  }
}

void updatewindowtype(Client *c) {
  Atom state = getatomprop(c, netatom[NetWMState]);
  Atom wtype = getatomprop(c, netatom[NetWMWindowType]);

  if (state == netatom[NetWMFullscreen])
    setfullscreen(c, 1);
  if (wtype == netatom[NetWMWindowTypeDialog])
    c->isfloating = 1;
}

void updatewmhints(Client *c) {
  XWMHints *wmh;

  if ((wmh = XGetWMHints(dpy, c->win))) {
    if (c == selmon->sel && wmh->flags & XUrgencyHint) {
      wmh->flags &= ~XUrgencyHint;
      XSetWMHints(dpy, c->win, wmh);
    } else
      c->isurgent = (wmh->flags & XUrgencyHint) ? 1 : 0;
    if (wmh->flags & InputHint)
      c->neverfocus = !wmh->input;
    else
      c->neverfocus = 0;
    XFree(wmh);
  }
}

void view(const Arg *arg) {
  int i;
  unsigned int tmptag;

  if ((arg->ui & TAGMASK) == selmon->tagset[selmon->seltags])
    return;
  selmon->seltags ^= 1; /* toggle sel tagset */
  if (arg->ui & TAGMASK) {
    selmon->tagset[selmon->seltags] = arg->ui & TAGMASK;
    selmon->pertag->prevtag = selmon->pertag->curtag;

    if (arg->ui == ~0)
      selmon->pertag->curtag = 0;
    else {
      for (i = 0; !(arg->ui & 1 << i); i++)
        ;
      selmon->pertag->curtag = i + 1;
    }
  } else {
    tmptag = selmon->pertag->prevtag;
    selmon->pertag->prevtag = selmon->pertag->curtag;
    selmon->pertag->curtag = tmptag;
  }

  selmon->nmaster = selmon->pertag->nmasters[selmon->pertag->curtag];
  selmon->mfact = selmon->pertag->mfacts[selmon->pertag->curtag];
  selmon->sellt = selmon->pertag->sellts[selmon->pertag->curtag];
  selmon->lt[selmon->sellt] =
      selmon->pertag->ltidxs[selmon->pertag->curtag][selmon->sellt];
  selmon->lt[selmon->sellt ^ 1] =
      selmon->pertag->ltidxs[selmon->pertag->curtag][selmon->sellt ^ 1];

  if (selmon->showbar != selmon->pertag->showbars[selmon->pertag->curtag])
    togglebar(NULL);

  focus(NULL);
  arrange(selmon);
}

Client *wintoclient(Window w) {
  Client *c;
  Monitor *m;

  for (m = mons; m; m = m->next)
    for (c = m->clients; c; c = c->next)
      if (c->win == w)
        return c;
  return NULL;
}

Monitor *wintomon(Window w) {
  int x, y;
  Client *c;
  Monitor *m;

  if (w == root && getrootptr(&x, &y))
    return recttomon(x, y, 1, 1);
  for (m = mons; m; m = m->next)
    if (w == m->barwin || w == m->tabwin || w == m->traywin)
      return m;
  if ((c = wintoclient(w)))
    return c->mon;
  return selmon;
}

int wmclasscontains(Window win, const char *class, const char *name) {
  XClassHint ch = {NULL, NULL};
  int res = 1;

  if (XGetClassHint(dpy, win, &ch)) {
    if (ch.res_name && strstr(ch.res_name, name) == NULL)
      res = 0;
    if (ch.res_class && strstr(ch.res_class, class) == NULL)
      res = 0;
  } else
    res = 0;

  if (ch.res_class)
    XFree(ch.res_class);
  if (ch.res_name)
    XFree(ch.res_name);

  return res;
}

/* There's no way to check accesses to destroyed windows, thus those cases are
 * ignored (especially on UnmapNotify's). Other types of errors call Xlibs
 * default error handler, which may call exit. */
int xerror(Display *dpy, XErrorEvent *ee) {
  if (ee->error_code == BadWindow ||
      (ee->request_code == X_SetInputFocus && ee->error_code == BadMatch) ||
      (ee->request_code == X_PolyText8 && ee->error_code == BadDrawable) ||
      (ee->request_code == X_PolyFillRectangle &&
       ee->error_code == BadDrawable) ||
      (ee->request_code == X_PolySegment && ee->error_code == BadDrawable) ||
      (ee->request_code == X_ConfigureWindow && ee->error_code == BadMatch) ||
      (ee->request_code == X_GrabButton && ee->error_code == BadAccess) ||
      (ee->request_code == X_GrabKey && ee->error_code == BadAccess) ||
      (ee->request_code == X_CopyArea && ee->error_code == BadDrawable))
    return 0;
  fprintf(stderr, "dwm: fatal error: request code=%d, error code=%d\n",
          ee->request_code, ee->error_code);
  return xerrorxlib(dpy, ee); /* may call exit */
}

int xerrordummy(Display *dpy, XErrorEvent *ee) { return 0; }

/* Startup Error handler to check if another window manager
 * is already running. */
int xerrorstart(Display *dpy, XErrorEvent *ee) {
  die("dwm: another window manager is already running");
  return -1;
}

void xrdb(const Arg *arg) {
  loadxrdb();
  int i;
  for (i = 0; i < LENGTH(colors); i++)
    scheme[i] = drw_scm_create(drw, colors[i], 3);
  focus(NULL);
  arrange(NULL);
}

void zoom(const Arg *arg) {
  Client *c = selmon->sel;

  if (!selmon->lt[selmon->sellt]->arrange ||
      (selmon->sel && selmon->sel->isfloating))
    return;
  if (c == nexttiled(selmon->clients))
    if (!c || !(c = nexttiled(c->next)))
      return;
  pop(c);
}

int main(int argc, char *argv[]) {
  if (argc == 2 && !strcmp("-v", argv[1]))
    die("dwm-" VERSION);
  else if (argc != 1)
    die("usage: dwm [-v]");
  if (!setlocale(LC_CTYPE, "") || !XSupportsLocale())
    fputs("warning: no locale support\n", stderr);
  if (!(dpy = XOpenDisplay(NULL)))
    die("dwm: cannot open display");
  compileregexes();
  checkotherwm();
  XrmInitialize();
  loadxrdb();
  setup();
#ifdef __OpenBSD__
  if (pledge("stdio rpath proc exec", NULL) == -1)
    die("pledge");
#endif /* __OpenBSD__ */
  scan();
  runautostart();
  run();
  if (restart)
    execvp(argv[0], argv);
  cleanup();
  XCloseDisplay(dpy);
  return EXIT_SUCCESS;
}

void focusmaster(const Arg *arg) {
  Client *c;

  if (selmon->nmaster < 1)
    return;

  c = nexttiled(selmon->clients);

  if (c)
    focus(c);
}

static void bstack(Monitor *m) {
  int w, h, mh, mx, tx, ty, tw;
  unsigned int i, n;
  Client *c;

  for (n = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), n++)
    ;
  if (n == 0)
    return;
  if (n > m->nmaster) {
    mh = m->nmaster ? m->mfact * m->wh : 0;
    tw = m->ww / (n - m->nmaster);
    ty = m->wy + mh;
  } else {
    mh = m->wh;
    tw = m->ww;
    ty = m->wy;
  }
  for (i = mx = 0, tx = m->wx, c = nexttiled(m->clients); c;
       c = nexttiled(c->next), i++) {
    if (i < m->nmaster) {
      w = (m->ww - mx) / (MIN(n, m->nmaster) - i);
      resize(c, m->wx + mx, m->wy, w - (2 * c->bw), mh - (2 * c->bw), 0);
      mx += WIDTH(c);
    } else {
      h = m->wh - mh;
      resize(c, tx, ty, tw - (2 * c->bw), h - (2 * c->bw), 0);
      if (tw != m->ww)
        tx += WIDTH(c);
    }
  }
}

static void bstackhoriz(Monitor *m) {
  int w, mh, mx, tx, ty, th;
  unsigned int i, n;
  Client *c;

  for (n = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), n++)
    ;
  if (n == 0)
    return;
  if (n > m->nmaster) {
    mh = m->nmaster ? m->mfact * m->wh : 0;
    th = (m->wh - mh) / (n - m->nmaster);
    ty = m->wy + mh;
  } else {
    th = mh = m->wh;
    ty = m->wy;
  }
  for (i = mx = 0, tx = m->wx, c = nexttiled(m->clients); c;
       c = nexttiled(c->next), i++) {
    if (i < m->nmaster) {
      w = (m->ww - mx) / (MIN(n, m->nmaster) - i);
      resize(c, m->wx + mx, m->wy, w - (2 * c->bw), mh - (2 * c->bw), 0);
      mx += WIDTH(c);
    } else {
      resize(c, tx, ty, m->ww - (2 * c->bw), th - (2 * c->bw), 0);
      if (th != m->wh)
        ty += HEIGHT(c);
    }
  }
}
