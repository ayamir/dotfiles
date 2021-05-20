#if CENTER_PATCH
#include "center.c"
#endif
#if DYNAMIC_OPTIONS_PATCH
#include "dynamicoptions.c"
#endif
#if FUZZYHIGHLIGHT_PATCH
#include "fuzzyhighlight.c"
#elif HIGHLIGHT_PATCH
#include "highlight.c"
#endif
#if FUZZYMATCH_PATCH
#include "fuzzymatch.c"
#endif
#if HIGHPRIORITY_PATCH
#include "highpriority.c"
#endif
#if MULTI_SELECTION_PATCH
#include "multiselect.c"
#endif
#if JSON_PATCH
#include "json.c"
#endif
#if MOUSE_SUPPORT_PATCH
#include "mousesupport.c"
#endif
#if NAVHISTORY_PATCH
#include "navhistory.c"
#endif
#if NON_BLOCKING_STDIN_PATCH
#include "nonblockingstdin.c"
#endif
#if NUMBERS_PATCH
#include "numbers.c"
#endif
#if XRESOURCES_PATCH
#include "xresources.c"
#endif