#include <X11/XF86keysym.h>

/* See LICENSE file for copyright and license details. */

/* appearance */
static const unsigned int borderpx  = 2;        /* border pixel of windows */
static const unsigned int gappx     = 5;        /* gaps between windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
/*  Display modes of the tab bar: never shown, always shown, shown only in  */
/*  monocle mode in the presence of several windows.                        */
/*  Modes after showtab_nmodes are disabled.                                */
enum showtab_modes { showtab_never, showtab_auto, showtab_nmodes, showtab_always};
static const int showtab			= showtab_auto;        /* Default tab bar show mode */
static const int toptab				= False;               /* False means bottom tab bar */

static const char *fonts[]     = {"RobotoMono:size=9:antialias=true:autohint=true",
                                  "Hack Nerd Font:size=8:antialias=true:autohint=true",
                                  "Sarasa UI SC:size=8:antialias=true:autohint=true",
                                  "JoyPixels:size=10:antialias=true:autohint=true"
						     	};
static const char dmenufont[]       = "Sarasa UI SC:size=10:antialias=true:autohint=true";

static const char col_gray1[]       = "#fdf1c7";
static const char col_gray2[]       = "#ebdbb2";
static const char col_gray3[]       = "#3c3836";
static const char col_gray4[]       = "#282828";
static const char col_cyan[]        = "#fabd2f";

static const char *colors[][3]      = {
	/*               fg         bg         border   */
	[SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
	[SchemeSel]  = { col_gray4, col_cyan,  col_cyan  },
};

/* tagging */
//static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };
static const char *tags[] = { "", "", "", "", "", "", "", "", "" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class                            instance                    title               tags mask     isfloating   monitor */
	{ "jetbrains-*",                    "JetBrains Toolbox",        NULL,               1 << 1,       1,           -1 },
	{ "jetbrains-*",                    "sun-awt-X11-XFramePeer",   NULL,               1 << 1,       0,           -1 },
	{ "jetbrains-*",                    "jetbrains-*",              "win0",             1 << 1,       1,           -1 },
	{ "jetbrains-*",                    NULL,                       "Welcome to*",      1 << 1,       1,           -1 },
    { "Google-chrome",                 "google-chrome",             NULL,               1 << 2,       0,           -1 },
	{ "Vivaldi-stable",                 "vivaldi-stable",           NULL,               1 << 2,       0,           -1 },
	{ "FirefoxNightly",                 NULL,                       NULL,               1 << 2,       0,           -1 },
	{ "Nightly",                        NULL,                       NULL,               1 << 2,       0,           -1 },
	{ "Navigator",                      "Nightly",                  NULL,               1 << 2,       0,           -1 },
	{ "Alacritty",                      "kitty-music",              NULL,               1 << 3,       0,           -1 },
	{ "kitty-music",                    NULL,                       NULL,               1 << 3,       0,           -1 },
	{ "qqmusic",                        NULL,                       NULL,               1 << 3,       0,           -1 },
	{ "Spotify",                        "spotify",                  NULL,               1 << 3,       0,           -1 },
	{ "netease-cloud-music",            NULL,                       NULL,               1 << 3,       0,           -1 },
	{ "Steam",                          NULL,                       NULL,               1 << 4,       0,           -1 },
	{ "VirtualBox Machine",             NULL,                       NULL,               1 << 5,       0,           -1 },
	{ "Alacritty",                      "Alacritty",                NULL,               1 << 6,       0,           -1 },
	{ "Qq",                             "qq",                       NULL,               1 << 6,       1,           -1 },
	{ "Freechat",                       "freechat",                 NULL,               1 << 6,       0,           -1 },
	{ "TelegramDesktop",                NULL,                       NULL,               1 << 7,       0,           -1 },
	{ "qv2ray",                         NULL,                       NULL,               1 << 8,       0,           -1 },
	{ NULL,                             "kitty-reload",             NULL,               1 << 8,       0,           -1 },

	{ "xdman-Main",                     NULL,                       NULL,               0,            1,           -1 },
	{ "Nitrogen",                       NULL,                       NULL,               0,            1,           -1 },
	{ "lxappearance",                   NULL,                       NULL,               0,            1,           -1 },
};

/* layout(s) */
static const float mfact     = 0.50; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */

#include "layouts.c"
static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default */
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
	{ "HHH",      grid },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }
#define CMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }


