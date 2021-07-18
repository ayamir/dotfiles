
# Table of Contents

1.  [My Own Dwm Config](#org27716e3)
    1.  [Color Scheme](#org4976554)
    2.  [Patches](#org2026491)
    3.  [Keybinding](#orgdf423ab)
    4.  [Other](#org1958ae2)
        1.  [Xsessions config](#org1745859)
        2.  [Recompile](#org3f8fde8)



<a id="org27716e3"></a>

# My Own Dwm Config


<a id="org4976554"></a>

## Color Scheme

Nord and Light


<a id="org2026491"></a>

## Patches

You can see all of 16 patches I have applied in `./patches` dir.

-   dwm-00-regex-rules.diff

    to enable `config.def.h` 's regex rules

-   dwm-attachasideandbelow-20200702-f04cac6.diff

    new windows are spawned on the bottom of the stack

-   dwm-bottomstack-20160719-56a31dc.diff

    add two stack layout that master on top and other windows on bottom

-   dwm-fullscreen-6.2.diff

    make window fullscreen

-   dwm-gridmode-20170909-ceac8c9.diff

    add a grid layout

-   dwm-6.2-tab-v2b.diff

    convert monocule layout to tab layout

-   dwm-restartsig-20180523-6.2.diff

    make dwm can restart through a shortcut

-   dwm-autostart-20200610-cb3f58a.diff

    enable autostart apps when dwm start or restart(my script ensures apps only start when dwm starts for the first time)

-   dwm-focusmaster-20200717-bb2e722.diff

    let you can focus master window through a shortcut

-   dwm-uselessgap-6.2.diff

    gap appears only two or more windows appear

-   dwm-focusonnetactive-6.2.diff

    automatically switch to urgent window

-   dwm-pertag-perseltag-6.2.diff

    maintain layout for pertag

-   dwm-status2d-6.2.diff

    allow color on dwm status

-   dwm-status2d-xrdb-6.2.diff

    status2d work with xrdb

-   dwm-xrdb-6.2.diff

    reload dwm color through `~/.Xresources`

-   tcl.c

    a new layout with a wide master panel centered on the screen.

<a id="orgdf423ab"></a>

## Keybinding

You can see all of keybindings in `./config.def.h` clearly.


<a id="org1958ae2"></a>

## Other


<a id="org1745859"></a>

### Xsessions config

Execute `recompile` script first.

Then

`sudo vim /usr/share/xsessions/dwm.desktop`

```shell
[Desktop Entry]
Encoding=UTF-8
Name=Dwm
Comment=Dynamic window manager
Exec=dwm
Icon=dwm
Type=XSession
```

<a id="org3f8fde8"></a>

### Recompile

The script called `recompile` need your user can execute `sudo` command without password.

