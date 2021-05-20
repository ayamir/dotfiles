/* See LICENSE file for copyright and license details. */
#include <ctype.h>
#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <time.h>
#include <unistd.h>

#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <X11/Xutil.h>
#ifdef XINERAMA
#include <X11/extensions/Xinerama.h>
#endif
#include <X11/Xft/Xft.h>

#include "patches.h"
/* Patch incompatibility overrides */
#if MULTI_SELECTION_PATCH
#undef NON_BLOCKING_STDIN_PATCH
#undef PIPEOUT_PATCH
#undef JSON_PATCH
#undef PRINTINPUTTEXT_PATCH
#endif // MULTI_SELECTION_PATCH
#if JSON_PATCH
#undef NON_BLOCKING_STDIN_PATCH
#undef PRINTINPUTTEXT_PATCH
#undef PIPEOUT_PATCH
#endif // JSON_PATCH

#include "drw.h"
#include "util.h"
#if JSON_PATCH
#include <jansson.h>
#endif // JSON_PATCH

/* macros */
#define INTERSECT(x,y,w,h,r)  (MAX(0, MIN((x)+(w),(r).x_org+(r).width)  - MAX((x),(r).x_org)) \
                             * MAX(0, MIN((y)+(h),(r).y_org+(r).height) - MAX((y),(r).y_org)))
#define LENGTH(X)             (sizeof X / sizeof X[0])
#if PANGO_PATCH
#define TEXTW(X)              (drw_font_getwidth(drw, (X), False) + lrpad)
#define TEXTWM(X)             (drw_font_getwidth(drw, (X), True) + lrpad)
#else
#define TEXTW(X)              (drw_fontset_getwidth(drw, (X)) + lrpad)
#endif // PANGO_PATCH
#if ALPHA_PATCH
#define OPAQUE                0xffU
#define OPACITY               "_NET_WM_WINDOW_OPACITY"
#endif // ALPHA_PATCH

/* enums */
enum {
	SchemeNorm,
	SchemeSel,
	SchemeOut,
	#if MORECOLOR_PATCH
	SchemeMid,
	#endif // MORECOLOR_PATCH
	#if HIGHLIGHT_PATCH || FUZZYHIGHLIGHT_PATCH
	SchemeNormHighlight,
	SchemeSelHighlight,
	#endif // HIGHLIGHT_PATCH || FUZZYHIGHLIGHT_PATCH
	#if HIGHPRIORITY_PATCH
	SchemeHp,
	#endif // HIGHPRIORITY_PATCH
	SchemeLast,
}; /* color schemes */

struct item {
	char *text;
	struct item *left, *right;
	#if NON_BLOCKING_STDIN_PATCH
	struct item *next;
	#endif // NON_BLOCKING_STDIN_PATCH
	#if MULTI_SELECTION_PATCH
	int id; /* for multiselect */
	#else
	int out;
	#endif // MULTI_SELECTION_PATCH
	#if HIGHPRIORITY_PATCH
	int hp;
	#endif // HIGHPRIORITY_PATCH
	#if JSON_PATCH
	json_t *json;
	#endif // JSON_PATCH
	#if FUZZYMATCH_PATCH
	double distance;
	#endif // FUZZYMATCH_PATCH
};

static char text[BUFSIZ] = "";
#if PIPEOUT_PATCH
static char pipeout[8] = " | dmenu";
#endif // PIPEOUT_PATCH
static char *embed;
static int bh, mw, mh;
#if XYW_PATCH
static int dmx = 0, dmy = 0; /* put dmenu at these x and y offsets */
static unsigned int dmw = 0; /* make dmenu this wide */
#endif // XYW_PATCH
static int inputw = 0, promptw;
#if PASSWORD_PATCH
static int passwd = 0;
#endif // PASSWORD_PATCH
static int lrpad; /* sum of left and right padding */
#if REJECTNOMATCH_PATCH
static int reject_no_match = 0;
#endif // REJECTNOMATCH_PATCH
static size_t cursor;
static struct item *items = NULL;
static struct item *matches, *matchend;
static struct item *prev, *curr, *next, *sel;
static int mon = -1, screen;
#if MANAGED_PATCH
static int managed = 0;
#endif // MANAGED_PATCH
#if MULTI_SELECTION_PATCH
static int *selid = NULL;
static unsigned int selidsize = 0;
#endif // MULTI_SELECTION_PATCH
#if PRINTINPUTTEXT_PATCH
static int use_text_input = 0;
#endif // PRINTINPUTTEXT_PATCH
#if PRESELECT_PATCH
static unsigned int preselected = 0;
#endif // PRESELECT_PATCH

static Atom clip, utf8;
#if WMTYPE_PATCH
static Atom type, dock;
#endif // WMTYPE_PATCH
static Display *dpy;
static Window root, parentwin, win;
static XIC xic;

#if ALPHA_PATCH
static int useargb = 0;
static Visual *visual;
static int depth;
static Colormap cmap;
#endif // ALPHA_PATCH

static Drw *drw;
static Clr *scheme[SchemeLast];

#include "patch/include.h"

#include "config.h"

#if CASEINSENSITIVE_PATCH
static char * cistrstr(const char *s, const char *sub);
static int (*fstrncmp)(const char *, const char *, size_t) = strncasecmp;
static char *(*fstrstr)(const char *, const char *) = cistrstr;
#else
static int (*fstrncmp)(const char *, const char *, size_t) = strncmp;
static char *(*fstrstr)(const char *, const char *) = strstr;
#endif // CASEINSENSITIVE_PATCH

static void appenditem(struct item *item, struct item **list, struct item **last);
static void calcoffsets(void);
static void cleanup(void);
static char * cistrstr(const char *s, const char *sub);
static int drawitem(struct item *item, int x, int y, int w);
static void drawmenu(void);
static void grabfocus(void);
static void grabkeyboard(void);
static void match(void);
static void insert(const char *str, ssize_t n);
static size_t nextrune(int inc);
static void movewordedge(int dir);
static void keypress(XKeyEvent *ev);
static void paste(void);
#if ALPHA_PATCH
static void xinitvisual(void);
#endif // ALPHA_PATCH
static void readstdin(void);
static void run(void);
static void setup(void);
static void usage(void);

#include "patch/include.c"

static void
appenditem(struct item *item, struct item **list, struct item **last)
{
	if (*last)
		(*last)->right = item;
	else
		*list = item;

	item->left = *last;
	item->right = NULL;
	*last = item;
}

static void
calcoffsets(void)
{
	int i, n;

	if (lines > 0)
		#if GRID_PATCH
		if (columns)
			n = lines * columns * bh;
		else
			n = lines * bh;
		#else
		n = lines * bh;
		#endif // GRID_PATCH
	else
		#if SYMBOLS_PATCH
		n = mw - (promptw + inputw + TEXTW(symbol_1) + TEXTW(symbol_2));
		#else
		n = mw - (promptw + inputw + TEXTW("<") + TEXTW(">"));
		#endif // SYMBOLS_PATCH
	/* calculate which items will begin the next page and previous page */
	for (i = 0, next = curr; next; next = next->right)
		#if PANGO_PATCH
		if ((i += (lines > 0) ? bh : MIN(TEXTWM(next->text), n)) > n)
		#else
		if ((i += (lines > 0) ? bh : MIN(TEXTW(next->text), n)) > n)
		#endif // PANGO_PATCH
			break;
	for (i = 0, prev = curr; prev && prev->left; prev = prev->left)
		#if PANGO_PATCH
		if ((i += (lines > 0) ? bh : MIN(TEXTWM(prev->left->text), n)) > n)
		#else
		if ((i += (lines > 0) ? bh : MIN(TEXTW(prev->left->text), n)) > n)
		#endif // PANGO_PATCH
			break;
}

static void
cleanup(void)
{
	size_t i;

	XUngrabKey(dpy, AnyKey, AnyModifier, root);
	for (i = 0; i < SchemeLast; i++)
		free(scheme[i]);
	drw_free(drw);
	XSync(dpy, False);
	XCloseDisplay(dpy);
	#if MULTI_SELECTION_PATCH
	free(selid);
	#endif // MULTI_SELECTION_PATCH
}

