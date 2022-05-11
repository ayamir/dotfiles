static void
drawhighlights(struct item *item, int x, int y, int maxw)
{
	int i, indent;
	char *highlight;
	char c;

	if (!(strlen(item->text) && strlen(text)))
		return;

	drw_setscheme(drw, scheme[item == sel
	                   ? SchemeSelHighlight
	                   : SchemeNormHighlight]);
	for (i = 0, highlight = item->text; *highlight && text[i];) {
		#if FUZZYMATCH_PATCH
		if (!fstrncmp(&(*highlight), &text[i], 1))
		#else
		if (*highlight == text[i])
		#endif // FUZZYMATCH_PATCH
		{
			/* get indentation */
			c = *highlight;
			*highlight = '\0';
			indent = TEXTW(item->text);
			*highlight = c;

			/* highlight character */
			c = highlight[1];
			highlight[1] = '\0';
			drw_text(
				drw,
				x + indent - (lrpad / 2),
				y,
				MIN(maxw - indent, TEXTW(highlight) - lrpad),
				bh, 0, highlight, 0
				#if PANGO_PATCH
				, True
				#endif // PANGO_PATCH
			);
			highlight[1] = c;
			i++;
		}
		highlight++;
	}
}
