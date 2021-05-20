int
utf8nextchar(const char *str, int len, int i, int inc)
{
	int n;

	for (n = i + inc; n + inc >= 0 && n + inc <= len
	  && (str[n] & 0xc0) == 0x80; n += inc)
		;
	return n;
}

int
drw_text_align(Drw *drw, int x, int y, unsigned int w, unsigned int h, const char *text, int textlen, int align)
{
	int ty;
	unsigned int ew;
	XftDraw *d = NULL;
	Fnt *usedfont, *curfont, *nextfont;
	size_t len;
	int utf8strlen, utf8charlen, render = x || y || w || h;
	long utf8codepoint = 0;
	const char *utf8str;
	FcCharSet *fccharset;
	FcPattern *fcpattern;
	FcPattern *match;
	XftResult result;
	int charexists = 0;
	int i, n;

	if (!drw || (render && !drw->scheme) || !text || !drw->fonts || textlen <= 0
	  || (align != AlignL && align != AlignR))
		return 0;

	if (!render) {
		w = ~w;
	} else {
		XSetForeground(drw->dpy, drw->gc, drw->scheme[ColBg].pixel);
		XFillRectangle(drw->dpy, drw->drawable, drw->gc, x, y, w, h);
		d = XftDrawCreate(drw->dpy, drw->drawable,
		                  DefaultVisual(drw->dpy, drw->screen),
		                  DefaultColormap(drw->dpy, drw->screen));
	}

	usedfont = drw->fonts;
	i = align == AlignL ? 0 : textlen;
	x = align == AlignL ? x : x + w;
	while (1) {
		utf8strlen = 0;
		nextfont = NULL;
		/* if (align == AlignL) */
		utf8str = text + i;

		while ((align == AlignL && i < textlen) || (align == AlignR && i > 0)) {
			if (align == AlignL) {
				utf8charlen = utf8decode(text + i, &utf8codepoint, MIN(textlen - i, UTF_SIZ));
				if (!utf8charlen) {
					textlen = i;
					break;
				}
			} else {
				n = utf8nextchar(text, textlen, i, -1);
				utf8charlen = utf8decode(text + n, &utf8codepoint, MIN(textlen - n, UTF_SIZ));
				if (!utf8charlen) {
					textlen -= i;
					text += i;
					i = 0;
					break;
				}
			}
			for (curfont = drw->fonts; curfont; curfont = curfont->next) {
				charexists = charexists || XftCharExists(drw->dpy, curfont->xfont, utf8codepoint);
				if (charexists) {
					if (curfont == usedfont) {
						utf8strlen += utf8charlen;
						i += align == AlignL ? utf8charlen : -utf8charlen;
					} else {
						nextfont = curfont;
					}
					break;
				}
			}

			if (!charexists || nextfont)
				break;
			else
				charexists = 0;
		}

		if (align == AlignR)
			utf8str = text + i;

		if (utf8strlen) {
			drw_font_getexts(usedfont, utf8str, utf8strlen, &ew, NULL);
			/* shorten text if necessary */
			if (align == AlignL) {
				for (len = utf8strlen; len && ew > w; ) {
					len = utf8nextchar(utf8str, len, len, -1);
					drw_font_getexts(usedfont, utf8str, len, &ew, NULL);
				}
			} else {
				for (len = utf8strlen; len && ew > w; ) {
					n = utf8nextchar(utf8str, len, 0, +1);
					utf8str += n;
					len -= n;
					drw_font_getexts(usedfont, utf8str, len, &ew, NULL);
				}
			}

			if (len) {
				if (render) {
					ty = y + (h - usedfont->h) / 2 + usedfont->xfont->ascent;
					XftDrawStringUtf8(d, &drw->scheme[ColFg],
					                  usedfont->xfont, align == AlignL ? x : x - ew, ty, (XftChar8 *)utf8str, len);
				}
				x += align == AlignL ? ew : -ew;
				w -= ew;
			}
			if (len < utf8strlen)
				break;
		}

		if ((align == AlignR && i <= 0) || (align == AlignL && i >= textlen)) {
			break;
		} else if (nextfont) {
			charexists = 0;
			usedfont = nextfont;
		} else {
			/* Regardless of whether or not a fallback font is found, the
			 * character must be drawn. */
			charexists = 1;

			fccharset = FcCharSetCreate();
			FcCharSetAddChar(fccharset, utf8codepoint);

			if (!drw->fonts->pattern) {
				/* Refer to the comment in xfont_create for more information. */
				die("the first font in the cache must be loaded from a font string.");
			}

			fcpattern = FcPatternDuplicate(drw->fonts->pattern);
			FcPatternAddCharSet(fcpattern, FC_CHARSET, fccharset);
			FcPatternAddBool(fcpattern, FC_SCALABLE, FcTrue);

			FcConfigSubstitute(NULL, fcpattern, FcMatchPattern);
			FcDefaultSubstitute(fcpattern);
			match = XftFontMatch(drw->dpy, drw->screen, fcpattern, &result);

			FcCharSetDestroy(fccharset);
			FcPatternDestroy(fcpattern);

			if (match) {
				usedfont = xfont_create(drw, NULL, match);
				if (usedfont && XftCharExists(drw->dpy, usedfont->xfont, utf8codepoint)) {
					for (curfont = drw->fonts; curfont->next; curfont = curfont->next)
						; /* NOP */
					curfont->next = usedfont;
				} else {
					xfont_free(usedfont);
					usedfont = drw->fonts;
				}
			}
		}
	}
	if (d)
		XftDrawDestroy(d);

	return x;
}