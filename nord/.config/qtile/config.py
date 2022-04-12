import os
import subprocess

from colors import colors
from screens import screens

from os import environ

from libqtile.config import (
    # KeyChord,
    Key,
    # Screen,
    Group,
    Drag,
    Click,
    ScratchPad,
    DropDown,
    Match,
)

from libqtile.command import lazy
from libqtile import layout, bar, widget, hook
from libqtile.lazy import lazy

# from libqtile import qtile
# from typing import List  # noqa: F401
from custom.bsp import Bsp as CustomBsp
from custom.bsp import Bsp as CustomBspMargins
from custom.zoomy import Zoomy as CustomZoomy

# from custom.stack import Stack as CustomStack
# from custom.windowname import WindowName as CustomWindowName

mod = "mod4"
mod1 = "mod1"
terminal = "kitty"


@hook.subscribe.client_new
def floating_dialogs(window):
    dialog = window.window.get_wm_type() == "tk"
    transient = window.window.get_wm_transient_for()
    if dialog or transient:
        window.floating = True


@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser("~/.config/qtile/autostart.sh")
    subprocess.call([home])


# Resize functions for bsp layout
def resize(qtile, direction):
    layout = qtile.current_layout
    child = layout.current
    parent = child.parent

    while parent:
        if child in parent.children:
            layout_all = False

            if (direction == "left" and parent.split_horizontal) or (
                direction == "up" and not parent.split_horizontal
            ):
                parent.split_ratio = max(5, parent.split_ratio - layout.grow_amount)
                layout_all = True
            elif (direction == "right" and parent.split_horizontal) or (
                direction == "down" and not parent.split_horizontal
            ):
                parent.split_ratio = min(95, parent.split_ratio + layout.grow_amount)
                layout_all = True

            if layout_all:
                layout.group.layout_all()
                break

        child = parent
        parent = child.parent


@lazy.function
def resize_left(qtile):
    resize(qtile, "left")


@lazy.function
def resize_right(qtile):
    resize(qtile, "right")


@lazy.function
def resize_up(qtile):
    resize(qtile, "up")


@lazy.function
def resize_down(qtile):
    resize(qtile, "down")


