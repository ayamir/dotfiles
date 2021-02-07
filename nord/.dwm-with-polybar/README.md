
# Table of Contents

1.  [My Own Dwm Config](#org27716e3)
    1.  [Color Scheme](#org4976554)
    2.  [Patches](#org2026491)
    3.  [Keybinding](#orgdf423ab)
    4.  [Dependency](#dependency)
    5.  [Usage](#usage)
    6.  [Other](#org1958ae2)
        1.  [Xsessions config](#org1745859)
        2.  [Recompile](#org3f8fde8)
        3.  [Switch](#switch)
        4.  [Telegram Themes](#tg)
        5.  [Fcitx5 Themes](#fcitx5)
        6.  [Browser Themes](#browser)
    7.  [Credits](#credits)


<a id="org27716e3"></a>

# My Own Dwm Config


<a id="org4976554"></a>

## Color Scheme

Nord and Light

This directory use polybar as default bar which config is in `../.config/polybar`.

![Nord Dark](../Pictures/shot/dark-dwmpo.png)

![Nord Light](../Pictures/shot/light-dwmpo.png)


<a id="org2026491"></a>

## Patches

You can see all of 18 patches I have applied in `./patches` dir.

-   dwm-00-regex-rules.diff
    
    to enable `config.def.h` 's regex rules

-   dwm-anybar-polybar-tray-fix-20200810-bb2e722.diff

    use polybar as default bar

-   dwm-attachasideandbelow-20200702-f04cac6.diff

    new windows are spawned on the bottom of the stack

-   dwm-bottomstack-20160719-56a31dc.diff

    add two stack layout that master on top and other windows on bottom

-   dwm-gridmode-20170909-ceac8c9.diff
    
    add a grid layout

-   dwm-ipc-20201106-f04cac6.diff

    make polybar communicate with dwm

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

-   dwm-steam-6.2.diff

    with steam games' fix

-   dwm-xrdb-6.2.diff

    reload dwm color through `~/.Xresources`

-   tcl.c

    a new layout with a wide master panel centered on the screen.

<a id="orgdf423ab"></a>

## Keybinding

You can see all of keybindings in `./config.def.h` clearly.

<a id="dependency"></a>

## Dependency

+ Launcher: dmenu&rofi
+ Terminal: alacritty&kitty
+ Editor: 
  + vim
  + doom emacs
  + vscode
  + sublime-text-nightly
+ Compositor: picom-jonaburg-git
+ Shell: fish
+ Bar: polybar
+ PDF reader: zathura
+ Player: mpd&ncmpcpp
+ Window switcher: rofi
+ Notification daemon: dunst
+ Screen locker: i3lock-color
+ Theme controler: xsettingsd
+ Gtk themes:
  + Light: [Orchis-light](https://www.gnome-look.org/p/1357889/)
  + Dark: [Nordic](https://www.gnome-look.org/p/1267246/)
+ Qt themes:
  + use `qt5ct` and `qt5-styleplugins` to set qt theme follow gtk2 theme
+ Icon theme: [Papirus](https://www.gnome-look.org/p/1166289/)

<a id="usage"></a>

## Usage
1. Backup all of your old config files.
2. Install apps metioned in [Dependency](#dependency)
3. Copy all my config files to corresponding directories follow my repo's structure.


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

<a id="switch"></a>

### Switch

The simple script in `.local/bin/` called `switch-po` can switch `nord-light` and `nord-dark` theme through a shortcut defined in `.dwm/config.def.h`.

All of details about how to switch you can see in it.

<a id="tg"></a>

### Telegram Themes

Please refer this: [Nord-Tg](https://github.com/gilbertw1/telegram-nord-theme)

<a id="fcitx5"></a>

### Fcitx5 Themes

Please refer this: [Nord-Fcitx5](https://github.com/tonyfettes/fcitx5-nord)

<a id="browser"></a>

### Browser Themes

Set your browser just use default GTK theme.

You can use `Midnight Lizard` extension to realize web pages' nord color.

<a id="credits"></a>

## Credits

+ [Bento](https://github.com/MiguelRAvila/Bento) as my start page's template.
