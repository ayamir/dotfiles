/* See LICENSE file for copyright and license details. */

#if PANGO_PATCH
#include <pango/pango.h>
#include <pango/pangoxft.h>
#endif // PANGO_PATCH

typedef struct {
	Cursor cursor;
} Cur;

typedef struct Fnt {
	Display *dpy;
	unsigned int h;
	#if PANGO_PATCH
	PangoLayout *layout;
	#else
	XftFont *xfont;
	FcPattern *pattern;
	struct Fnt *next;
	#endif // PANGO_PATCH
} Fnt;

enum { ColFg, ColBg }; /* Clr scheme index */
typedef XftColor Clr;

typedef struct {
	unsigned int w, h;
	Display *dpy;
	int screen;
	Window root;
	#if ALPHA_PATCH
	Visual *visual;
	unsigned int depth;
	Colormap cmap;
	#endif // ALPHA_PATCH
	Drawable drawable;
	GC gc;
	Clr *scheme;
	#if PANGO_PATCH
	Fnt *font;
	#else
	Fnt *fonts;
	#endif // PANGO_PATCH
} Drw;

/* Drawable abstraction */
#if ALPHA_PATCH
Drw *drw_create(Display *dpy, int screen, Window win, unsigned int w, unsigned int h, Visual *visual, unsigned int depth, Colormap cmap);
#else
Drw *drw_create(Display *dpy, int screen, Window win, unsigned int w, unsigned int h);
#endif // ALPHA_PATCH
void drw_resize(Drw *drw, unsigned int w, unsigned int h);
void drw_free(Drw *drw);

/* Fnt abstraction */
#if PANGO_PATCH
Fnt *drw_font_create(Drw* drw, const char font[]);
void drw_font_free(Fnt* set);
unsigned int drw_font_getwidth(Drw *drw, const char *text, Bool markup);
void drw_font_getexts(Fnt *font, const char *text, unsigned int len, unsigned int *w, unsigned int *h, Bool markup);
#else
Fnt *drw_fontset_create(Drw* drw, const char *fonts[], size_t fontcount);
void drw_fontset_free(Fnt* set);
unsigned int drw_fontset_getwidth(Drw *drw, const char *text);
void drw_font_getexts(Fnt *font, const char *text, unsigned int len, unsigned int *w, unsigned int *h);
#endif // PANGO_PATCH

/* Colorscheme abstraction */
#if ALPHA_PATCH
void drw_clr_create(Drw *drw, Clr *dest, const char *clrname, unsigned int alpha);
Clr *drw_scm_create(Drw *drw, const char *clrnames[], const unsigned int alphas[], size_t clrcount);
#else
void drw_clr_create(Drw *drw, Clr *dest, const char *clrname);
Clr *drw_scm_create(Drw *drw, const char *clrnames[], size_t clrcount);
#endif // ALPHA_PATCH

/* Cursor abstraction */
Cur *drw_cur_create(Drw *drw, int shape);
void drw_cur_free(Drw *drw, Cur *cursor);

/* Drawing context manipulation */
#if !PANGO_PATCH
void drw_setfontset(Drw *drw, Fnt *set);
#endif // PANGO_PATCH
void drw_setscheme(Drw *drw, Clr *scm);

/* Drawing functions */
void drw_rect(Drw *drw, int x, int y, unsigned int w, unsigned int h, int filled, int invert);
#if PANGO_PATCH
int drw_text(Drw *drw, int x, int y, unsigned int w, unsigned int h, unsigned int lpad, const char *text, int invert, Bool markup);
#else
int drw_text(Drw *drw, int x, int y, unsigned int w, unsigned int h, unsigned int lpad, const char *text, int invert);
#endif // PANGO_PATCH

/* Map functions */
void drw_map(Drw *drw, Window win, int x, int y, unsigned int w, unsigned int h);

#if SCROLL_PATCH
#include "patch/scroll.h"
#endif