static char *
cistrstr(const char *s, const char *sub)
{
	size_t len;

	for (len = strlen(sub); *s; s++)
		if (!strncasecmp(s, sub, len))
			return (char *)s;
	return NULL;
}

static int
drawitem(struct item *item, int x, int y, int w)
{
	int r;
	if (item == sel)
		drw_setscheme(drw, scheme[SchemeSel]);
	#if HIGHPRIORITY_PATCH
	else if (item->hp)
		drw_setscheme(drw, scheme[SchemeHp]);
	#endif // HIGHPRIORITY_PATCH
	#if MORECOLOR_PATCH
	else if (item->left == sel || item->right == sel)
		drw_setscheme(drw, scheme[SchemeMid]);
	#endif // MORECOLOR_PATCH
	#if MULTI_SELECTION_PATCH
	else if (issel(item->id))
	#else
	else if (item->out)
	#endif // MULTI_SELECTION_PATCH
		drw_setscheme(drw, scheme[SchemeOut]);
	else
		drw_setscheme(drw, scheme[SchemeNorm]);

	#if PANGO_PATCH
	r = drw_text(drw, x, y, w, bh, lrpad / 2, item->text, 0, True);
	#else
	r = drw_text(drw, x, y, w, bh, lrpad / 2, item->text, 0);
	#endif // PANGO_PATCH
	#if HIGHLIGHT_PATCH || FUZZYHIGHLIGHT_PATCH
	drawhighlights(item, x, y, w);
	#endif // HIGHLIGHT_PATCH | FUZZYHIGHLIGHT_PATCH
	return r;
}

static void
drawmenu(void)
{
	#if SCROLL_PATCH
	static int curpos, oldcurlen;
	int curlen, rcurlen;
	#else
	unsigned int curpos;
	#endif // SCROLL_PATCH
	struct item *item;
	int x = 0, y = 0, w, rpad = 0;
	#if LINE_HEIGHT_PATCH && PANGO_PATCH
	int fh = drw->font->h;
	#elif LINE_HEIGHT_PATCH
	int fh = drw->fonts->h;
	#endif // LINE_HEIGHT_PATCH
	#if PASSWORD_PATCH
	char *censort;
	#endif // PASSWORD_PATCH

	drw_setscheme(drw, scheme[SchemeNorm]);
	drw_rect(drw, 0, 0, mw, mh, 1, 1);

	if (prompt && *prompt) {
		drw_setscheme(drw, scheme[SchemeSel]);
		#if PANGO_PATCH
		x = drw_text(drw, x, 0, promptw, bh, lrpad / 2, prompt, 0, True);
		#else
		x = drw_text(drw, x, 0, promptw, bh, lrpad / 2, prompt, 0);
		#endif // PANGO_PATCH
	}
	/* draw input field */
	w = (lines > 0 || !matches) ? mw - x : inputw;

	#if SCROLL_PATCH
	w -= lrpad / 2;
	x += lrpad / 2;
	rcurlen = drw_fontset_getwidth(drw, text + cursor);
	curlen = drw_fontset_getwidth(drw, text) - rcurlen;
	curpos += curlen - oldcurlen;
	curpos = MIN(w, MAX(0, curpos));
	curpos = MAX(curpos, w - rcurlen);
	curpos = MIN(curpos, curlen);
	oldcurlen = curlen;

	drw_setscheme(drw, scheme[SchemeNorm]);
	#if PASSWORD_PATCH
	if (passwd) {
		censort = ecalloc(1, sizeof(text));
		memset(censort, '.', strlen(text));
		drw_text_align(drw, x, 0, curpos, bh, censort, cursor, AlignR);
		drw_text_align(drw, x + curpos, 0, w - curpos, bh, censort + cursor, strlen(censort) - cursor, AlignL);
		free(censort);
	} else {
		drw_text_align(drw, x, 0, curpos, bh, text, cursor, AlignR);
		drw_text_align(drw, x + curpos, 0, w - curpos, bh, text + cursor, strlen(text) - cursor, AlignL);
	}
	#else
	drw_text_align(drw, x, 0, curpos, bh, text, cursor, AlignR);
	drw_text_align(drw, x + curpos, 0, w - curpos, bh, text + cursor, strlen(text) - cursor, AlignL);
	#endif // PASSWORD_PATCH
	#if LINE_HEIGHT_PATCH
	drw_rect(drw, x + curpos - 1, 2 + (bh-fh)/2, 2, fh - 4, 1, 0);
	#else
	drw_rect(drw, x + curpos - 1, 2, 2, bh - 4, 1, 0);
	#endif // LINE_HEIGHT_PATCH
	#else // !SCROLL_PATCH
	drw_setscheme(drw, scheme[SchemeNorm]);
	#if PASSWORD_PATCH
	if (passwd) {
		censort = ecalloc(1, sizeof(text));
		memset(censort, '.', strlen(text));
		#if PANGO_PATCH
		drw_text(drw, x, 0, w, bh, lrpad / 2, censort, 0, False);
		#else
		drw_text(drw, x, 0, w, bh, lrpad / 2, censort, 0);
		#endif // PANGO_PATCH
		free(censort);
	} else
		#if PANGO_PATCH
		drw_text(drw, x, 0, w, bh, lrpad / 2, text, 0, False);
		#else
		drw_text(drw, x, 0, w, bh, lrpad / 2, text, 0);
		#endif // PANGO_PATCH
	#elif PANGO_PATCH
	drw_text(drw, x, 0, w, bh, lrpad / 2, text, 0, False);
	#else
	drw_text(drw, x, 0, w, bh, lrpad / 2, text, 0);
	#endif // PASSWORD_PATCH

	curpos = TEXTW(text) - TEXTW(&text[cursor]);
	if ((curpos += lrpad / 2 - 1) < w) {
		drw_setscheme(drw, scheme[SchemeNorm]);
		#if LINE_HEIGHT_PATCH
		drw_rect(drw, x + curpos, 2 + (bh-fh)/2, 2, fh - 4, 1, 0);
		#else
		drw_rect(drw, x + curpos, 2, 2, bh - 4, 1, 0);
		#endif // LINE_HEIGHT_PATCH
	}
	#endif // SCROLL_PATCH

	#if NUMBERS_PATCH
	recalculatenumbers();
	rpad = TEXTW(numbers);
	#endif // NUMBERS_PATCH
	if (lines > 0) {
		#if GRID_PATCH
		/* draw grid */
		int i = 0;
		for (item = curr; item != next; item = item->right, i++)
			if (columns)
				#if VERTFULL_PATCH
				drawitem(
					item,
					0 + ((i / lines) *  (mw / columns)),
					y + (((i % lines) + 1) * bh),
					mw / columns
				);
				#else
				drawitem(
					item,
					x + ((i / lines) *  ((mw - x) / columns)),
					y + (((i % lines) + 1) * bh),
					(mw - x) / columns
				);
				#endif // VERTFULL_PATCH
			else
				#if VERTFULL_PATCH
				drawitem(item, 0, y += bh, mw);
				#else
				drawitem(item, x, y += bh, mw - x);
				#endif // VERTFULL_PATCH
		#else
		/* draw vertical list */
		for (item = curr; item != next; item = item->right)
			#if VERTFULL_PATCH
			drawitem(item, 0, y += bh, mw);
			#else
			drawitem(item, x, y += bh, mw - x);
			#endif // VERTFULL_PATCH
		#endif // GRID_PATCH
	} else if (matches) {
		/* draw horizontal list */
		x += inputw;
		w = TEXTW("<");
		if (curr->left) {
			drw_setscheme(drw, scheme[SchemeNorm]);
			#if PANGO_PATCH
			drw_text(drw, x, 0, w, bh, lrpad / 2, "<", 0, True);
			#else
			drw_text(drw, x, 0, w, bh, lrpad / 2, "<", 0);
			#endif // PANGO_PATCH
		}
		x += w;
		for (item = curr; item != next; item = item->right)
			#if PANGO_PATCH && SYMBOLS_PATCH
			x = drawitem(item, x, 0, MIN(TEXTWM(item->text), mw - x - TEXTW(symbol_2) - rpad));
			#elif PANGO_PATCH
			x = drawitem(item, x, 0, MIN(TEXTWM(item->text), mw - x - TEXTW(">") - rpad));
			#elif SYMBOLS_PATCH
			x = drawitem(item, x, 0, MIN(TEXTW(item->text), mw - x - TEXTW(symbol_2) - rpad));
			#else
			x = drawitem(item, x, 0, MIN(TEXTW(item->text), mw - x - TEXTW(">") - rpad));
			#endif // PANGO_PATCH
		if (next) {
			#if SYMBOLS_PATCH
			w = TEXTW(symbol_2);
			#else
			w = TEXTW(">");
			#endif // SYMBOLS_PATCH
			drw_setscheme(drw, scheme[SchemeNorm]);
			#if PANGO_PATCH && SYMBOLS_PATCH
			drw_text(drw, mw - w - rpad, 0, w, bh, lrpad / 2, symbol_2, 0, True);
			#elif PANGO_PATCH
			drw_text(drw, mw - w - rpad, 0, w, bh, lrpad / 2, ">", 0, True);
			#elif SYMBOLS_PATCH
			drw_text(drw, mw - w, 0, w, bh, lrpad / 2, symbol_2, 0);
			#else
			drw_text(drw, mw - w - rpad, 0, w, bh, lrpad / 2, ">", 0);
			#endif // PANGO_PATCH
		}
	}
	#if NUMBERS_PATCH
	drw_setscheme(drw, scheme[SchemeNorm]);
	drw_text(drw, mw - TEXTW(numbers), 0, TEXTW(numbers), bh, lrpad / 2, numbers, 0);
	#else
	#endif // NUMBERS_PATCH
	drw_map(drw, win, 0, 0, mw, mh);
	#if NON_BLOCKING_STDIN_PATCH
	XFlush(dpy);
	#endif // NON_BLOCKING_STDIN_PATCH
}