keys = [
    # Launching dmenu with custom settings
    # 'dmenu_height' package from aur needed for 'dmenu_height' argument
    Key(
        [mod],
        "d",
        lazy.spawn("dmenu_run_history"),
    ),
    Key(
        [mod],
        "p",
        lazy.spawn("rofi -show drun"),
    ),
    Key(
        [mod],
        "w",
        lazy.spawn("rofi -show window"),
    ),
    Key(
        [mod],
        "Return",
        lazy.spawn(terminal + " --single-instance -e fish"),
        desc="Launch terminal",
    ),
    Key(
        [mod, "shift"],
        "Return",
        lazy.spawn("alacritty"),
        desc="Launch terminal",
    ),
    Key(
        [mod, mod1],
        "Return",
        lazy.spawn("wezterm"),
        desc="Launch terminal",
    ),
    Key(
        [mod],
        "Tab",
        lazy.next_layout(),
        desc="Toggle through layouts",
    ),
    Key(
        [mod, "shift"],
        "Tab",
        lazy.prev_layout(),
        desc="Toggle through layouts",
    ),
    Key(
        [mod],
        "b",
        lazy.hide_show_bar("top"),
        desc="Kill focused window",
    ),
    Key(
        [mod],
        "q",
        lazy.window.kill(),
        desc="Kill focused window",
    ),
    Key(
        [mod, "shift"],
        "q",
        lazy.spawn("xkill"),
        desc="Force kill window",
    ),
    Key(
        [mod, "shift"],
        "r",
        lazy.restart(),
        desc="Restart Qtile",
    ),
    Key(
        [mod, "shift"],
        "Escape",
        lazy.shutdown(),
        desc="Shutdown Qtile",
    ),
    Key(
        [mod, "shift"],
        "a",
        lazy.spawn("glrnvim /home/ayamir/.config/qtile/config.py"),
        desc="Config qtile",
    ),
    Key(
        [mod],
        "e",
        lazy.spawn("firefox"),
        desc="Launches firefox",
    ),
    Key(
        [mod, "shift"],
        "n",
        lazy.spawn("nemo"),
        desc="Launches Nemo",
    ),
    Key(
        [mod, "shift"],
        "m",
        lazy.spawn("alacritty --class ncmpcpp -e ncmpcpp"),
        desc="Launches Ncmpcpp",
    ),
    Key(
        [mod, "control"],
        "l",
        lazy.spawn("switch l"),
        desc="Switch theme to light",
    ),
    Key(
        [mod, "control"],
        "n",
        lazy.spawn("switch n"),
        desc="Switch theme to dark",
    ),
    Key(
        [mod, "control"],
        "t",
        lazy.spawn("toggle_wall"),
        desc="Toggle paperview and picom",
    ),
    Key(
        [mod, "control"],
        "p",
        lazy.spawn("mpc toggle"),
        desc="Play mpd music",
    ),
    Key(
        [mod, "control"],
        "Left",
        lazy.spawn("mpc prev"),
        desc="Mpd music previous",
    ),
    Key(
        [mod, "control"],
        "Right",
        lazy.spawn("mpc next"),
        desc="Mpd music next",
    ),
    Key(
        [mod],
        "r",
        lazy.spawn("recordmenu"),
        desc="Start record",
    ),
    Key(
        [mod],
        "v",
        lazy.spawn("glrnvim"),
        desc="Launches glrnvim",
    ),
    Key(
        [mod],
        "z",
        lazy.spawn("zathura"),
        desc="Launches zathura",
    ),
    Key(
        [mod1],
        "v",
        lazy.spawn("neovide"),
        desc="Launches neovide",
    ),
    Key(
        [mod1],
        "c",
        lazy.spawn("clion"),
        desc="Launches clion",
    ),
    Key(
        [mod1],
        "i",
        lazy.spawn("idea"),
        desc="Launches idea",
    ),
    Key(
        [mod1],
        "p",
        lazy.spawn("pycharm"),
        desc="Launches pycharm",
    ),
    Key(
        [mod1],
        "g",
        lazy.spawn("goland"),
        desc="Launches goland",
    ),
    # Window controls
    Key(
        [mod],
        "j",
        lazy.layout.down(),
        desc="Move focus down in current stack pane",
    ),
    Key(
        [mod],
        "k",
        lazy.layout.up(),
        desc="Move focus up in current stack pane",
    ),
    Key(
        [mod],
        "h",
        lazy.layout.left(),
        lazy.layout.next(),
        desc="Move focus left in current stack pane",
    ),
    Key(
        [mod],
        "l",
        lazy.layout.right(),
        lazy.layout.previous(),
        desc="Move focus right in current stack pane",
    ),
    Key(
        [mod, "shift"],
        "j",
        lazy.layout.shuffle_down(),
        desc="Move windows down in current stack",
    ),
    Key(
        [mod, "shift"],
        "k",
        lazy.layout.shuffle_up(),
        desc="Move windows up in current stack",
    ),
    Key(
        [mod, "shift"],
        "h",
        lazy.layout.shuffle_left(),
        lazy.layout.swap_left(),
        lazy.layout.client_to_previous(),
        desc="Move windows left in current stack",
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        lazy.layout.swap_right(),
        lazy.layout.client_to_next(),
        desc="Move windows right in the current stack",
    ),
    Key(
        [mod, mod1],
        "j",
        lazy.layout.flip_down(),
        desc="Flip layout down",
    ),
    Key(
        [mod, mod1],
        "k",
        lazy.layout.flip_up(),
        desc="Flip layout up",
    ),
    Key(
        [mod, mod1],
        "h",
        lazy.layout.flip_left(),
        desc="Flip layout left",
    ),
    Key(
        [mod, mod1],
        "l",
        lazy.layout.flip_right(),
        desc="Flip layout right",
    ),
    Key(
        [mod],
        "comma",
        resize_left,
        desc="Resize window left",
    ),
    Key(
        [mod],
        "period",
        resize_right,
        desc="Resize window Right",
    ),
    Key(
        [mod],
        "semicolon",
        resize_up,
        desc="Resize windows upward",
    ),
    Key(
        [mod],
        "apostrophe",
        resize_down,
        desc="Resize windows downward",
    ),
    Key(
        [mod],
        "n",
        lazy.layout.normalize(),
        desc="Normalize window size ratios",
    ),
    Key(
        [mod],
        "m",
        lazy.layout.maximize(),
        desc="Toggle window between minimum and maximum sizes",
    ),
    Key(
        [mod, "control"], "k", lazy.layout.section_up()  # Move up a section in treetab
    ),
    Key(
        [mod, "control"],
        "j",
        lazy.layout.section_down(),  # Move down a section in treetab
    ),
    Key(
        [mod, "shift"],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen",
    ),
    Key(
        [mod],
        "f",
        lazy.window.toggle_floating(),
        desc="Toggle floating on focused window",
    ),
    # Stack controls
    # Key(
    #     [mod],
    #     "f",
    #     lazy.layout.rotate(),
    #     lazy.layout.flip(),
    #     desc="Switch which side main pane occupies {MonadTall}",
    # ),
    # Key(
    #     [mod],
    #     "s",
    #     lazy.layout.toggle_split(),
    #     desc="Toggle between split and unsplit sides of stack",
    # ),
    # Shot Screen
    Key(
        [mod, "shift"],
        "s",
        lazy.spawn("flameshot gui"),
        desc="Launches flameshot",
    ),
    Key(
        [],
        "Print",
        lazy.spawn("flameshot screen -n 0 -c"),
        desc="Shot display 0",
    ),
    Key(
        [mod],
        "Print",
        lazy.spawn("flameshot screen -n 1 -c"),
        desc="Shot display 1",
    ),
    # Audio bindings specifically for Logitech G915 media buttons
    Key(
        [],
        "XF86AudioNext",
        lazy.spawn("playerctl next"),
        desc="Play next audio",
    ),
    Key(
        [],
        "XF86AudioPlay",
        lazy.spawn("playerctl play-pause"),
        desc="Toggle play/pause audio",
    ),
    Key(
        [],
        "XF86AudioPrev",
        lazy.spawn("playerctl previous"),
        desc="Play previous audio",
    ),
    Key(
        [],
        "XF86AudioMute",
        lazy.spawn("amixer -q -D pulse sset Master toggle"),
        desc="Mute audio",
    ),
    Key(
        [],
        "XF86AudioRaiseVolume",
        lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +1%"),
        desc="Raise volume",
    ),
    Key(
        [],
        "XF86AudioLowerVolume",
        lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -1%"),
        desc="Lower volume",
    ),
    Key(
        [mod],
        "grave",
        lazy.group["scratchpad"].dropdown_toggle("term"),
        desc="Toggle scratchpad",
    ),
]

