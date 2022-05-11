#include <fcntl.h>
#include <unistd.h>
#include <sys/select.h>

static void
readstdin(void)
{
	static size_t max = 0;
	static struct item **end = &items;

	char buf[sizeof text], *p, *maxstr;
	struct item *item;

	#if PASSWORD_PATCH
	if (passwd) {
		inputw = lines = 0;
		return;
	}
	#endif // PASSWORD_PATCH

	/* read each line from stdin and add it to the item list */
	while (fgets(buf, sizeof buf, stdin)) {
		if (!(item = malloc(sizeof *item)))
			die("cannot malloc %u bytes:", sizeof *item);
		if ((p = strchr(buf, '\n')))
			*p = '\0';
		if (!(item->text = strdup(buf)))
			die("cannot strdup %u bytes:", strlen(buf)+1);
		if (strlen(item->text) > max) {
			max = strlen(maxstr = item->text);
			#if PANGO_PATCH
			inputw = maxstr ? TEXTWM(maxstr) : 0;
			#else
			inputw = maxstr ? TEXTW(maxstr) : 0;
			#endif // PANGO_PATCH
		}
		*end = item;
		end = &item->next;
		item->next = NULL;
		item->out = 0;
	}
	match();
	drawmenu();
}

static void
run(void)
{
	fd_set fds;
	int flags, xfd = XConnectionNumber(dpy);

	if ((flags = fcntl(0, F_GETFL)) == -1)
		die("cannot get stdin control flags:");
	if (fcntl(0, F_SETFL, flags | O_NONBLOCK) == -1)
		die("cannot set stdin control flags:");
	for (;;) {
		FD_ZERO(&fds);
		FD_SET(xfd, &fds);
		if (!feof(stdin))
			FD_SET(0, &fds);
		if (select(xfd + 1, &fds, NULL, NULL, NULL) == -1)
			die("cannot multiplex input:");
		if (FD_ISSET(xfd, &fds))
			readevent();
		if (FD_ISSET(0, &fds))
			readstdin();
	}
}