static void
grabfocus(void)
{
	struct timespec ts = { .tv_sec = 0, .tv_nsec = 10000000  };
	Window focuswin;
	int i, revertwin;

	for (i = 0; i < 100; ++i) {
		XGetInputFocus(dpy, &focuswin, &revertwin);
		if (focuswin == win)
			return;
		#if !MANAGED_PATCH
		XSetInputFocus(dpy, win, RevertToParent, CurrentTime);
		#endif // MANAGED_PATCH
		nanosleep(&ts, NULL);
	}
	die("cannot grab focus");
}

static void
grabkeyboard(void)
{
	struct timespec ts = { .tv_sec = 0, .tv_nsec = 1000000  };
	int i;

	#if MANAGED_PATCH
	if (embed || managed)
	#else
	if (embed)
	#endif // MANAGED_PATCH
		return;
	/* try to grab keyboard, we may have to wait for another process to ungrab */
	for (i = 0; i < 1000; i++) {
		if (XGrabKeyboard(dpy, DefaultRootWindow(dpy), True, GrabModeAsync,
		                  GrabModeAsync, CurrentTime) == GrabSuccess)
			return;
		nanosleep(&ts, NULL);
	}
	die("cannot grab keyboard");
}

static void
match(void)
{
	#if DYNAMIC_OPTIONS_PATCH
	if (dynamic && *dynamic)
		refreshoptions();
	#endif // DYNAMIC_OPTIONS_PATCH

	#if FUZZYMATCH_PATCH
	if (fuzzy) {
		fuzzymatch();
		return;
	}
	#endif
	static char **tokv = NULL;
	static int tokn = 0;

	char buf[sizeof text], *s;
	int i, tokc = 0;
	size_t len, textsize;
	struct item *item, *lprefix, *lsubstr, *prefixend, *substrend;
	#if HIGHPRIORITY_PATCH
	struct item *lhpprefix, *hpprefixend;
	#endif // HIGHPRIORITY_PATCH
	#if NON_BLOCKING_STDIN_PATCH
	int preserve = 0;
	#endif // NON_BLOCKING_STDIN_PATCH
	#if JSON_PATCH
	if (json)
		fstrstr = strcasestr;
	#endif // JSON_PATCH

	strcpy(buf, text);
	/* separate input text into tokens to be matched individually */
	for (s = strtok(buf, " "); s; tokv[tokc - 1] = s, s = strtok(NULL, " "))
		if (++tokc > tokn && !(tokv = realloc(tokv, ++tokn * sizeof *tokv)))
			die("cannot realloc %u bytes:", tokn * sizeof *tokv);
	len = tokc ? strlen(tokv[0]) : 0;

	#if PREFIXCOMPLETION_PATCH
	if (use_prefix) {
		matches = lprefix = matchend = prefixend = NULL;
		textsize = strlen(text);
	} else {
		matches = lprefix = lsubstr = matchend = prefixend = substrend = NULL;
		textsize = strlen(text) + 1;
	}
	#else
	matches = lprefix = lsubstr = matchend = prefixend = substrend = NULL;
	textsize = strlen(text) + 1;
	#endif // PREFIXCOMPLETION_PATCH
	#if HIGHPRIORITY_PATCH
	lhpprefix = hpprefixend = NULL;
	#endif // HIGHPRIORITY_PATCH
	#if NON_BLOCKING_STDIN_PATCH && DYNAMIC_OPTIONS_PATCH
	for (item = items; item && (!(dynamic && *dynamic) || item->text); item = (dynamic && *dynamic) ? item + 1 : item->next)
	#elif NON_BLOCKING_STDIN_PATCH
	for (item = items; item; item = item->next)
	#else
	for (item = items; item && item->text; item++)
	#endif
	{
		for (i = 0; i < tokc; i++)
			if (!fstrstr(item->text, tokv[i]))
				break;
		#if DYNAMIC_OPTIONS_PATCH
		if (i != tokc && !(dynamic && *dynamic)) /* not all tokens match */
			continue;
		#else
		if (i != tokc) /* not all tokens match */
			continue;
		#endif // DYNAMIC_OPTIONS_PATCH
		#if HIGHPRIORITY_PATCH
		/* exact matches go first, then prefixes with high priority, then prefixes, then substrings */
		#else
		/* exact matches go first, then prefixes, then substrings */
		#endif // HIGHPRIORITY_PATCH
		if (!tokc || !fstrncmp(text, item->text, textsize))
			appenditem(item, &matches, &matchend);
		#if HIGHPRIORITY_PATCH
		else if (item->hp && !fstrncmp(tokv[0], item->text, len))
			appenditem(item, &lhpprefix, &hpprefixend);
		#endif // HIGHPRIORITY_PATCH
		else if (!fstrncmp(tokv[0], item->text, len))
			appenditem(item, &lprefix, &prefixend);
		#if PREFIXCOMPLETION_PATCH
		else if (!use_prefix)
		#else
		else
		#endif // PREFIXCOMPLETION_PATCH
			appenditem(item, &lsubstr, &substrend);
		#if NON_BLOCKING_STDIN_PATCH
		if (sel == item)
			preserve = 1;
		#endif // NON_BLOCKING_STDIN_PATCH
	}
	#if HIGHPRIORITY_PATCH
	if (lhpprefix) {
		if (matches) {
			matchend->right = lhpprefix;
			lhpprefix->left = matchend;
		} else
			matches = lhpprefix;
		matchend = hpprefixend;
	}
	#endif // HIGHPRIORITY_PATCH
	if (lprefix) {
		if (matches) {
			matchend->right = lprefix;
			lprefix->left = matchend;
		} else
			matches = lprefix;
		matchend = prefixend;
	}
	#if PREFIXCOMPLETION_PATCH
	if (!use_prefix && lsubstr)
	#else
	if (lsubstr)
	#endif // PREFIXCOMPLETION_PATCH
	{
		if (matches) {
			matchend->right = lsubstr;
			lsubstr->left = matchend;
		} else
			matches = lsubstr;
		matchend = substrend;
	}
	#if NON_BLOCKING_STDIN_PATCH
	if (!preserve)
	#endif // NON_BLOCKING_STDIN_PATCH
	curr = sel = matches;

	#if INSTANT_PATCH
	if (instant && matches && matches==matchend && !lsubstr) {
		puts(matches->text);
		cleanup();
		exit(0);
	}
	#endif // INSTANT_PATCH

	calcoffsets();
}

