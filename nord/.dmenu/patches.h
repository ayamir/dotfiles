/* Patches */

/* The alpha patch adds transparency for the dmenu window.
 * You need to uncomment the corresponding line in config.mk to use the -lXrender library
 * when including this patch.
 */
#define ALPHA_PATCH 0

/* This patch adds a border around the dmenu window. It is intended to be used with the center
 * or xyw patches, to make the menu stand out from similarly coloured windows.
 * http://tools.suckless.org/dmenu/patches/border/
 */
#define BORDER_PATCH 1

/* This patch makes dmenu case-insensitive by default, replacing the
 * case-insensitive -i option with a case sensitive -s option.
 * http://tools.suckless.org/dmenu/patches/case-insensitive/
 */
#define CASEINSENSITIVE_PATCH 0

/* This patch centers dmenu in the middle of the screen.
 * https://tools.suckless.org/dmenu/patches/center/
 */
#define CENTER_PATCH 1

/* This patch enables color emoji in dmenu by removing a workaround for a BadLength error
 * in the Xft library when color glyphs are used.
 * To enable this you will need an updated Xft library that can handle color glyphs otherwise
 * the program will crash on encountering such characters. Note that you will also need a font
 * that provides color emojis for this to work.
 */
#define COLOR_EMOJI_PATCH 0

/* This patch adds a flag (-dy) which makes dmenu run the command given to it whenever input
 * is changed with the current input as the last argument and update the option list according
 * to the output of that command.
 * https://tools.suckless.org/dmenu/patches/dynamicoptions/
 */
#define DYNAMIC_OPTIONS_PATCH 0

/* This patch make it so that fuzzy matches gets highlighted and is therefore meant
 * to be used together with the fuzzymatch patch.
 * https://tools.suckless.org/dmenu/patches/fuzzyhighlight/
 */
#define FUZZYHIGHLIGHT_PATCH 1

/* This patch adds support for fuzzy-matching to dmenu, allowing users to type non-consecutive
 * portions of the string to be matched.
 * https://tools.suckless.org/dmenu/patches/fuzzymatch/
 */
#define FUZZYMATCH_PATCH 1

/* Allows dmenu's entries to be rendered in a grid by adding a new -g flag to specify
 * the number of grid columns. The -g and -l options can be used together to create a
 * G columns * L lines grid.
 * https://tools.suckless.org/dmenu/patches/grid/
 */
#define GRID_PATCH 1

/* This patch highlights the individual characters of matched text for each dmenu list entry.
 * The fuzzy highlight patch takes precedence over this patch.
 * https://tools.suckless.org/dmenu/patches/highlight/
 */
#define HIGHLIGHT_PATCH 1

/* This will automatically sort the search result so that high priority items are shown first.
 * https://tools.suckless.org/dmenu/patches/highpriority/
 */
#define HIGHPRIORITY_PATCH 1

/* This patch causes dmenu to print out the current text each time a key is pressed.
 * https://tools.suckless.org/dmenu/patches/incremental/
 */
#define INCREMENTAL_PATCH 0

/* This patch adds an option to provide preselected text.
 * https://tools.suckless.org/dmenu/patches/initialtext/
 */
#define INITIALTEXT_PATCH 0

/* This patch adds a flag which will cause dmenu to select an item immediately if there
 * is only one matching option left.
 * https://tools.suckless.org/dmenu/patches/instant/
 */
#define INSTANT_PATCH 0

/* This patch adds basic support for json files.
 * This patch depends on the jansson library. Uncomment the relevant line in config.mk when
 * enabling this patch.
 *
 * This patch is not compatible with the multi-selection, printinputtext, pipeout and
 * non-blocking stdin patches.
 * The multi-selection patch takes precedence over this patch.
 * This patch takes precedence over non-blocking stdin, pipeout and printintputtext patches.
 *
 * https://tools.suckless.org/dmenu/patches/json/
 */
#define JSON_PATCH 0

/* This patch adds a '-h' option which sets the minimum height of a dmenu line. This helps
 * integrate dmenu with other UI elements that require a particular vertical size.
 * http://tools.suckless.org/dmenu/patches/line-height/
 */
#define LINE_HEIGHT_PATCH 1

/* This patch adds a -wm flag which sets override_redirect to false; thus letting your window
 * manager manage the dmenu window.
 *
 * This may be helpful in contexts where you don't want to exclusively bind dmenu or want to
 * treat dmenu more as a "window" rather than as an overlay.
 * https://tools.suckless.org/dmenu/patches/managed/
 */
#define MANAGED_PATCH 0

/* This patch adds an additional color scheme for highlighting entries adjacent to the current
 * selection.
 * https://tools.suckless.org/dmenu/patches/morecolor/
 */
#define MORECOLOR_PATCH 0

/* This patch adds basic mouse support for dmenu.
 * https://tools.suckless.org/dmenu/patches/mouse-support/
 */
#define MOUSE_SUPPORT_PATCH 1

/* Without this patch when you press Ctrl+Enter dmenu just outputs current item and it is not
 * possible to undo that.
 * With this patch dmenu will output all selected items only on exit. It is also possible to
 * deselect any selected item.
 * Also refer to the dmenu_run replacement on the below URL that supports multiple selections.
 *
 * This patch is not compatible with, and takes precedence over, the json, printinputtext,
 * pipeout and non-blocking stdin patches.
 *
 * https://tools.suckless.org/dmenu/patches/multi-selection/
 */
