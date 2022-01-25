local wezterm = require("wezterm")
local mykeys = {
	{
		key = "t",
		mods = "SHIFT|ALT",
		action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }),
	},
	{
		key = "w",
		mods = "SHIFT|ALT",
		action = wezterm.action({ CloseCurrentTab = { confirm = true } }),
	},
	{ key = "=", mods = "CTRL", action = "IncreaseFontSize" },
	{ key = "-", mods = "CTRL", action = "DecreaseFontSize" },
	{ key = "0", mods = "CTRL", action = "ResetFontSize" },
	{ key = "C", mods = "CTRL|SHIFT", action = "Copy" },
	{ key = "V", mods = "CTRL|SHIFT", action = "Paste" },
	{ key = "Z", mods = "CTRL", action = "TogglePaneZoomState" },
	{
		key = "J",
		mods = "SHIFT|ALT",
		action = wezterm.action({ ActivateTabRelative = -1 }),
	},
	{
		key = "K",
		mods = "SHIFT|ALT",
		action = wezterm.action({ ActivateTabRelative = 1 }),
	},
	{ key = "X", mods = "SHIFT|ALT", action = "ActivateCopyMode" },
	{ key = " ", mods = "SHIFT|ALT", action = "QuickSelect" },
}
for i = 1, 8 do
	table.insert(mykeys, {
		key = tostring(i),
		mods = "CTRL|ALT",
		action = wezterm.action({ ActivateTab = i - 1 }),
	})
end

return {
	use_ime = true,
	default_prog = { "/usr/bin/fish", "-l" },
	font = wezterm.font_with_fallback({
		"Sarasa Mono SC Nerd",
		"JetBrainsMono Nerd Font",
		"Consolas NF",
		"FiraCode Nerd Font",
		"CamingoCode Nerd Font",
		"Hack Nerd Font",
		"PlexCodePro Nerd Font Mono",
		"CodeNewRoman Nerd Font",
		"Operator Mono Lig",
	}),
	front_end = "OpenGL",
	font_size = 14,
	color_scheme = "Catppuccin",
	enable_tab_bar = true,
	tab_max_width = 20,
	tab_bar_at_bottom = true,
	hide_tab_bar_if_only_one_tab = true,
	text_background_opacity = 1.0,
	disable_default_key_bindings = true,
	mouse_bindings = {
		{

			event = { Up = { streak = 1, button = "Left" } },
			mods = "NONE",
			action = wezterm.action({
				CompleteSelectionOrOpenLinkAtMouseCursor = "Clipboard",
			}),
		},
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "CTRL",
			action = "OpenLinkAtMouseCursor",
		},
	},
	keys = mykeys,
	window_background_opacity = 1.0,
	-- window_background_image = "/home/ayamir/Pictures/wezterm/nord.jpg",
	-- window_background_image_hsb = {
	--     brightness = 2.0,
	--     hue = 1.0,
	--     saturation = 1.0
	-- }
}
