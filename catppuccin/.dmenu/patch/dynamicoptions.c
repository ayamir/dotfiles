static void
refreshoptions()
{
	int dynlen = strlen(dynamic);
	char* cmd= malloc(dynlen + strlen(text) + 2);
	if (cmd == NULL)
		die("malloc:");
	sprintf(cmd, "%s %s", dynamic, text);
	FILE *stream = popen(cmd, "r");
	if (!stream)
		die("popen(%s):", cmd);
	readstream(stream);
	int pc = pclose(stream);
	if (pc == -1)
		die("pclose:");
	free(cmd);
	curr = sel = items;
}

static void
readstream(FILE* stream)
{
	char buf[sizeof text], *p;
	size_t i, imax = 0, size = 0;
	unsigned int tmpmax = 0;

	/* read each line from stdin and add it to the item list */
	for (i = 0; fgets(buf, sizeof buf, stream); i++) {
		if (i + 1 >= size / sizeof *items)
			if (!(items = realloc(items, (size += BUFSIZ))))
				die("cannot realloc %u bytes:", size);
		if ((p = strchr(buf, '\n')))
			*p = '\0';
		if (!(items[i].text = strdup(buf)))
			die("cannot strdup %u bytes:", strlen(buf) + 1);
		items[i].out = 0;
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
			imax = i;
		}
	}
	if (items)
		items[i].text = NULL;
	#if PANGO_PATCH
	inputw = items ? TEXTWM(items[imax].text) : 0;
	#else
	inputw = items ? TEXTW(items[imax].text) : 0;
	#endif // PANGO_PATCH
	if (!dynamic || !*dynamic)
		lines = MIN(lines, i);
}