static void
insert(const char *str, ssize_t n)
{
	if (strlen(text) + n > sizeof text - 1)
		return;

	#if REJECTNOMATCH_PATCH
	static char last[BUFSIZ] = "";
	if (reject_no_match) {
		/* store last text value in case we need to revert it */
		memcpy(last, text, BUFSIZ);
	}
	#endif // REJECTNOMATCH_PATCH

	/* move existing text out of the way, insert new text, and update cursor */
	memmove(&text[cursor + n], &text[cursor], sizeof text - cursor - MAX(n, 0));
	if (n > 0)
		memcpy(&text[cursor], str, n);
	cursor += n;
	match();

	#if REJECTNOMATCH_PATCH
	if (!matches && reject_no_match) {
		/* revert to last text value if theres no match */
		memcpy(text, last, BUFSIZ);
		cursor -= n;
		match();
	}
	#endif // REJECTNOMATCH_PATCH
}

static size_t
nextrune(int inc)
{
	ssize_t n;

	/* return location of next utf8 rune in the given direction (+1 or -1) */
	for (n = cursor + inc; n + inc >= 0 && (text[n] & 0xc0) == 0x80; n += inc)
		;
	return n;
}

static void
movewordedge(int dir)
{
	if (dir < 0) { /* move cursor to the start of the word*/
		while (cursor > 0 && strchr(worddelimiters, text[nextrune(-1)]))
			cursor = nextrune(-1);
		while (cursor > 0 && !strchr(worddelimiters, text[nextrune(-1)]))
			cursor = nextrune(-1);
	} else { /* move cursor to the end of the word */
		while (text[cursor] && strchr(worddelimiters, text[cursor]))
			cursor = nextrune(+1);
		while (text[cursor] && !strchr(worddelimiters, text[cursor]))
			cursor = nextrune(+1);
	}
}

static void
keypress(XKeyEvent *ev)
{
	char buf[32];
	int len;
	#if PREFIXCOMPLETION_PATCH
	struct item * item;
	#endif // PREFIXCOMPLETION_PATCH
	KeySym ksym;
	Status status;

	len = XmbLookupString(xic, ev, buf, sizeof buf, &ksym, &status);
	switch (status) {
	default: /* XLookupNone, XBufferOverflow */
		return;
	case XLookupChars:
		goto insert;
	case XLookupKeySym:
	case XLookupBoth:
		break;
	}

	if (ev->state & ControlMask) {
		switch(ksym) {
		case XK_a: ksym = XK_Home;      break;
		case XK_b: ksym = XK_Left;      break;
		case XK_c: ksym = XK_Escape;    break;
		case XK_d: ksym = XK_Delete;    break;
		case XK_e: ksym = XK_End;       break;
		case XK_f: ksym = XK_Right;     break;
		case XK_g: ksym = XK_Escape;    break;
		case XK_h: ksym = XK_BackSpace; break;
		case XK_i: ksym = XK_Tab;       break;
		case XK_j: /* fallthrough */
		case XK_J: /* fallthrough */
		case XK_m: /* fallthrough */
		case XK_M: ksym = XK_Return; ev->state &= ~ControlMask; break;
		case XK_n: ksym = XK_Down;      break;
		case XK_p: ksym = XK_Up;        break;

		case XK_k: /* delete right */
			text[cursor] = '\0';
			match();
			break;
		case XK_u: /* delete left */
			insert(NULL, 0 - cursor);
			break;
		case XK_w: /* delete word */
			while (cursor > 0 && strchr(worddelimiters, text[nextrune(-1)]))
				insert(NULL, nextrune(-1) - cursor);
			while (cursor > 0 && !strchr(worddelimiters, text[nextrune(-1)]))
				insert(NULL, nextrune(-1) - cursor);
			break;
		case XK_y: /* paste selection */
		case XK_Y:
			XConvertSelection(dpy, (ev->state & ShiftMask) ? clip : XA_PRIMARY,
			                  utf8, utf8, win, CurrentTime);
			return;
		case XK_Left:
			movewordedge(-1);
			goto draw;
		case XK_Right:
			movewordedge(+1);
			goto draw;
		case XK_Return:
		case XK_KP_Enter:
			#if MULTI_SELECTION_PATCH
			selsel();
			#endif // MULTI_SELECTION_PATCH
			break;
		case XK_bracketleft:
			cleanup();
			exit(1);
		default:
			return;
		}
	} else if (ev->state & Mod1Mask) {
		switch(ksym) {
		case XK_b:
			movewordedge(-1);
			goto draw;
		case XK_f:
			movewordedge(+1);
			goto draw;
		case XK_g: ksym = XK_Home;  break;
		case XK_G: ksym = XK_End;   break;
		case XK_h: ksym = XK_Up;    break;
		case XK_j: ksym = XK_Next;  break;
		case XK_k: ksym = XK_Prior; break;
		case XK_l: ksym = XK_Down;  break;
		#if NAVHISTORY_PATCH
		case XK_p: navhistory(-1); buf[0]=0; break;
		case XK_n: navhistory(1); buf[0]=0; break;
		#endif // NAVHISTORY_PATCH
		default:
			return;
		}
	}

	switch(ksym) {
	default:
insert:
		if (!iscntrl(*buf))
			insert(buf, len);
		break;
	case XK_Delete:
		if (text[cursor] == '\0')
			return;
		cursor = nextrune(+1);
		/* fallthrough */
	case XK_BackSpace:
		if (cursor == 0)
			return;
		insert(NULL, nextrune(-1) - cursor);
		break;
	case XK_End:
		if (text[cursor] != '\0') {
			cursor = strlen(text);
			break;
		}
		if (next) {
			/* jump to end of list and position items in reverse */
			curr = matchend;
			calcoffsets();
			curr = prev;
			calcoffsets();
			while (next && (curr = curr->right))
				calcoffsets();
		}
		sel = matchend;
		break;
	case XK_Escape:
		cleanup();
		exit(1);
	case XK_Home:
		if (sel == matches) {
			cursor = 0;
			break;
		}
		sel = curr = matches;
		calcoffsets();
		break;
	case XK_Left:
		if (cursor > 0 && (!sel || !sel->left || lines > 0)) {
			cursor = nextrune(-1);
			break;
		}
		if (lines > 0)
			return;
		/* fallthrough */
	case XK_Up:
		if (sel && sel->left && (sel = sel->left)->right == curr) {
			curr = prev;
			calcoffsets();
		}
		break;
	case XK_Next:
		if (!next)
			return;
		sel = curr = next;
		calcoffsets();
		break;
	case XK_Prior:
		if (!prev)
			return;
		sel = curr = prev;
		calcoffsets();
		break;
	case XK_Return:
	case XK_KP_Enter:
		#if !MULTI_SELECTION_PATCH
		#if JSON_PATCH
		if (!printjsonssel(ev->state))
			break;
		#elif PIPEOUT_PATCH
		#if PRINTINPUTTEXT_PATCH
		if (sel && (
			(use_text_input && (ev->state & ShiftMask)) ||
			(!use_text_input && !(ev->state & ShiftMask))
		))
		#else
		if (sel && !(ev->state & ShiftMask))
		#endif // PRINTINPUTTEXT_PATCH
		{
			if (sel->text[0] == startpipe[0]) {
				strncpy(sel->text + strlen(sel->text),pipeout,8);
				puts(sel->text+1);
			}
			puts(sel->text);
		} else {
			if (text[0] == startpipe[0]) {
				strncpy(text + strlen(text),pipeout,8);
				puts(text+1);
			}
			puts(text);
		}
		#elif PRINTINPUTTEXT_PATCH
		if (use_text_input)
			puts((sel && (ev->state & ShiftMask)) ? sel->text : text);
		else
			puts((sel && !(ev->state & ShiftMask)) ? sel->text : text);
		#else
		puts((sel && !(ev->state & ShiftMask)) ? sel->text : text);
		#endif // PIPEOUT_PATCH
		#endif // MULTI_SELECTION_PATCH
		if (!(ev->state & ControlMask)) {
			#if NAVHISTORY_PATCH
			savehistory((sel && !(ev->state & ShiftMask))
				    ? sel->text : text);
			#endif // NAVHISTORY_PATCH
			#if MULTI_SELECTION_PATCH
			printsel(ev->state);
			#endif // MULTI_SELECTION_PATCH
			cleanup();
			exit(0);
		}
		#if !MULTI_SELECTION_PATCH
		if (sel)
			sel->out = 1;
		#endif // MULTI_SELECTION_PATCH
		break;
	case XK_Right:
		if (text[cursor] != '\0') {
			cursor = nextrune(+1);
			break;
		}
		if (lines > 0)
			return;
		/* fallthrough */
	case XK_Down:
		if (sel && sel->right && (sel = sel->right) == next) {
			curr = next;
			calcoffsets();
		}
		break;
	case XK_Tab:
		#if PREFIXCOMPLETION_PATCH
		if (!matches) break; /* cannot complete no matches */
		strncpy(text, matches->text, sizeof text - 1);
		text[sizeof text - 1] = '\0';
		len = cursor = strlen(text); /* length of longest common prefix */
		for (item = matches; item && item->text; item = item->right) {
			cursor = 0;
			while (cursor < len && text[cursor] == item->text[cursor])
				cursor++;
			len = cursor;
		}
		memset(text + len, '\0', strlen(text) - len);
		#else
		if (!sel)
			return;
		strncpy(text, sel->text, sizeof text - 1);
		text[sizeof text - 1] = '\0';
		cursor = strlen(text);
		match();
		#endif //
		break;
	}

draw:
	#if INCREMENTAL_PATCH
	if (incremental) {
		puts(text);
		fflush(stdout);
	}
	#endif // INCREMENTAL_PATCH
	drawmenu();
}

