static char **hpitems = NULL;
static int hplength = 0;

static char**
tokenize(char *source, const char *delim, int *llen) {
	int listlength = 0;
	char **list = malloc(1 * sizeof(char*));
	char *token = strtok(source, delim);

	while (token) {
		if (!(list = realloc(list, sizeof(char*) * (listlength + 1))))
			die("Unable to realloc %d bytes\n", sizeof(char*) * (listlength + 1));
		if (!(list[listlength] = strdup(token)))
			die("Unable to strdup %d bytes\n", strlen(token) + 1);
		token = strtok(NULL, delim);
		listlength++;
	}

	*llen = listlength;
	return list;
}

static int
arrayhas(char **list, int length, char *item) {
	for (int i = 0; i < length; i++) {
		int len1 = strlen(list[i]);
		int len2 = strlen(item);
		if (fstrncmp(list[i], item, len1 > len2 ? len2 : len1) == 0)
			return 1;
	}
	return 0;
}