# Command to find out wm_class of window: xprop | grep WM_CLASS
workspaces = [
    {
        "name": "1",
        "key": "1",
        "label": "",
        "layout": "bsp",
        "matches": [
            Match(wm_class="solaar"),
        ],
        "spawn": ["solaar"],
    },
    {
        "name": "2",
        "key": "2",
        "label": "",
        "layout": "bsp",
        "matches": [
            Match(wm_class="jetbrains-idea"),
            Match(wm_class="jetbrains-pycharm"),
            Match(wm_class="jetbrains-clion"),
            Match(wm_class="jetbrains-goland"),
        ],
        "spawn": [],
    },
    {
        "name": "3",
        "key": "3",
        "label": "",
        "layout": "bsp",
        "matches": [
            Match(wm_class="microsoft-edge"),
            Match(wm_class="google-chrome"),
            Match(wm_class="firefox"),
        ],
        "spawn": ["google-chrome-stable"],
    },
    {
        "name": "4",
        "key": "4",
        "label": "",
        "layout": "max",
        "matches": [
            Match(wm_class="spotify"),
            Match(wm_class="ncmpcpp"),
            Match(wm_class="yesplaymusic"),
            Match(wm_class="netease-cloud-music"),
        ],
        "spawn": [],
    },
    {
        "name": "5",
        "key": "5",
        "label": "",
        "layout": "bsp",
        "matches": [
            Match(wm_class="Steam"),
        ],
        "spawn": [],
    },
    {
        "name": "6",
        "key": "6",
        "label": "",
        "layout": "max",
        "matches": [
            Match(wm_class="VirtualBox Manager"),
            Match(wm_class="VirtualBox Machine"),
            Match(wm_class="Vmware"),
            Match(wm_class="freechat"),
        ],
        "spawn": [],
    },
    {
        "name": "7",
        "key": "7",
        "label": "",
        "layout": "max",
        "matches": [
            Match(wm_class="icalingua"),
        ],
        "spawn": ["icalingua"],
    },
    {
        "name": "8",
        "key": "8",
        "label": "",
        "layout": "max",
        "matches": [
            Match(wm_class="TelegramDesktop"),
        ],
        "spawn": ["telegram-desktop"],
    },
    {
        "name": "9",
        "key": "9",
        "label": "",
        "layout": "floating",
        "matches": [
            Match(wm_class="qbittorrent"),
            Match(wm_class="postman"),
            Match(wm_class="xdman-Main"),
        ],
        "spawn": ["qbittorrent"],
    },
]