#define MULTI_SELECTION_PATCH 0

/* This patch provides dmenu the ability for history navigation similar to that of bash.
 * https://tools.suckless.org/dmenu/patches/navhistory/
 */
#define NAVHISTORY_PATCH 0

/* This is a patch to have dmenu read stdin in a non blocking way, making it wait for input both
 * from stdin and from X. This means that you can continue feeding dmenu while you type.
 * This patch is meant to be used along with the incremental patch, so that you can use stdout
 * to feed stdin.
 *
 * This patch is not compatible with the json and multi-selection patches, both of which takes
 * precedence over this patch.
 *
 * https://tools.suckless.org/dmenu/patches/non_blocking_stdin/
 */
#define NON_BLOCKING_STDIN_PATCH 0

/* Adds text which displays the number of matched and total items in the top right corner of dmenu.
 * https://tools.suckless.org/dmenu/patches/numbers/
 */
#define NUMBERS_PATCH 1

/* This patch adds simple markup for dmenu using pango markup.
 * This depends on the pango library v1.44 or greater.
 * You need to uncomment the corresponding lines in config.mk to use the pango libraries
 * when including this patch.
 *
 * Note that the pango patch is incompatible with the scroll patch and will result in
 * compilation errors if both are enabled.
 *
 * Note that the pango patch does not protect against the BadLength error from Xft
 * when color glyphs are used, which means that dmenu will crash if color emoji is used.
 *
 * If you need color emoji then you may want to install this patched library from the AUR:
 * https://aur.archlinux.org/packages/libxft-bgra/
 *
 * A long term fix for the libXft library is pending approval of this pull request:
 * https://gitlab.freedesktop.org/xorg/lib/libxft/-/merge_requests/1
 *
 * Also see:
 * https://developer.gnome.org/pygtk/stable/pango-markup-language.html
 * https://github.com/StillANixRookie/dmenu-pango
 */
#define PANGO_PATCH 0

/* With this patch dmenu will not directly display the keyboard input, but instead replace
 * it with dots. All data from stdin will be ignored.
 * https://tools.suckless.org/dmenu/patches/password/
 */
#define PASSWORD_PATCH 0

/* This patch allows the selected text to be piped back out with dmenu. This can be useful if you
 * want to display the output of a command on the screen.
 * Only text starting with the character '#' is piped out by default.
 *
 * This patch is not compatible with the json and multi-select patches, both of which takes
 * precedence over this one.
 *
 * https://tools.suckless.org/dmenu/patches/pipeout/
 */
#define PIPEOUT_PATCH 0

/* This patch changes the behaviour of matched items and the Tab key to allow tab completion.
 * https://tools.suckless.org/dmenu/patches/prefix-completion/
 */
#define PREFIXCOMPLETION_PATCH 0

/* This patch adds an option -ps to specify an item by providing the index that should be
 * pre-selected.
 * https://tools.suckless.org/dmenu/patches/preselect/
 */
#define PRESELECT_PATCH 0

/* This patch adds a flag (-t) which makes Return key to ignore selection and print the input
 * text to stdout. The flag basically swaps the functions of Return and Shift+Return hotkeys.
 *
 * This patch is not compatible with the multi-select and json patches, both of which takes
 * precedence over this one.
 *
 * https://tools.suckless.org/dmenu/patches/printinputtext/
 */
#define PRINTINPUTTEXT_PATCH 0

/* This patch adds a new flag to dmenu with which text input will be rejected if it would
 * result in no matching item.
 * https://tools.suckless.org/dmenu/patches/reject-no-match/
 */
#define REJECTNOMATCH_PATCH 0

/* This patch adds support for text scrolling and no longer appends '...' for long input as
 * it can handle long text.
 * https://tools.suckless.org/dmenu/patches/scroll/
 */
#define SCROLL_PATCH 1

/* This patch allows the symbols, which are printed in dmenu to indicate that either the input
 * is too long or there are too many options to be shown in dmenu in one line, to be defined.
 * https://tools.suckless.org/dmenu/patches/symbols/
 */
#define SYMBOLS_PATCH 0

/* This patch prevents dmenu from indenting items at the same level as the prompt length.
 * https://tools.suckless.org/dmenu/patches/vertfull/
 */
#define VERTFULL_PATCH 1

/* Adds extended window manager hints such as _NET_WM_WINDOW_TYPE and _NET_WM_WINDOW_TYPE_DOCK.
 * https://github.com/Baitinq/dmenu/blob/master/patches/dmenu-wm_type.diff
 */
#define WMTYPE_PATCH 0

/* This patch adds the ability to configure dmenu via Xresources. At startup, dmenu will read and
 * apply the resources named below:
 *    dmenu.font          : font or font set
 *    dmenu.background    : normal background color
 *    dmenu.foreground    : normal foreground color
 *    dmenu.selbackground : selected background color
 *    dmenu.selforeground : selected foreground color
 * https://tools.suckless.org/dmenu/patches/xresources/
 */
#define XRESOURCES_PATCH 0

/* This patch adds options for specifying dmenu window position and width.
 * The center patch takes precedence over the XYW patch if enabled.
 * https://tools.suckless.org/dmenu/patches/xyw/
 */
#define XYW_PATCH 1
