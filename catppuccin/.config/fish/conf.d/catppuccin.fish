# Catppuccin color palette

# --> special
set -l foreground dadae8
set -l selection 3e4058

# --> palette
set -l teal bee4ed
set -l flamingo f2cecf
set -l magenta c6aae8
set -l pink e5b4e2
set -l red e38c8f
set -l peach f9c096
set -l green b1e3ad
set -l yellow ebddaa
set -l blue a4b9ef
set -l gray 6e6c7e

# Syntax Highlighting
set -g fish_color_normal $foreground
set -g fish_color_command $blue
set -g fish_color_param $flamingo
set -g fish_color_keyword $red
set -g fish_color_quote $green
set -g fish_color_redirection $pink
set -g fish_color_end $peach
set -g fish_color_error $red
set -g fish_color_gray $gray
set -g fish_color_selection --background=$selection
set -g fish_color_search_match --background=$selection
set -g fish_color_operator $pink
set -g fish_color_escape $flamingo
set -g fish_color_autosuggestion $gray
set -g fish_color_cancel $red

# Prompt
set -g fish_color_cwd $yellow
set -g fish_color_user $teal
set -g fish_color_host $blue

# Completion Pager
set -g fish_pager_color_progress $gray
set -g fish_pager_color_prefix $pink
set -g fish_pager_color_completion $foreground
set -g fish_pager_color_description $gray
