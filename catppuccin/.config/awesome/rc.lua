-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local theme_dir = os.getenv("HOME") .. "/.config/awesome/themes/default/"

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
local lain = require("lain")
-- Theme handling library
local beautiful = require("beautiful")
beautiful.init(theme_dir .. "theme.lua")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Autostart

-- Shell programs
local local_bin = os.getenv("HOME") .. "/.local/bin/"
local rofi_bin = os.getenv("HOME") .. "/.config/rofi/bin/"
local randr = local_bin .. "randr"
local picom = "picom -b --config " .. theme_dir .. "conf/picom.conf"
local autostart = local_bin .. "awesome-autostart"
local snotify = local_bin .. "snotify"
local restore_wall = "nitrogen --restore"
-- local random_wall = "python " .. local_bin .. "nitrogen_randomizer.py " .. theme_dir .. "2K"
local recordmenu = local_bin .. "recordmenu"
local pycharm = local_bin .. "pycharm"
local webstorm = local_bin .. "webstorm"
local dmenu_run = local_bin .. "dmenu_run_history"
local rofi_window = rofi_bin .. "rofi_window"
local rofi_launcher = rofi_bin .. "rofi_launcher"
local rofi_powermenu = rofi_bin .. "rofi_powermenu"

awful.spawn.with_shell(randr)
awful.spawn.with_shell(restore_wall)
awful.spawn.with_shell(picom)
awful.spawn.with_shell(snotify)
awful.spawn.with_shell(autostart)

-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.

-- This is used later as the default terminal and editor to run.
local terminal = "kitty"
local editor = os.getenv("EDITOR") or "nvim"
local editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey = "Mod4"
local altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.spiral.dwindle,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.fair,
	awful.layout.suit.max,
	awful.layout.suit.floating,
	-- awful.layout.suit.tile,
	-- awful.layout.suit.tile.left,
	-- awful.layout.suit.tile.top,
	-- awful.layout.suit.fair.horizontal,
	-- awful.layout.suit.max.fullscreen,
	-- awful.layout.suit.magnifier,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
local myawesomemenu = {
	{
		"hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end,
	},
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}

local editormenu = {
	{ "neovim", "kitty -e nvim" },
	{ "vscode", "vscode" },
}

local officemenu = {
	{ "Word", "wps" },
	{ "Excel", "et" },
	{ "Power Point", "wpp" },
}

local networkmenu = {
	{ "chrome", "google-chrome-stable" },
	{ "vivaldi", "vivaldi" },
}

local termmenu = {
	{ "st", "st" },
	{ "kitty", "kitty" },
}

local multimediamenu = {
	{ "yesplaymusic", "yesplaymusic" },
	{ "spotify", "spotify" },
	{ "ncmpcpp", "kitty --class music -e ncmpcpp" },
	{ "vlc", "vlc" },
	{ "pulseaudio", "pavucontrol" },
}

local settingsmenu = {
	{ "lxappearance", "lxappearance" },
	{ "wallpaper settings", "nitrogen" },
	{ "qt5 settings", "qt5ct" },
}

local utilsmenu = {
	{ "screenshot", "flameshot gui" },
	{ "screenkey", "screenkey" },
}

local myexitmenu = {
	{
		"logout",
		function()
			awesome.quit()
		end,
	},
	{ "reboot", "sudo systemctl reboot" },
	{ "suspend", "sudo systemctl suspend" },
	{ "shutdown", "sudo systemctl poweroff" },
}

local mymainmenu = awful.menu({
	items = {
		{ "editors", editormenu },
		{ "terms", termmenu },
		{ "network", networkmenu },
		{ "office", officemenu },
		{ "multimedia", multimediamenu },
		{ "settings", settingsmenu },
		{ "utils", utilsmenu },
		{ "awesome", myawesomemenu },
		{ "exit options", myexitmenu },
	},
})

local mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
-- Create a textclock widget
local mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 3, function()
		awful.menu.client_list({ theme = { width = 250 } })
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

local markup = lain.util.markup

local cpu = lain.widget.cpu({
	timeout = 1,
	settings = function()
		widget:set_markup(markup.fontfg(beautiful.font, beautiful.yellow, " " .. cpu_now.usage .. "%"))
	end,
})