/* commands */
static char dmenumon[3] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *windowswitchcmd[] = { "rofi", "-show", "window", NULL };
static const char *clipmenucmd[]    = { "clipmenu", "-i", "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray4, "-sb", col_cyan, "-sf", col_gray2, NULL};
static const char *dmenucmd[]    = { "dmenu_run_history", "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray4, "-sb", col_cyan, "-sf", col_gray2, NULL};
static const char *termcmd[]  = { "kitty", "--single-instance", NULL };

static const char *upvol[]   = { "/usr/bin/pactl", "set-sink-volume", "0", "+3%",     NULL };
static const char *downvol[] = { "/usr/bin/pactl", "set-sink-volume", "0", "-3%",     NULL };
static const char *mutevol[] = { "/usr/bin/pactl", "set-sink-mute",   "0", "toggle",  NULL };

static Key keys[] = {
	/* modifier                     key             function        argument */
	{ MODKEY,                       XK_d,           spawn,          {.v = dmenucmd } },
	{ MODKEY,                       XK_c,           spawn,          {.v = clipmenucmd } },
	{ MODKEY,                       XK_Return,      spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_w,           spawn,          {.v = windowswitchcmd } },
	{ MODKEY,                       XK_b,           togglebar,      {0} },
    { MODKEY|ControlMask,           XK_m,           focusmaster,    {0} },
	{ MODKEY,                       XK_j,           focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,           focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_i,           incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_o,           incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,           setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,           setmfact,       {.f = +0.05} },
	{ MODKEY|ControlMask,           XK_Return,      zoom,           {0} },
	{ MODKEY,                       XK_Tab,         view,           {0} },
	{ MODKEY,                       XK_q,           killclient,     {0} },
	{ MODKEY,                       XK_t,           setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_f,           setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_m,           setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                       XK_g,           setlayout,      {.v = &layouts[3]} },
	{ MODKEY,                       XK_space,       setlayout,      {0} },
	{ MODKEY|ShiftMask,             XK_space,       togglefloating, {0} },
	{ MODKEY,                       XK_0,           view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,           tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_comma,       focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period,      focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,       tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period,      tagmon,         {.i = +1 } },

    /* My Own App Start Ways */
    { Mod1Mask,                     XK_c,           spawn,          CMD("code") },
    { MODKEY,                       XK_e,           spawn,          CMD("google-chrome-stable") },
    { MODKEY,                       XK_z,           spawn,          CMD("zathura") },
    { MODKEY|ShiftMask,             XK_Return,      spawn,          CMD("alacritty") },
    { MODKEY|ShiftMask,             XK_q,           spawn,          CMD("xkill") },
    { MODKEY|ShiftMask,             XK_s,           spawn,          CMD("flameshot gui") },
    { MODKEY|ShiftMask,             XK_n,           spawn,          CMD("thunar") },
    { MODKEY|ShiftMask,             XK_m,           spawn,          CMD("alacritty --class kitty-music -e ncmpcpp") },
    { MODKEY|ShiftMask,             XK_h,           spawn,          CMD("alacritty -e htop") },
    { MODKEY|ShiftMask,             XK_e,           spawn,          CMD("emacs") },
    { MODKEY|ShiftMask,             XK_v,           spawn,          CMD("VBoxManage startvm 'Windows7' --type gui") },

    { Mod1Mask|ControlMask,         XK_Delete,      spawn,          CMD("betterlockscreen -l") },
    { Mod1Mask|ControlMask,         XK_s,           spawn,          CMD("systemctl suspend") },

    /*IDE start*/
    { Mod1Mask,                     XK_i,           spawn,          CMD("idea") },
    { Mod1Mask,                     XK_l,           spawn,          CMD("clion") },
    { Mod1Mask,                     XK_p,           spawn,          CMD("pycharm") },
    { Mod1Mask,                     XK_a,           spawn,          CMD("studio") },
    { Mod1Mask,                     XK_g,           spawn,          CMD("goland") },

    /* Mpd control */
    { MODKEY|ControlMask,           XK_p,           spawn,          CMD("mpc toggle") },
    { MODKEY|ControlMask,           XK_Left,        spawn,          CMD("mpc prev") },
    { MODKEY|ControlMask,           XK_Right,       spawn,          CMD("mpc next") },

    /* Switch */
    { MODKEY|ControlMask,           XK_n,           spawn,          CMD("sh ~/.local/bin/switch-gruvbox n") },
    { MODKEY|ControlMask,           XK_l,           spawn,          CMD("sh ~/.local/bin/switch-gruvbox l") },

    /* Touchpad */
    { MODKEY|ControlMask,           XK_e,           spawn,          CMD("xinput enable 'DELL0828:00 06CB:7E7E Touchpad'")},
    { MODKEY|ControlMask,           XK_d,           spawn,          CMD("xinput disable 'DELL0828:00 06CB:7E7E Touchpad'")},

    /* XF86Keys */
	{ 0,            XF86XK_AudioMute,               spawn,          {.v = mutevol } },
	{ 0,            XF86XK_AudioLowerVolume,        spawn,          {.v = downvol } },
	{ 0,            XF86XK_AudioRaiseVolume,        spawn,          {.v = upvol   } },

	TAGKEYS(                        XK_1,                           0)
	TAGKEYS(                        XK_2,                           1)
	TAGKEYS(                        XK_3,                           2)
	TAGKEYS(                        XK_4,                           3)
	TAGKEYS(                        XK_5,                           4)
	TAGKEYS(                        XK_6,                           5)
	TAGKEYS(                        XK_7,                           6)
	TAGKEYS(                        XK_8,                           7)
	TAGKEYS(                        XK_9,                           8)
	{ MODKEY|ShiftMask,             XK_Escape,      quit,           {0} },
	{ MODKEY|ShiftMask,             XK_r,           quit,           {1} }, 
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
	{ ClkTabBar,            0,              Button1,        focuswin,       {0} },
};