groups = []
for workspace in workspaces:
    matches = workspace["matches"] if "matches" in workspace else None
    groups.append(
        Group(
            workspace["name"],
            matches=matches,
            layout=workspace["layout"],
            spawn=workspace["spawn"],
            label=workspace["label"],
        )
    )
    keys.append(
        Key(
            [mod],
            workspace["key"],
            lazy.group[workspace["name"]].toscreen(),
            desc="Focus certain workspace",
        )
    )
    keys.append(
        Key(
            [mod, "shift"],
            workspace["key"],
            lazy.window.togroup(workspace["name"]),
            desc="Move focused window to another workspace",
        )
    )

groups.append(
    ScratchPad(
        "scratchpad",
        [
            DropDown(
                "term",
                "wezterm",
                x=0.7,
                y=0.01,
                width=0.3,
                height=0.3,
                on_focus_lost_hide=False,
            ),
        ],
    )
)

layout_theme = {
    "border_width": 3,
    "margin": 5,
    "border_focus": "3b4252",
    "border_normal": "3b4252",
    "font": "FiraCode Nerd Font",
    "grow_amount": 4,
}

layout_theme_margins = {
    "name": "bsp-margins",
    "border_width": 3,
    "margin": [150, 300, 150, 300],
    "border_focus": "3b4252",
    "border_normal": "3b4252",
    "font": "FiraCode Nerd Font",
    "grow_amount": 4,
}

layout_audio = {
    "name": "monadwide-audio",
    "border_width": 3,
    "margin": 100,
    "border_focus": "3b4252",
    "border_normal": "3b4252",
    "font": "FiraCode Nerd Font",
    "ratio": 0.65,
    "new_client_position": "after_current",
}

layouts = [
    # layout.Bsp(**layout_theme, fair=False),
    CustomBsp(**layout_theme, fair=False),
    layout.Max(**layout_theme),
    layout.TreeTab(
        **layout_theme,
        active_bg=colors[1],
        active_fg=colors[0],
        bg_color=colors[1],
        fontsize=16,
        inactive_bg=colors[1],
        inactive_fg=colors[0],
        sections=["", "", ""],
        section_fontsize=18,
        section_fg=colors[0],
    ),
    layout.MonadTall(**layout_theme),
    layout.MonadWide(**layout_theme),
    layout.Floating(
        float_rules=[
            Match(wm_type="utility"),
            Match(wm_type="notification"),
            Match(wm_type="toolbar"),
            Match(wm_type="splash"),
            Match(wm_type="dialog"),
            Match(wm_class="file_progress"),
            Match(wm_class="confirm"),
            Match(wm_class="dialog"),
            Match(wm_class="download"),
            Match(wm_class="error"),
            Match(wm_class="notification"),
            Match(wm_class="splash"),
            Match(wm_class="toolbar"),
            Match(func=lambda c: c.has_fixed_size()),
            Match(func=lambda c: c.has_fixed_ratio()),
            Match(wm_class="xdman-Main"),
            Match(wm_class="nitrogen"),
            Match(wm_class="lxappearance"),
        ],
        **layout_theme,
    ),
    # layout.Columns(
    #    **layout_theme,
    #    border_on_single=True,
    #    num_columns=3,
    #    # border_focus_stack=colors[2],
    #    # border_normal_stack=colors[2],
    #    split=False,
    # ),
    # layout.RatioTile(**layout_theme),
    # layout.VerticalTile(**layout_theme),
    # layout.Matrix(**layout_theme, columns=3),
    # layout.Slice(**layout_theme),
    # layout.Tile(shift_windows=True, **layout_theme),
    # CustomBspMargins(**layout_theme_margins),
]

# Setup bar

widget_defaults = dict(
    font="JetBrainsMono Nerd Font Mono Medium",
    fontsize=25,
    padding=3,
    background=colors[0],
)
extension_defaults = widget_defaults.copy()

# Drag floating layouts.
mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
main = None  # WARNING: this is deprecated and will be removed soon
follow_mouse_focus = True
bring_front_click = "floating_only"
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "focus"

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "compiz"
