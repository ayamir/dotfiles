local wezterm = require("wezterm")
local c = wezterm.config_builder()
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
	{ key = "C", mods = "CTRL", action = wezterm.action.CopyTo("ClipboardAndPrimarySelection") },
	{ key = "V", mods = "CTRL", action = wezterm.action.PasteFrom("Clipboard") },
	{ key = "V", mods = "CTRL", action = wezterm.action.PasteFrom("PrimarySelection") },
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

wezterm.plugin.require("https://github.com/nekowinston/wezterm-bar").apply_to_config(c)

c.use_ime = true
c.default_prog = { "/bin/zsh", "-l" }
c.window_decorations = "RESIZE"
c.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
c.font = wezterm.font_with_fallback({
	"JetBrainsMono Nerd Font",
	"Sarasa Mono SC Nerd",
	"Consolas NF",
	"FiraCode Nerd Font",
	"CamingoCode Nerd Font",
	"Hack Nerd Font",
	"PlexCodePro Nerd Font Mono",
	"CodeNewRoman Nerd Font",
	"Operator Mono Lig",
})
c.adjust_window_size_when_changing_font_size = false
c.audible_bell = "Disabled"
c.clean_exit_codes = { 130 }
c.default_cursor_style = "BlinkingBar"
c.command_palette_font_size = 13.0
c.window_frame = { font_size = 13.0 }
c.window_background_opacity = 0.95
c.front_end = "OpenGL"
c.font_size = 13
c.mouse_bindings = {
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
}
c.keys = mykeys

wezterm.plugin.require("https://github.com/catppuccin/wezterm").apply_to_config(c, {
	sync = false,
	sync_flavors = { light = "latte", dark = "mocha" },
})

return c
