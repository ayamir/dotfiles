#include <jansson.h>

static size_t items_sz = 0;
static size_t items_ln = 0;
static json_t *json = NULL;

static struct item *
itemnew(void)
{
	if (items_ln + 1 >= (items_sz / sizeof *items))
		if (!(items = realloc(items, (items_sz += BUFSIZ))))
			die("cannot realloc %u bytes:", items_sz);
	return &items[items_ln++];
}

static void
readjson(const char *path)
{
	json_error_t jerr;

	if (!(json = json_load_file(path, 0, &jerr)))
		die("%s @ line: %i - %s", jerr.text, jerr.line, path);
}

static void
listjson(json_t *obj)
{
	void *iter;
	unsigned imax = 0;
	unsigned tmpmax = 0;
	struct item *item;

	items_ln = 0;
	iter = json_object_iter(obj);
	while (iter) {
		item = itemnew();
		item->text = (char*) json_object_iter_key(iter);
		item->json = json_object_iter_value(iter);
		#if !MULTI_SELECTION_PATCH
		item->out = 0;
		#endif // MULTI_SELECTION_PATCH
		drw_font_getexts(drw->fonts, item->text, strlen(item->text),
				 &tmpmax, NULL);
		if (tmpmax > inputw) {
			inputw = tmpmax;
			imax = items_ln - 1;
		}
		iter = json_object_iter_next(obj, iter);
	}
	if (items)
		items[items_ln].text = NULL;
	inputw = items ? TEXTW(items[imax].text) : 0;
	lines = MIN(lines, items_ln - 1);
}

static int
printjsonssel(unsigned int state)
{
	if (sel && sel->json) {
		if (json_is_object(sel->json)) {
			listjson(sel->json);
			text[0] = '\0';
			match();
			drawmenu();
			return 0;
		} else {
			puts(json_string_value(sel->json));
		}
	} else {
		puts((sel && !(state & ShiftMask)) ? sel->text : text);
	}
	return 1;
}