local mem = lain.widget.mem({
	timeout = 1,
	settings = function()
		widget:set_markup(markup.fontfg(beautiful.font, beautiful.blue, " " .. mem_now.perc .. "%"))
	end,
})

local systray = wibox.widget.systray()

local vol = lain.widget.alsa({
	timeout = 1,
	settings = function()
		if volume_now.status == "off" then
			volume_now.level = "Muted"
			widget:set_markup(markup.fontfg(beautiful.font, beautiful.grey, "婢 " .. volume_now.level))
		else
			widget:set_markup(markup.fontfg(beautiful.font, beautiful.pink, "奔 " .. volume_now.level .. "% "))
		end
	end,
})

vol.widget:buttons(awful.util.table.join(
	awful.button({}, 1, function() -- left click
		awful.spawn("pamixer -t")
		vol.update()
	end),
	awful.button({}, 3, function() -- middle click
		awful.spawn("pavucontrol")
	end),
	awful.button({}, 4, function() -- scroll up
		awful.spawn("pamixer -i 3")
		vol.update()
	end),
	awful.button({}, 5, function() -- scroll down
		awful.spawn("pamixer -d 3")
		vol.update()
	end)
))

local mpris = require("themes.default.mpris")
local mpd = require("themes.default.mpdarc")
local spacer = wibox.widget.textbox(" ")

local tag1 = "  "
local tag2 = "  "
local tag3 = "  "
local tag4 = "  "
local tag5 = "  "
local tag6 = "  "
local tag7 = "  "
local tag8 = "  "
local tag9 = "  "

awful.screen.connect_for_each_screen(function(s)
	-- Each screen has its own tag table.
	awful.tag.add(tag1, {
		layout = awful.layout.layouts[1],
		master_fill_policy = "master_width_factor",
		screen = s,
		selected = true,
	})

	awful.tag.add(tag2, {
		layout = awful.layout.layouts[1],
		master_fill_policy = "master_width_factor",
		screen = s,
	})

	awful.tag.add(tag3, {
		layout = awful.layout.layouts[1],
		master_fill_policy = "master_width_factor",
		screen = s,
	})

	awful.tag.add(tag4, {
		layout = awful.layout.layouts[1],
		master_fill_policy = "master_width_factor",
		screen = s,
	})

	awful.tag.add(tag5, {
		layout = awful.layout.layouts[1],
		master_fill_policy = "master_width_factor",
		screen = s,
	})

	if s == screen[1] then
		awful.tag.add(tag6, {
			layout = awful.layout.layouts[5],
			master_fill_policy = "master_width_factor",
			screen = s,
		})
	else
		awful.tag.add(tag6, {
			layout = awful.layout.layouts[4],
			master_fill_policy = "master_width_factor",
			screen = s,
		})
	end

	awful.tag.add(tag7, {
		layout = awful.layout.layouts[1],
		master_fill_policy = "master_width_factor",
		screen = s,
	})

	awful.tag.add(tag8, {
		layout = awful.layout.layouts[1],
		master_fill_policy = "master_width_factor",
		screen = s,
	})

	awful.tag.add(tag9, {
		layout = awful.layout.layouts[1],
		master_fill_policy = "master_width_factor",
		screen = s,
	})

	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
	})

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
	})

	-- Create the wibox
	s.mywibox = awful.wibar({ position = "top", screen = s })

	if s == screen[1] then
		-- Add widgets to the wibox
		s.mywibox:setup({
			layout = wibox.layout.align.horizontal,
			{ -- Left widgets
				layout = wibox.layout.fixed.horizontal,
				mylauncher,
				s.mytaglist,
			},
			s.mytasklist, -- Middle widget
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				spacer,
				mytextclock,
				systray,
				spacer,
				s.mylayoutbox,
			},
		})
	else
		-- Add widgets to the wibox
		s.mywibox:setup({
			layout = wibox.layout.align.horizontal,
			{ -- Left widgets
				layout = wibox.layout.fixed.horizontal,
				mylauncher,
				s.mytaglist,
			},
			s.mytasklist, -- Middle widget
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				mpris(),
				spacer,
				cpu,
				spacer,
				mem,
				spacer,
				vol,
				mytextclock,
				spacer,
				s.mylayoutbox,
			},
		})
	end