static void
paste(void)
{
	char *p, *q;
	int di;
	unsigned long dl;
	Atom da;

	/* we have been given the current selection, now insert it into input */
	if (XGetWindowProperty(dpy, win, utf8, 0, (sizeof text / 4) + 1, False,
	                   utf8, &da, &di, &dl, &dl, (unsigned char **)&p)
	    == Success && p) {
		insert(p, (q = strchr(p, '\n')) ? q - p : (ssize_t)strlen(p));
		XFree(p);
	}
	drawmenu();
}

#if ALPHA_PATCH
static void
xinitvisual()
{
	XVisualInfo *infos;
	XRenderPictFormat *fmt;
	int nitems;
	int i;

	XVisualInfo tpl = {
		.screen = screen,
		.depth = 32,
		.class = TrueColor
	};
	long masks = VisualScreenMask | VisualDepthMask | VisualClassMask;

	infos = XGetVisualInfo(dpy, masks, &tpl, &nitems);
	visual = NULL;
	for(i = 0; i < nitems; i ++) {
		fmt = XRenderFindVisualFormat(dpy, infos[i].visual);
		if (fmt->type == PictTypeDirect && fmt->direct.alphaMask) {
			visual = infos[i].visual;
			depth = infos[i].depth;
			cmap = XCreateColormap(dpy, root, visual, AllocNone);
			useargb = 1;
			break;
		}
	}

	XFree(infos);

	if (! visual) {
		visual = DefaultVisual(dpy, screen);
		depth = DefaultDepth(dpy, screen);
		cmap = DefaultColormap(dpy, screen);
	}
}
#endif // ALPHA_PATCH

#if !NON_BLOCKING_STDIN_PATCH
static void
readstdin(void)
{
	char buf[sizeof text], *p;
	#if JSON_PATCH
	size_t i;
	unsigned int imax = 0;
	struct item *item;
	#else
	size_t i, imax = 0, size = 0;
	#endif // JSON_PATCH
	unsigned int tmpmax = 0;

	#if PASSWORD_PATCH
	if (passwd) {
		inputw = lines = 0;
		return;
	}
	#endif // PASSWORD_PATCH

	/* read each line from stdin and add it to the item list */
	for (i = 0; fgets(buf, sizeof buf, stdin); i++)	{
		#if JSON_PATCH
		item = itemnew();
		#else
		if (i + 1 >= size / sizeof *items)
			if (!(items = realloc(items, (size += BUFSIZ))))
				die("cannot realloc %u bytes:", size);
		#endif // JSON_PATCH
		if ((p = strchr(buf, '\n')))
			*p = '\0';
		#if JSON_PATCH
		if (!(item->text = strdup(buf)))
		#else
		if (!(items[i].text = strdup(buf)))
		#endif // JSON_PATCH
			die("cannot strdup %u bytes:", strlen(buf) + 1);
		#if MULTI_SELECTION_PATCH
		items[i].id = i; /* for multiselect */
		#elif JSON_PATCH
		item->json = NULL;
		item->out = 0;
		#else
		items[i].out = 0;
		#endif // items[i].out = 0;
		#if HIGHPRIORITY_PATCH
		items[i].hp = arrayhas(hpitems, hplength, items[i].text);
		#endif // HIGHPRIORITY_PATCH
		#if PANGO_PATCH
		drw_font_getexts(drw->font, buf, strlen(buf), &tmpmax, NULL, True);
		#else
		drw_font_getexts(drw->fonts, buf, strlen(buf), &tmpmax, NULL);
		#endif // PANGO_PATCH
		if (tmpmax > inputw) {
			inputw = tmpmax;
			#if JSON_PATCH
			imax = items_ln - 1;
			#else
			imax = i;
			#endif // JSON_PATCH
		}
	}
	if (items)
		#if JSON_PATCH
		items[items_ln].text = NULL;
		#else
		items[i].text = NULL;
		#endif // JSON_PATCH
	#if PANGO_PATCH
	inputw = items ? TEXTWM(items[imax].text) : 0;
	#else
	inputw = items ? TEXTW(items[imax].text) : 0;
	#endif // PANGO_PATCH
	#if JSON_PATCH
	lines = MIN(lines, items_ln);
	#else
	lines = MIN(lines, i);
	#endif // JSON_PATCH
}
#endif // NON_BLOCKING_STDIN_PATCH

static void
#if NON_BLOCKING_STDIN_PATCH
readevent(void)
#else
run(void)
#endif // NON_BLOCKING_STDIN_PATCH
{
	XEvent ev;
	#if PRESELECT_PATCH
	int i;
	#endif // PRESELECT_PATCH

	while (!XNextEvent(dpy, &ev)) {
		#if PRESELECT_PATCH
		if (preselected) {
			for (i = 0; i < preselected; i++) {
				if (sel && sel->right && (sel = sel->right) == next) {
					curr = next;
					calcoffsets();
				}
			}
			drawmenu();
			preselected = 0;
		}
		#endif // PRESELECT_PATCH
		if (XFilterEvent(&ev, win))
			continue;
		switch(ev.type) {
		#if MOUSE_SUPPORT_PATCH
		case ButtonPress:
			buttonpress(&ev);
			break;
		#endif // MOUSE_SUPPORT_PATCH
		case DestroyNotify:
			if (ev.xdestroywindow.window != win)
				break;
			cleanup();
			exit(1);
		case Expose:
			if (ev.xexpose.count == 0)
				drw_map(drw, win, 0, 0, mw, mh);
			break;
		case FocusIn:
			/* regrab focus from parent window */
			if (ev.xfocus.window != win)
				grabfocus();
			break;
		case KeyPress:
			keypress(&ev.xkey);
			break;
		case SelectionNotify:
			if (ev.xselection.property == utf8)
				paste();
			break;
		case VisibilityNotify:
			if (ev.xvisibility.state != VisibilityUnobscured)
				XRaiseWindow(dpy, win);
			break;
		}
	}
}

