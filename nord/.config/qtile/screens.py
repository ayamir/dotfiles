import os
import subprocess

from libqtile.config import (
    # KeyChord,
    # Key,
    Screen,
    # Group,
    # Drag,
    # Click,
    # ScratchPad,
    # DropDown,
    # Match,
)
from libqtile.command import lazy
from libqtile import bar, widget  # , hook, layout

# from libqtile.lazy import lazy
from libqtile import qtile

# from custom.bsp import Bsp as CustomBsp
# from custom.zoomy import Zoomy as CustomZoomy
# from custom.stack import Stack as CustomStack
from custom.windowname import WindowName as CustomWindowName

from colors import colors

terminal = "kitty"


def open_pavu():
    qtile.cmd_spawn("pavucontrol")


group_box_settings = {
    "padding": 3,
    "borderwidth": 4,
    "active": colors[9],
    "inactive": colors[10],
    "disable_drag": True,
    "rounded": True,
    "highlight_color": colors[2],
    "block_highlight_text_color": colors[8],
    "highlight_method": "block",
    "this_current_screen_border": colors[1],
    "this_screen_border": colors[7],
    "other_current_screen_border": colors[1],
    "other_screen_border": colors[1],
    "foreground": colors[0],
    "background": colors[1],
    "urgent_border": colors[3],
}

text_size = 25
icon_size = 25

