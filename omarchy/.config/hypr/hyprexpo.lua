-- HyprExpo pinned for Hyprland 0.56.2.
local plugin_path = os.getenv("HOME") .. "/.local/lib/hyprland/hyprexpo/59bf4d378cecde9ed849e9c562306738b1583016/hyprexpo.so"
local file = io.open(plugin_path, "rb")
if not file then return end -- Run scripts/install-hyprexpo.sh first.
file:close()
hl.plugin.load(plugin_path)
local loaded = false
for _, plugin in ipairs(hl.get_loaded_plugins()) do
  if plugin.name == "hyprexpo" then loaded = true; break end
end
if loaded then
  hl.config({ plugin = { hyprexpo = {
    columns = 3,
    rows = 3,
    workspace_method = "first 1",
    gaps_in = 8,
    gaps_out = 8,
    gesture_distance = 200,
    keynav_enable = 0,
    cancel_key = "escape",
    show_workspace_names = 1,
  } } })
  hl.plugin.hyprexpo.gesture({ fingers = 4, direction = "up", action = "expo" })
  hl.plugin.hyprexpo.gesture({ fingers = 4, direction = "down", action = "cancel" })
end