end)

-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
	awful.button({}, 3, function()
		mymainmenu:toggle()
	end)
	-- awful.button({}, 4, awful.tag.viewnext),
	-- awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
local globalkeys = gears.table.join(
	awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
	awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
	awful.key({ modkey }, "Tab", awful.tag.history.restore, { description = "go back", group = "tag" }),

	-- Toggle wibox
	awful.key({ modkey }, "b", function()
		mouse.screen.mywibox.visible = not mouse.screen.mywibox.visible
	end),

	-- Standard program
	awful.key({ modkey }, "d", function()
		awful.spawn(dmenu_run, false)
	end, { description = "launch dmenu", group = "launcher" }),
	awful.key({ modkey }, "c", function()
		awful.spawn(recordmenu, false)
	end, { description = "launch recordmenu", group = "launcher" }),
	awful.key({ modkey }, "r", function()
		awful.spawn(rofi_launcher, false)
	end, { description = "launch launcher", group = "launcher" }),
	awful.key({ modkey }, "w", function()
		awful.spawn(rofi_window, false)
	end, { description = "launch window", group = "launcher" }),
	awful.key({ modkey }, "p", function()
		awful.spawn(rofi_powermenu, false)
	end, { description = "launch powermenu", group = "launcher" }),
	awful.key({ modkey }, "e", function()
		awful.spawn("vivaldi")
	end, { description = "launch vivaldi", group = "launcher" }),
	awful.key({ modkey }, "x", function()
		awful.spawn("logseq")
	end, { description = "launch logseq", group = "launcher" }),
	awful.key({ modkey }, "z", function()
		awful.spawn("obsidian")
	end, { description = "launch obsidian", group = "launcher" }),
	awful.key({ modkey }, "v", function()
		awful.spawn("vscode")
	end, { description = "launch vscode", group = "launcher" }),
	awful.key({ altkey }, "Return", function()
		awful.spawn("kitty --title f4h --class f4h -e fish")
	end, { description = "open kitty", group = "launcher" }),

	awful.key({ modkey, "Shift" }, "q", function()
		awful.spawn("xkill", false)
	end, { description = "launch xkill", group = "launcher" }),
	awful.key({ modkey, "Shift" }, "s", function()
		awful.spawn("flameshot gui", false)
	end, { description = "launch flameshot", group = "launcher" }),
	awful.key({ modkey, "Shift" }, "e", function()
		awful.spawn("google-chrome-stable")
	end, { description = "launch chrome", group = "launcher" }),
	awful.key({ modkey, "Shift" }, "m", function()
		awful.spawn("yesplaymusic")
	end, { description = "launch ncmpcpp", group = "launcher" }),

	awful.key({ altkey, "Control" }, "p", function()
		awful.spawn("playerctl play-pause", false)
	end, { description = "toggle mpris", group = "launcher" }),
	awful.key({ altkey, "Control" }, "Left", function()
		awful.spawn("playerctl previous", false)
	end, { description = "play previous mpris", group = "launcher" }),
	awful.key({ altkey, "Control" }, "Right", function()
		awful.spawn("playerctl next", false)
	end, { description = "play next mpris", group = "launcher" }),

	awful.key({ modkey, "Control" }, "p", function()
		awful.spawn("mpc toggle", false)
	end, { description = "mpc toggle", group = "launcher" }),
	awful.key({ modkey, "Control" }, "Left", function()
		awful.spawn("mpc prev", false)
	end, { description = "mpc prev", group = "launcher" }),
	awful.key({ modkey, "Control" }, "Right", function()
		awful.spawn("mpc next", false)
	end, { description = "mpc next", group = "launcher" }),

	awful.key({ modkey }, "Return", function()
		awful.spawn("kitty -e zsh")
	end, { description = "open kitty with zsh", group = "launcher" }),
	awful.key({ altkey }, "w", function()
		awful.spawn(webstorm)
	end, { description = "launch webstorm", group = "launcher" }),
	awful.key({ altkey }, "p", function()
		awful.spawn(pycharm)
	end, { description = "launch pycharm", group = "launcher" }),

	awful.key({}, "XF86AudioMute", function()
		awful.spawn("pamixer -t", false)
	end, { description = "toggle mute", group = "launcher" }),
	awful.key({}, "XF86AudioRaiseVolume", function()
		awful.spawn("pamixer -i 3", false)
	end, { description = "increace volume", group = "launcher" }),
	awful.key({}, "XF86AudioLowerVolume", function()
		awful.spawn("pamixer -d 3", false)
	end, { description = "decrease volume", group = "launcher" }),
	awful.key({}, "XF86MonBrightnessUp", function()
		awful.spawn("light -A 5", false)
	end, { description = "increase brightness", group = "launcher" }),
	awful.key({}, "XF86MonBrightnessDown", function()
		awful.spawn("light -U 5", false)
	end, { description = "decrease brightness", group = "launcher" }),
	awful.key({}, "Print", function()
		awful.spawn("flameshot screen -n 0 -c", false)
	end, { description = "Shot screen 0", group = "launcher" }),
	awful.key({ "Shift" }, "Print", function()
		awful.spawn("flameshot screen -n 1 -c", false)
	end, { description = "Shot screen 1", group = "launcher" }),
	awful.key({ "Control" }, "Print", function()
		awful.spawn("flameshot full -c", false)
	end, { description = "Shot all screen", group = "launcher" }),

	-- Screen manipulation
	awful.key({ modkey }, "l", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ modkey }, "h", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),

	-- awful.key({ modkey }, "w", function()
	-- 	mymainmenu:show()
	-- end, { description = "show main menu", group = "awesome" }),

	-- Client manipulation
	awful.key({ modkey }, "j", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next by index", group = "client" }),
	awful.key({ modkey }, "k", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus previous by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),

	awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
	awful.key({ modkey }, "Escape", function()
		awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end, { description = "go back", group = "client" }),

	-- Awesome manipulation
	awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
	awful.key({ modkey, "Control" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),

	-- Layout manipulation
	awful.key({ modkey }, "period", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase master width factor", group = "layout" }),
	awful.key({ modkey }, "comma", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width factor", group = "layout" }),

	awful.key({ modkey, "Shift" }, "h", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of master clients", group = "layout" }),
	awful.key({ modkey, "Shift" }, "l", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of master clients", group = "layout" }),

	awful.key({ modkey, "Control" }, "h", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "layout" }),
	awful.key({ modkey, "Control" }, "l", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "layout" }),

	awful.key({ modkey }, "grave", function()
		awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),
	awful.key({ modkey, "Shift" }, "grave", function()
		awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),

	awful.key({ modkey, "Control" }, "n", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:emit_signal("request::activate", "key.unminimize", { raise = true })
		end
	end, { description = "restore minimized", group = "client" })
)

local clientkeys = gears.table.join(
	awful.key({ modkey }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "toggle fullscreen", group = "client" }),
	awful.key({ modkey }, "q", function(c)
		c:kill()
	end, { description = "close", group = "client" }),
	awful.key(
		{ modkey, "Shift" },
		"f",
		awful.client.floating.toggle,
		{ description = "toggle floating", group = "client" }
	),
	awful.key({ modkey, "Control" }, "Return", function(c)
		c:swap(awful.client.getmaster())
	end, { description = "move to master", group = "client" }),
	awful.key({ modkey }, "o", function(c)
		c:move_to_screen()
	end, { description = "move to screen", group = "client" }),
	awful.key({ modkey }, "t", function(c)
		c.ontop = not c.ontop
	end, { description = "toggle keep on top", group = "client" }),
	awful.key({ modkey }, "n", function(c)
		-- The client currently has the input focus, so it cannot be
		-- minimized, since minimized clients can't have the focus.
		c.minimized = true
	end, { description = "minimize", group = "client" }),
	awful.key({ modkey }, "m", function(c)
		c.maximized = not c.maximized
		c:raise()
	end, { description = "(un)maximize", group = "client" }),
	awful.key({ modkey, "Control" }, "m", function(c)
		c.maximized_vertical = not c.maximized_vertical
		c:raise()
	end, { description = "(un)maximize vertically", group = "client" }),
	awful.key({ modkey, "Shift" }, "m", function(c)
		c.maximized_horizontal = not c.maximized_horizontal
		c:raise()
	end, { description = "(un)maximize horizontally", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = gears.table.join(
		globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, { description = "view tag #" .. i, group = "tag" }),
		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, { description = "toggle tag #" .. i, group = "tag" }),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, { description = "move focused client to tag #" .. i, group = "tag" }),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end, { description = "toggle focused client on tag #" .. i, group = "tag" })
	)
end

local clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ modkey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ modkey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

local function myfocus_filter(c)
	if awful.client.focus.filter(c) then
		-- This works with tooltips and some popup-menus
		if c.class == "Wine" and c.above == true then
			return nil
		elseif
			c.class == "Wine"
			and c.type == "dialog"
			and c.skip_taskbar == true
			and c.size_hints.max_width
			and c.size_hints.max_width < 160
		then
			-- for popup item menus of Photoshop CS5
			return nil
		else
			return c
		end
	end
end

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = myfocus_filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},
	{
		rule_any = {
			instance = { "Tim.exe", "QQ" },
		},
		properties = {
			focusable = true,
			floating = true,
			border_width = 0,
		},
	},
	{
		rule_any = { class = { "St", "kitty" } },
		properties = {},
		callback = awful.client.setslave,
	},

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				"copyq", -- Includes session name in class.
				"pinentry",
				"Places",
			},
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin", -- kalarm.
				"Sxiv",
				"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
				"jetbrains-toolbox",
				"Wine",
				"wechat.exe",
				"Lxappearance",
				"Nitrogen",
				"Org.gnome.Nautilus",
				"Timeshift-gtk",
				"QQ",
			},

			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
				"Welcome to CLion",
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = { floating = true },
	},

	-- Add titlebars to normal clients and dialogs
	{ rule_any = { type = { "normal", "dialog" } }, properties = { titlebars_enabled = false } },

	-- Set Firefox to always map on the tag1 on screen 1.
	{ rule = { class = "vivaldi-stable" }, properties = { screen = 1, tag = tag1 } },
	{ rule = { instance = "Devtools" }, properties = { screen = 2, tag = tag1 } },
	-- { rule = { class = "Typora" }, properties = { screen = 2, tag = tag1 } },

	{ rule = { class = "jetbrains-clion" }, properties = { screen = 1, tag = tag2 } },
	{ rule = { class = "jetbrains-webstorm" }, properties = { screen = 1, tag = tag2 } },
	{ rule = { class = "jetbrains-pycharm" }, properties = { screen = 1, tag = tag2 } },

	{ rule = { class = "f4h" }, properties = { screen = 1, tag = tag3 } },

	{ rule = { instance = "spotify" }, properties = { screen = 1, tag = tag4 } },
	{ rule = { class = "Spotify" }, properties = { screen = 1, tag = tag4 } },
	{ rule = { class = "yesplaymusic" }, properties = { screen = 1, tag = tag4 } },

	{ rule = { instance = "music" }, properties = { screen = 2, tag = tag4 } },

	{ rule = { class = "Steam" }, properties = { screen = 2, tag = tag5 } },

	{ rule = { class = "QQ" }, properties = { screen = 1, tag = tag6 } },
	{ rule = { class = "Wine" }, properties = { screen = 1, tag = tag6 } },
	{ rule = { class = "wechat.exe" }, properties = { screen = 1, tag = tag6 } },
	{ rule = { class = "TelegramDesktop" }, properties = { screen = 2, tag = tag6 } },

	{ rule = { class = "Solaar" }, properties = { screen = 1, tag = tag7 } },
	{ rule = { class = "qBittorrent" }, properties = { screen = 1, tag = tag7 } },
	{ rule = { class = "discord" }, properties = { screen = 2, tag = tag7 } },

	{ rule = { class = "Logseq" }, properties = { screen = 1, tag = tag8 } },
	{ rule = { class = "obsidian" }, properties = { screen = 2, tag = tag8 } },

	{ rule = { class = "winedbg.exe" }, properties = { screen = 1, tag = tag9 } },
	{ rule = { class = "Clash for Windows" }, properties = { screen = 2, tag = tag9 } },
}
-- }}}

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c):setup({
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle
			{ -- Title
				align = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	})
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)

client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)

-- }}}
--