screens = [
    Screen(
        wallpaper="~/Pictures/qtile/wallpaper.png",
        wallpaper_mode="fill",
        top=bar.Bar(
            [
                widget.Sep(
                    linewidth=0,
                    background=colors[1],
                    padding=30,
                    size_percent=40,
                ),
                widget.TextBox(
                    background=colors[1],
                    foreground=colors[0],
                    fontsize=25,
                    font="JetBrainsMono Nerd Font",
                    text="望 ",
                    mouse_callbacks={
                        "Button1": lambda: qtile.cmd_spawn("toggle_all"),
                    },
                ),
                widget.GroupBox(
                    **group_box_settings,
                    fontsize=20,
                ),
                widget.Sep(
                    linewidth=0,
                    background=colors[1],
                    padding=10,
                    size_percent=40,
                ),
                widget.CurrentLayoutIcon(
                    custom_icon_paths=[os.path.expanduser("~/.config/qtile/icons")],
                    foreground=colors[8],
                    background=colors[1],
                    padding=-2,
                    scale=0.45,
                ),
                widget.TextBox(
                    background=colors[1],
                    foreground=colors[3],
                    text="",
                    font="Font Awesome 5 Free Solid",
                    padding=15,
                ),
                CustomWindowName(
                    background=colors[1],
                    foreground=colors[0],
                    width=bar.CALCULATED,
                    empty_group_string="Desktop",
                    max_chars=40,
                ),
                widget.Spacer(background=colors[1]),
                widget.Sep(
                    linewidth=0,
                    padding=10,
                    size_percent=50,
                    background=colors[1],
                ),
                widget.TextBox(
                    background=colors[1],
                    foreground=colors[11],
                    text=" ",
                    font="Font Awesome 5 Free Solid",
                    fontsize=icon_size,
                ),
                widget.Net(background=colors[1], foreground=colors[0], format="{down}"),
                widget.Sep(
                    linewidth=0,
                    padding=10,
                    size_percent=50,
                    background=colors[1],
                ),
                widget.TextBox(
                    background=colors[1],
                    foreground=colors[8],
                    text=" ",
                    font="Font Awesome 5 Free Solid",
                    fontsize=icon_size,
                ),
                widget.PulseVolume(
                    background=colors[1],
                    foreground=colors[0],
                    limit_max_volume="True",
                    update_interval=0.1,
                    mouse_callbacks={"Button3": open_pavu},
                    fontsize=text_size,
                ),
                widget.Sep(
                    background=colors[1],
                    linewidth=0,
                    padding=10,
                    size_percent=50,
                ),
                widget.TextBox(
                    background=colors[1],
                    foreground=colors[7],
                    text="",
                    font="Font Awesome 5 Free Solid",
                    fontsize=icon_size,
                ),
                widget.CPU(
                    background=colors[1],
                    foreground=colors[0],
                    update_interval=1,
                    format="{load_percent: .0f} %",
                    fontsize=text_size,
                ),
                widget.Sep(
                    background=colors[1],
                    linewidth=0,
                    padding=10,
                    size_percent=50,
                ),
                widget.TextBox(
                    text="",
                    font="Font Awesome 5 Free Solid",
                    background=colors[1],
                    foreground=colors[6],
                    fontsize=icon_size,
                ),
                widget.Memory(
                    background=colors[1],
                    foreground=colors[0],
                    format="{MemPercent: .0f} %",
                    fontsize=text_size,
                ),
                widget.Sep(
                    background=colors[1],
                    linewidth=0,
                    padding=10,
                    size_percent=50,
                ),
                widget.TextBox(
                    background=colors[1],
                    foreground=colors[5],
                    text=" ",
                    font="Font Awesome 5 Free Solid",
                    fontsize=icon_size,
                ),
                widget.Battery(
                    background=colors[1],
                    foreground=colors[0],
                    format="{percent:2.0%}",
                    fontsize=text_size,
                ),
                widget.Sep(
                    background=colors[1],
                    linewidth=0,
                    padding=10,
                    size_percent=50,
                ),
                widget.TextBox(
                    background=colors[1],
                    foreground=colors[4],
                    text=" ",
                    font="Font Awesome 5 Free Solid",
                    fontsize=icon_size,
                ),
                widget.Clock(
                    background=colors[1],
                    foreground=colors[0],
                    format="%m/%d %A %H:%M:%S",
                    fontsize=text_size,
                ),
                widget.Sep(
                    background=colors[1],
                    linewidth=0,
                    padding=25,
                    size_percent=50,
                ),
            ],
            50,
            margin=[0, -10, 5, -10],
        ),
        bottom=bar.Gap(5),
        left=bar.Gap(5),
        right=bar.Gap(5),
    ),
    Screen(
        wallpaper="~/Pictures/qtile/wallpaper.png",
        wallpaper_mode="fill",
        top=bar.Bar(
            [
                widget.Sep(
                    linewidth=0,
                    background=colors[1],
                    padding=30,
                    size_percent=40,
                ),
                widget.TextBox(
                    background=colors[1],
                    foreground=colors[0],
                    fontsize=20,
                    font="JetBrainsMono Nerd Font",
                    text="望 ",
                    mouse_callbacks={
                        "Button1": lambda: qtile.cmd_spawn("toggle_all"),
                    },
                ),
                widget.GroupBox(
                    **group_box_settings,
                    fontsize=20,
                ),
                widget.Sep(
                    linewidth=0,
                    background=colors[1],
                    padding=10,
                    size_percent=40,
                ),
                widget.CurrentLayoutIcon(
                    custom_icon_paths=[os.path.expanduser("~/.config/qtile/icons")],
                    foreground=colors[8],
                    background=colors[1],
                    padding=-2,
                    scale=0.45,
                ),
                widget.Sep(
                    linewidth=0,
                    background=colors[1],
                    padding=10,
                    size_percent=50,
                ),
                widget.Systray(
                    padding=10,
                    foreground=colors[8],
                    background=colors[1],
                    icon_size=icon_size,
                ),
                widget.Sep(
                    linewidth=0,
                    background=colors[1],
                    padding=10,
                    size_percent=50,
                ),
                widget.TextBox(
                    background=colors[1],
                    foreground=colors[3],
                    text="",
                    font="Font Awesome 5 Free Solid",
                    fontsize=icon_size,
                    padding=15,
                ),
                CustomWindowName(
                    background=colors[1],
                    foreground=colors[0],
                    width=bar.CALCULATED,
                    empty_group_string="Desktop",
                    max_chars=40,
                ),
                widget.Spacer(background=colors[1]),
                widget.Sep(
                    linewidth=0,
                    padding=10,
                    size_percent=50,
                    background=colors[1],
                ),
                widget.OpenWeather(
                    background=colors[1],
                    foreground=colors[0],
                    app_key="eaf0bf95962bd42471d02500acc89aa1",
                    cityid="1812537",
                    language="zh_cn",
                    format="{main_temp}°{units_temperature} {humidity}% {weather_details}",
                ),
                widget.Sep(
                    background=colors[1],
                    linewidth=0,
                    padding=25,
                    size_percent=50,
                ),
                widget.TextBox(
                    background=colors[1],
                    foreground=colors[4],
                    text=" ",
                    font="Font Awesome 5 Free Solid",
                    fontsize=icon_size,
                ),
                widget.Clock(
                    background=colors[1],
                    foreground=colors[0],
                    format="%m/%d %A %H:%M:%S",
                    fontsize=text_size,
                ),
                widget.Sep(
                    background=colors[1],
                    linewidth=0,
                    padding=25,
                    size_percent=50,
                ),
            ],
            50,
            margin=[0, -10, 5, -10],
        ),
        bottom=bar.Gap(5),
        left=bar.Gap(5),
        right=bar.Gap(5),
    ),
]