static void
setup(void)
{
	int x, y, i, j;
	unsigned int du;
	XSetWindowAttributes swa;
	XIM xim;
	Window w, dw, *dws;
	XWindowAttributes wa;
	XClassHint ch = {"dmenu", "dmenu"};
#ifdef XINERAMA
	XineramaScreenInfo *info;
	Window pw;
	int a, di, n, area = 0;
#endif
	/* init appearance */
	#if XRESOURCES_PATCH
	for (j = 0; j < SchemeLast; j++)
		#if ALPHA_PATCH
		scheme[j] = drw_scm_create(drw, (const char**)colors[j], alphas[j], 2);
		#else
		scheme[j] = drw_scm_create(drw, (const char**)colors[j], 2);
		#endif // ALPHA_PATCH
	#else
	for (j = 0; j < SchemeLast; j++)
		#if ALPHA_PATCH
		scheme[j] = drw_scm_create(drw, colors[j], alphas[j], 2);
		#else
		scheme[j] = drw_scm_create(drw, colors[j], 2);
		#endif // ALPHA_PATCH
	#endif // XRESOURCES_PATCH

	clip = XInternAtom(dpy, "CLIPBOARD",   False);
	utf8 = XInternAtom(dpy, "UTF8_STRING", False);
	#if WMTYPE_PATCH
	type = XInternAtom(dpy, "_NET_WM_WINDOW_TYPE", False);
	dock = XInternAtom(dpy, "_NET_WM_WINDOW_TYPE_DOCK", False);
	#endif // WMTYPE_PATCH

	/* calculate menu geometry */
	#if PANGO_PATCH
	bh = drw->font->h + 2;
	#else
	bh = drw->fonts->h + 2;
	#endif // PANGO_PATCH
	#if LINE_HEIGHT_PATCH
	bh = MAX(bh,lineheight);	/* make a menu line AT LEAST 'lineheight' tall */
	#endif // LINE_HEIGHT_PATCH
	lines = MAX(lines, 0);
	mh = (lines + 1) * bh;
	#if CENTER_PATCH && PANGO_PATCH
	promptw = (prompt && *prompt) ? TEXTWM(prompt) - lrpad / 4 : 0;
	#elif CENTER_PATCH
	promptw = (prompt && *prompt) ? TEXTW(prompt) - lrpad / 4 : 0;
	#endif // CENTER_PATCH
#ifdef XINERAMA
	i = 0;
	if (parentwin == root && (info = XineramaQueryScreens(dpy, &n))) {
		XGetInputFocus(dpy, &w, &di);
		if (mon >= 0 && mon < n)
			i = mon;
		else if (w != root && w != PointerRoot && w != None) {
			/* find top-level window containing current input focus */
			do {
				if (XQueryTree(dpy, (pw = w), &dw, &w, &dws, &du) && dws)
					XFree(dws);
			} while (w != root && w != pw);
			/* find xinerama screen with which the window intersects most */
			if (XGetWindowAttributes(dpy, pw, &wa))
				for (j = 0; j < n; j++)
					if ((a = INTERSECT(wa.x, wa.y, wa.width, wa.height, info[j])) > area) {
						area = a;
						i = j;
					}
		}
		/* no focused window is on screen, so use pointer location instead */
		if (mon < 0 && !area && XQueryPointer(dpy, root, &dw, &dw, &x, &y, &di, &di, &du))
			for (i = 0; i < n; i++)
				if (INTERSECT(x, y, 1, 1, info[i]) != 0)
					break;

		#if CENTER_PATCH
		if (center) {
			mw = MIN(MAX(max_textw() + promptw, min_width), info[i].width);
			x = info[i].x_org + ((info[i].width  - mw) / 2);
			y = info[i].y_org + ((info[i].height - mh) / 2);
		} else {
			#if XYW_PATCH
			x = info[i].x_org + dmx;
			y = info[i].y_org + (topbar ? dmy : info[i].height - mh - dmy);
			mw = (dmw>0 ? dmw : info[i].width);
			#else
			x = info[i].x_org;
			y = info[i].y_org + (topbar ? 0 : info[i].height - mh);
			mw = info[i].width;
			#endif // XYW_PATCH
		}
		#elif XYW_PATCH
		x = info[i].x_org + dmx;
		y = info[i].y_org + (topbar ? dmy : info[i].height - mh - dmy);
		mw = (dmw>0 ? dmw : info[i].width);
		#else
		x = info[i].x_org;
		y = info[i].y_org + (topbar ? 0 : info[i].height - mh);
		mw = info[i].width;
		#endif // CENTER_PATCH / XYW_PATCH
		XFree(info);
	} else
#endif
	{
		if (!XGetWindowAttributes(dpy, parentwin, &wa))
			die("could not get embedding window attributes: 0x%lx",
			    parentwin);
		#if CENTER_PATCH
		if (center) {
			mw = MIN(MAX(max_textw() + promptw, min_width), wa.width);
			x = (wa.width  - mw) / 2;
			y = (wa.height - mh) / 2;
		} else {
			#if XYW_PATCH
			x = dmx;
			y = topbar ? dmy : wa.height - mh - dmy;
			mw = (dmw>0 ? dmw : wa.width);
			#else
			x = 0;
			y = topbar ? 0 : wa.height - mh;
			mw = wa.width;
			#endif // XYW_PATCH
		}
		#elif XYW_PATCH
		x = dmx;
		y = topbar ? dmy : wa.height - mh - dmy;
		mw = (dmw>0 ? dmw : wa.width);
		#else
		x = 0;
		y = topbar ? 0 : wa.height - mh;
		mw = wa.width;
		#endif // CENTER_PATCH / XYW_PATCH
	}
	#if !CENTER_PATCH
	#if PANGO_PATCH
	promptw = (prompt && *prompt) ? TEXTWM(prompt) - lrpad / 4 : 0;
	#else
	promptw = (prompt && *prompt) ? TEXTW(prompt) - lrpad / 4 : 0;
	#endif // PANGO_PATCH
	#endif // CENTER_PATCH
	inputw = MIN(inputw, mw/3);
	match();

	/* create menu window */
	#if MANAGED_PATCH
	swa.override_redirect = managed ? False : True;
	#else
	swa.override_redirect = True;
	#endif // MANAGED_PATCH
	#if ALPHA_PATCH
	swa.background_pixel = 0;
	swa.colormap = cmap;
	#else
	swa.background_pixel = scheme[SchemeNorm][ColBg].pixel;
	#endif // ALPHA_PATCH
	swa.event_mask = ExposureMask | KeyPressMask | VisibilityChangeMask
	#if MOUSE_SUPPORT_PATCH
	| ButtonPressMask
	#endif // MOUSE_SUPPORT_PATCH
	;
	#if BORDER_PATCH
	win = XCreateWindow(dpy, parentwin, x, y, mw, mh, border_width,
	#else
	win = XCreateWindow(dpy, parentwin, x, y, mw, mh, 0,
	#endif // BORDER_PATCH
						#if ALPHA_PATCH
	                    depth, InputOutput, visual,
	                    CWOverrideRedirect|CWBackPixel|CWBorderPixel|CWColormap|CWEventMask, &swa
						#else
	                    CopyFromParent, CopyFromParent, CopyFromParent,
	                    CWOverrideRedirect | CWBackPixel | CWEventMask, &swa
						#endif // ALPHA_PATCH
	);
	#if BORDER_PATCH
	if (border_width)
		XSetWindowBorder(dpy, win, scheme[SchemeSel][ColBg].pixel);
	#endif // BORDER_PATCH
	XSetClassHint(dpy, win, &ch);
	#if WMTYPE_PATCH
	XChangeProperty(dpy, win, type, XA_ATOM, 32, PropModeReplace,
			(unsigned char *) &dock, 1);
	#endif // WMTYPE_PATCH


	/* input methods */
	if ((xim = XOpenIM(dpy, NULL, NULL, NULL)) == NULL)
		die("XOpenIM failed: could not open input device");

	xic = XCreateIC(xim, XNInputStyle, XIMPreeditNothing | XIMStatusNothing,
	                XNClientWindow, win, XNFocusWindow, win, NULL);

	#if MANAGED_PATCH
	if (managed) {
		XTextProperty prop;
		char *windowtitle = prompt != NULL ? prompt : "dmenu";
		Xutf8TextListToTextProperty(dpy, &windowtitle, 1, XUTF8StringStyle, &prop);
		XSetWMName(dpy, win, &prop);
		XSetTextProperty(dpy, win, &prop, XInternAtom(dpy, "_NET_WM_NAME", False));
		XFree(prop.value);
	}
	#endif // MANAGED_PATCH

	XMapRaised(dpy, win);
	if (embed) {
		XSelectInput(dpy, parentwin, FocusChangeMask | SubstructureNotifyMask);
		if (XQueryTree(dpy, parentwin, &dw, &w, &dws, &du) && dws) {
			for (i = 0; i < du && dws[i] != win; ++i)
				XSelectInput(dpy, dws[i], FocusChangeMask);
			XFree(dws);
		}
		grabfocus();
	}
	drw_resize(drw, mw, mh);
	drawmenu();
}

static void
usage(void)
{
	fputs("usage: dmenu [-bv"
		#if CENTER_PATCH
		"c"
		#endif
		#if !NON_BLOCKING_STDIN_PATCH
		"f"
		#endif // NON_BLOCKING_STDIN_PATCH
		#if INCREMENTAL_PATCH
		"r"
		#endif // INCREMENTAL_PATCH
		#if CASEINSENSITIVE_PATCH
		"s"
		#else
		"i"
		#endif // CASEINSENSITIVE_PATCH
		#if INSTANT_PATCH
		"n"
		#endif // INSTANT_PATCH
		#if PRINTINPUTTEXT_PATCH
		"t"
		#endif // PRINTINPUTTEXT_PATCH
		#if PREFIXCOMPLETION_PATCH
		"x"
		#endif // PREFIXCOMPLETION_PATCH
		#if FUZZYMATCH_PATCH
		"F"
		#endif // FUZZYMATCH_PATCH
		#if PASSWORD_PATCH
		"P"
		#endif // PASSWORD_PATCH
		#if REJECTNOMATCH_PATCH
		"R" // (changed from r to R due to conflict with INCREMENTAL_PATCH)
		#endif // REJECTNOMATCH_PATCH
		"] "
		#if MANAGED_PATCH
		"[-wm] "
		#endif // MANAGED_PATCH
		#if GRID_PATCH
		"[-g columns] "
		#endif // GRID_PATCH
		"[-l lines] [-p prompt] [-fn font] [-m monitor]"
		"\n             [-nb color] [-nf color] [-sb color] [-sf color] [-w windowid]"
		#if ALPHA_PATCH || BORDER_PATCH || HIGHPRIORITY_PATCH || INITIALTEXT_PATCH || LINE_HEIGHT_PATCH || NAVHISTORY_PATCH || XYW_PATCH || DYNAMIC_OPTIONS_PATCH || JSON_PATCH
		"\n            "
		#endif
		#if JSON_PATCH
		" [ -j json-file]"
		#endif // JSON_PATCH
		#if DYNAMIC_OPTIONS_PATCH
		" [ -dy command]"
		#endif // DYNAMIC_OPTIONS_PATCH
		#if ALPHA_PATCH
		" [ -o opacity]"
		#endif // ALPHA_PATCH
		#if BORDER_PATCH
		" [-bw width]"
		#endif // BORDER_PATCH
		#if HIGHPRIORITY_PATCH
		" [-hb color] [-hf color] [-hp items]"
		#endif // HIGHPRIORITY_PATCH
		#if INITIALTEXT_PATCH
		" [-it text]"
		#endif // INITIALTEXT_PATCH
		#if LINE_HEIGHT_PATCH
		" [-h height]"
		#endif // LINE_HEIGHT_PATCH
		#if PRESELECT_PATCH
		" [-ps index]"
		#endif // PRESELECT_PATCH
		#if NAVHISTORY_PATCH
		" [-H histfile]"
		#endif // NAVHISTORY_PATCH
		#if XYW_PATCH
		" [-X xoffset] [-Y yoffset] [-W width]" // (arguments made upper case due to conflicts)
		#endif // XYW_PATCH
		#if HIGHLIGHT_PATCH || FUZZYHIGHLIGHT_PATCH
		"\n [-nhb color] [-nhf color] [-shb color] [-shf color]" // highlight colors
		#endif // HIGHLIGHT_PATCH | FUZZYHIGHLIGHT_PATCH
		"\n", stderr);
	exit(1);
}

int
main(int argc, char *argv[])
{
	XWindowAttributes wa;
	int i;
	#if !NON_BLOCKING_STDIN_PATCH
	int fast = 0;
	#endif // NON_BLOCKING_STDIN_PATCH

	for (i = 1; i < argc; i++)
		/* these options take no arguments */
		if (!strcmp(argv[i], "-v")) {      /* prints version information */
			puts("dmenu-"VERSION);
			exit(0);
		} else if (!strcmp(argv[i], "-b")) { /* appears at the bottom of the screen */
			topbar = 0;
		#if CENTER_PATCH
		} else if (!strcmp(argv[i], "-c")) { /* toggles centering of dmenu window on screen */
			center = !center;
		#endif
		#if !NON_BLOCKING_STDIN_PATCH
		} else if (!strcmp(argv[i], "-f")) { /* grabs keyboard before reading stdin */
			fast = 1;
		#endif // NON_BLOCKING_STDIN_PATCH
		#if INCREMENTAL_PATCH
		} else if (!strcmp(argv[i], "-r")) { /* incremental */
			incremental = !incremental;
		#endif // INCREMENTAL_PATCH
		#if CASEINSENSITIVE_PATCH
		} else if (!strcmp(argv[i], "-s")) { /* case-sensitive item matching */
			fstrncmp = strncmp;
			fstrstr = strstr;
		#else
		} else if (!strcmp(argv[i], "-i")) { /* case-insensitive item matching */
			fstrncmp = strncasecmp;
			fstrstr = cistrstr;
		#endif // CASEINSENSITIVE_PATCH
		#if MANAGED_PATCH
		} else if (!strcmp(argv[i], "-wm")) { /* display as managed wm window */
			managed = 1;
		#endif // MANAGED_PATCH
		#if INSTANT_PATCH
		} else if (!strcmp(argv[i], "-n")) { /* instant select only match */
			instant = !instant;
		#endif // INSTANT_PATCH
		#if PRINTINPUTTEXT_PATCH
		} else if (!strcmp(argv[i], "-t")) { /* favors text input over selection */
			use_text_input = 1;
		#endif // PRINTINPUTTEXT_PATCH
		#if PREFIXCOMPLETION_PATCH
		} else if (!strcmp(argv[i], "-x")) { /* invert use_prefix */
			use_prefix = !use_prefix;
		#endif // PREFIXCOMPLETION_PATCH
		#if FUZZYMATCH_PATCH
		} else if (!strcmp(argv[i], "-F")) { /* disable/enable fuzzy matching, depends on default */
			fuzzy = !fuzzy;
		#endif // FUZZYMATCH_PATCH
		#if PASSWORD_PATCH
		} else if (!strcmp(argv[i], "-P")) { /* is the input a password */
			passwd = 1;
		#endif // PASSWORD_PATCH
		#if REJECTNOMATCH_PATCH
		} else if (!strcmp(argv[i], "-R")) { /* reject input which results in no match */
			reject_no_match = 1;
		#endif // REJECTNOMATCH_PATCH
		} else if (i + 1 == argc)
			usage();
		/* these options take one argument */
		#if NAVHISTORY_PATCH
		else if (!strcmp(argv[i], "-H"))
			histfile = argv[++i];
		#endif // NAVHISTORY_PATCH
		#if GRID_PATCH
		else if (!strcmp(argv[i], "-g")) {   /* number of columns in grid */
			columns = atoi(argv[++i]);
			if (columns && lines == 0)
				lines = 1;
		}
		#endif // GRID_PATCH
		#if JSON_PATCH
		else if (!strcmp(argv[i], "-j"))
			readjson(argv[++i]);
		#endif // JSON_PATCH
		else if (!strcmp(argv[i], "-l"))   /* number of lines in vertical list */
			lines = atoi(argv[++i]);
		#if XYW_PATCH
		else if (!strcmp(argv[i], "-X"))   /* window x offset */
			dmx = atoi(argv[++i]);
		else if (!strcmp(argv[i], "-Y"))   /* window y offset (from bottom up if -b) */
			dmy = atoi(argv[++i]);
		else if (!strcmp(argv[i], "-W"))   /* make dmenu this wide */
			dmw = atoi(argv[++i]);
		#endif // XYW_PATCH
		else if (!strcmp(argv[i], "-m"))
			mon = atoi(argv[++i]);
		#if ALPHA_PATCH
		else if (!strcmp(argv[i], "-o"))  /* opacity */
			opacity = atof(argv[++i]);
		#endif // ALPHA_PATCH
		else if (!strcmp(argv[i], "-p"))   /* adds prompt to left of input field */
			prompt = argv[++i];
		else if (!strcmp(argv[i], "-fn"))  /* font or font set */
			#if PANGO_PATCH
			strcpy(font, argv[++i]);
			#else
			fonts[0] = argv[++i];
			#endif // PANGO_PATCH
		#if LINE_HEIGHT_PATCH
		else if(!strcmp(argv[i], "-h")) { /* minimum height of one menu line */
			lineheight = atoi(argv[++i]);
			lineheight = MAX(lineheight,8); /* reasonable default in case of value too small/negative */
		}
		#endif // LINE_HEIGHT_PATCH
		else if (!strcmp(argv[i], "-nb"))  /* normal background color */
			colors[SchemeNorm][ColBg] = argv[++i];
		else if (!strcmp(argv[i], "-nf"))  /* normal foreground color */
			colors[SchemeNorm][ColFg] = argv[++i];
		else if (!strcmp(argv[i], "-sb"))  /* selected background color */
			colors[SchemeSel][ColBg] = argv[++i];
		else if (!strcmp(argv[i], "-sf"))  /* selected foreground color */
			colors[SchemeSel][ColFg] = argv[++i];
		#if HIGHPRIORITY_PATCH
		else if (!strcmp(argv[i], "-hb"))  /* high priority background color */
			colors[SchemeHp][ColBg] = argv[++i];
		else if (!strcmp(argv[i], "-hf")) /* low priority background color */
			colors[SchemeHp][ColFg] = argv[++i];
		else if (!strcmp(argv[i], "-hp"))
			hpitems = tokenize(argv[++i], ",", &hplength);
 		#endif // HIGHPRIORITY_PATCH
		#if HIGHLIGHT_PATCH || FUZZYHIGHLIGHT_PATCH
		else if (!strcmp(argv[i], "-nhb")) /* normal hi background color */
			colors[SchemeNormHighlight][ColBg] = argv[++i];
		else if (!strcmp(argv[i], "-nhf")) /* normal hi foreground color */
			colors[SchemeNormHighlight][ColFg] = argv[++i];
		else if (!strcmp(argv[i], "-shb")) /* selected hi background color */
			colors[SchemeSelHighlight][ColBg] = argv[++i];
		else if (!strcmp(argv[i], "-shf")) /* selected hi foreground color */
			colors[SchemeSelHighlight][ColFg] = argv[++i];
		#endif // HIGHLIGHT_PATCH | FUZZYHIGHLIGHT_PATCH
		else if (!strcmp(argv[i], "-w"))   /* embedding window id */
			embed = argv[++i];
		#if PRESELECT_PATCH
		else if (!strcmp(argv[i], "-ps"))   /* preselected item */
			preselected = atoi(argv[++i]);
		#endif // PRESELECT_PATCH
		#if DYNAMIC_OPTIONS_PATCH
		else if (!strcmp(argv[i], "-dy"))  /* dynamic command to run */
			dynamic = argv[++i];
		#endif // DYNAMIC_OPTIONS_PATCH
		#if BORDER_PATCH
		else if (!strcmp(argv[i], "-bw"))  /* border width around dmenu */
			border_width = atoi(argv[++i]);
		#endif // BORDER_PATCH
		#if INITIALTEXT_PATCH
		else if (!strcmp(argv[i], "-it")) {   /* adds initial text */
			const char * text = argv[++i];
			insert(text, strlen(text));
		}
		#endif // INITIALTEXT_PATCH
		else
			usage();

	if (!setlocale(LC_CTYPE, "") || !XSupportsLocale())
		fputs("warning: no locale support\n", stderr);
	if (!(dpy = XOpenDisplay(NULL)))
		die("cannot open display");
	screen = DefaultScreen(dpy);
	root = RootWindow(dpy, screen);
	if (!embed || !(parentwin = strtol(embed, NULL, 0)))
		parentwin = root;
	if (!XGetWindowAttributes(dpy, parentwin, &wa))
		die("could not get embedding window attributes: 0x%lx",
		    parentwin);

	#if ALPHA_PATCH
	xinitvisual();
	drw = drw_create(dpy, screen, root, wa.width, wa.height, visual, depth, cmap);
	#else
	drw = drw_create(dpy, screen, root, wa.width, wa.height);
	#endif // ALPHA_PATCH
	#if XRESOURCES_PATCH
	readxresources();
	#if PANGO_PATCH
	if (!drw_font_create(drw, font))
		die("no fonts could be loaded.");
	#else
	if (!drw_fontset_create(drw, (const char**)fonts, LENGTH(fonts)))
		die("no fonts could be loaded.");
	#endif // PANGO_PATCH
	#elif PANGO_PATCH
	if (!drw_font_create(drw, font))
		die("no fonts could be loaded.");
	#else
	if (!drw_fontset_create(drw, fonts, LENGTH(fonts)))
		die("no fonts could be loaded.");
	#endif // XRESOURCES_PATCH | PANGO_PATCH
	#if PANGO_PATCH
	lrpad = drw->font->h;
	#else
	lrpad = drw->fonts->h;
	#endif // PANGO_PATCH

#ifdef __OpenBSD__
	if (pledge("stdio rpath", NULL) == -1)
		die("pledge");
#endif
	#if NAVHISTORY_PATCH
	loadhistory();
	#endif // NAVHISTORY_PATCH

	#if NON_BLOCKING_STDIN_PATCH
	grabkeyboard();
	#else
	if (fast && !isatty(0)) {
		grabkeyboard();
		#if JSON_PATCH
		if (json)
			listjson(json);
		#if DYNAMIC_OPTIONS_PATCH
		else if (!(dynamic && *dynamic))
			readstdin();
		#else
		else
			readstdin();
		#endif // DYNAMIC_OPTIONS_PATCH
		#elif DYNAMIC_OPTIONS_PATCH
		if (!(dynamic && *dynamic))
			readstdin();
		#else
		readstdin();
		#endif // JSON_PATCH | DYNAMIC_OPTIONS_PATCH
	} else {
		#if JSON_PATCH
		if (json)
			listjson(json);
		#if DYNAMIC_OPTIONS_PATCH
		else if (!(dynamic && *dynamic))
			readstdin();
		#else
		else
			readstdin();
		#endif // DYNAMIC_OPTIONS_PATCH
		#elif DYNAMIC_OPTIONS_PATCH
		if (!(dynamic && *dynamic))
			readstdin();
		#else
		readstdin();
		#endif // JSON_PATCH | DYNAMIC_OPTIONS_PATCH
		grabkeyboard();
	}
	#endif // NON_BLOCKING_STDIN_PATCH
	setup();
	run();

	return 1; /* unreachable */
}
