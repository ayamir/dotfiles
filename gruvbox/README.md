
# Table of Contents

1.  [My Own Dwm Config](#org27716e3)
    1.  [Intro](#intro)
    2.  [Color Scheme](#org4976554)
    3.  [Patches](#org2026491)
    4.  [Keybinding](#orgdf423ab)
    5.  [Dependency](#dependency)
    6.  [Usage](#usage)
    7.  [Other](#org1958ae2)
        1.  [Recompile](#org3f8fde8)
        2.  [Xsessions](#org1745859)
        3.  [Switch](#switch)
        4.  [Telegram Themes](#tg)
        5.  [Fcitx5 Themes](#fcitx5)
        6.  [Browser Themes](#browser)
    8.  [Credits](#credits)


<a id="org27716e3"></a>

# My Own Dwm Config

<a id="intro"></a>

## Intro

This repo collects app's gruvbox theme. 

I will switch my color scheme to Nord sometimes, so this repo's update might not in time.

So you can also see [this repo](https://github.com/ayamir/nord-and-light) to get my Nord configs.

<a id="org4976554"></a>

## Color Scheme

Gruvbox

![apps](./shot/apps.png)

![desktop](./shot/desktop.png)

<a id="org2026491"></a>

## Patches

You can see all of 8 patches I have applied in `.dwm/patches` dir.

-   dwm-00-regex-rules.diff
    
    to enable `config.def.h` 's regex rules

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


<a id="orgdf423ab"></a>

## Keybinding

You can see all of keybindings in `.dwm/config.def.h` clearly.

<a id="dependency"></a>

## Dependency

+ Launcher: dmenu
+ Terminal: alacritty&kitty
+ Editor: 
  + vim
  + doom emacs
  + vscode
  + sublime-text-nightly
+ Compositor: picom-jonaburg-git
+ Shell: fish
+ PDF reader: zathura
+ Player: mpd&ncmpcpp
+ Window switcher: rofi
+ Notification daemon: dunst
+ Theme controler: xsettingsd
+ Gtk themes:
  + Light: [Pop-gruvbox](./usr/share/themes/Pop-gruvbox)
  + Dark: [Gruvbox-Material-Dark](./usr/share/themes/Gruvbox-Material-Dark)
+ Qt themes:
  + use `qt5ct` and `qt5-styleplugins` to set qt theme follow gtk2 theme
+ Icon theme: [Material-Originals-dark](./usr/share/icons/Material-Originals-dark)

<a id="usage"></a>

## Usage
1. Backup all of your old config files.
2. Install apps metioned in [Dependency](#dependency)
3. Copy all my config files to corresponding directories follow my repo's structure.


<a id="org1958ae2"></a>

## Other

<a id="org3f8fde8"></a>

### Recompile

The script called `recompile` need your user can execute `sudo` command without password.

<a id="org1745859"></a>

### Xsessions

Execute `recompile` script first.

Then add xsession file manually.

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

<a id="switch"></a>

### Switch

The simple script in `.local/bin/` called `switch-gruvbox` can switch `gruvbox-light` and `gruvbox-dark` theme through a shortcut defined in `.dwm/config.def.h`.

All of details about how to switch you can see in it.

<a id="tg"></a>

### Telegram Themes

Please refer this: [Gruvbox-Tg](https://github.com/ayamir/Gruvbox-Tg)

<a id="fcitx5"></a>

### Fcitx5 Themes

Please refer this: [Gruvbox-Fcitx5](https://github.com/ayamir/fcitx5-gruvbox)

<a id="browser"></a>

### Browser Themes

Set your browser just use default GTK theme.

You can use `Dark Reader` extension to realize web pages' gruvbox color.

![browser](./shot/browser.png)

<a id="credits"></a>

## Credits

My Pop-gruvbox theme is a fork of [Pop-gruvbox](https://github.com/salimundo/Pop-gruvbox) with topbar's color changed to yellow.
