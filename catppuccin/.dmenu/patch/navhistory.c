static char *histfile;
static char *histbuf, *histptr;
static size_t histsz;

static void
loadhistory(void)
{
	FILE *fp = NULL;
	size_t sz;

	if (!histfile)
		return;
	if (!(fp = fopen(histfile, "r")))
		return;
	fseek(fp, 0, SEEK_END);
	sz = ftell(fp);
	fseek(fp, 0, SEEK_SET);
	if (sz) {
		histsz = sz + 1 + BUFSIZ;
		if (!(histbuf = malloc(histsz))) {
			fprintf(stderr, "warning: cannot malloc %lu "\
				"bytes", histsz);
		} else {
			histptr = histbuf + fread(histbuf, 1, sz, fp);
			if (histptr <= histbuf) { /* fread error */
				free(histbuf);
				histbuf = NULL;
				return;
			}
			if (histptr[-1] != '\n')
				*histptr++ = '\n';
			histptr[BUFSIZ - 1] = '\0';
			*histptr = '\0';
			histsz = histptr - histbuf + BUFSIZ;
		}
	}
	fclose(fp);
}

static void
navhistory(int dir)
{
	char *p;
	size_t len = 0, textlen;

	if (!histbuf)
		return;
	if (dir > 0) {
		if (histptr == histbuf + histsz - BUFSIZ)
			return;
		while (*histptr && *histptr++ != '\n');
		for (p = histptr; *p && *p++ != '\n'; len++);
	} else {
		if (histptr == histbuf)
			return;
		if (histptr == histbuf + histsz - BUFSIZ) {
			textlen = strlen(text);
			textlen = MIN(textlen, BUFSIZ - 1);
			strncpy(histptr, text, textlen);
			histptr[textlen] = '\0';
		}
		for (histptr--; histptr != histbuf && histptr[-1] != '\n';
		     histptr--, len++);
	}
	len = MIN(len, BUFSIZ - 1);
	strncpy(text, histptr, len);
	text[len] = '\0';
	cursor = len;
	match();
}

static void
savehistory(char *str)
{
	unsigned int n = 0, len = 0;
	size_t slen;
	char *p;
	FILE *fp;

	if (!histfile || !maxhist)
		return;
	if (!(slen = strlen(str)))
		return;
	if (histbuf && maxhist > 1) {
		p = histbuf + histsz - BUFSIZ - 1; /* skip the last newline */
		if (histnodup) {
			for (; p != histbuf && p[-1] != '\n'; p--, len++);
			n++;
			if (slen == len && !strncmp(p, str, len)) {
				return;
			}
		}
		for (; p != histbuf; p--, len++)
			if (p[-1] == '\n' && ++n + 1 > maxhist)
				break;
		fp = fopen(histfile, "w");
		fwrite(p, 1, len + 1, fp);	/* plus the last newline */
	} else {
		fp = fopen(histfile, "w");
	}
	fwrite(str, 1, strlen(str), fp);
	fclose(fp);
}