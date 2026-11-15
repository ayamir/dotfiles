-- 工作区布局与窗口落位：按 catppuccin/.config/awesome/rc.lua 移植。
--
-- awesome 那边：
--   * 9 个 tag，tag1..tag9 全部用 awful.layout.suit.spiral.dwindle
--   * tag6 在主屏是 floating，副屏是 max
--   * 每个 tag 都设了 master_fill_policy = master_width_factor
--   * 所有 client 都设 placement = no_overlap + no_offscreen
--   * 应用按 class 固定到 tag1..tag9（浏览器 / IDE / 文件 / 音乐 / 游戏 / IM / 工具 / 笔记 / 杂项）
--
-- Hyprland 只能对上其中一部分，对应关系见下面各段；对不上的写在文件末尾。

-- 工作区切换：保留四指手势的跟手效果，松手后用较缓的横向滑动收尾。
hl.animation({ leaf = "workspaces", enabled = true, speed = 4.5, bezier = "easeInOutCubic", style = "slide" })

-- ---------- 1. 布局 ----------
-- spiral.dwindle → dwindle（Omarchy 的默认值，这里显式写出来，免得主题或更新把它改掉）
hl.config({ general = { layout = "dwindle" } })

-- master_fill_policy = master_width_factor：awesome 的 tile/fair 用它决定主区宽度。
-- Hyprland 只有 master 布局有这个旋钮（master:mfact），awesome 的默认比例是 0.5，
-- Hyprland 的默认是 0.55，顺手对齐。
hl.config({ master = { mfact = 0.5 } })

-- ---------- 2. tag6：IM 工作区用浮动 ----------
-- Hyprland 没有“整工作区浮动”的布局（工作区只会是 dwindle/master/scrolling），
-- Omarchy 的做法是把该工作区的窗口逐个浮起来 —— 也就是 SUPER + L 循环到的
-- floating 模式，这里直接给工作区 6 定死。
o.workspace_mode({ workspace = 6, mode = "floating" })

-- ---------- 3. 应用固定到工作区 ----------
-- 对应 awesome 的 { rule = { class = ... }, properties = { tag = tagN } }。
-- tag 序号就是这里的工作区号（tag1 → workspace 1）。
--
-- Hyprland 的 class / title 匹配用的是正则，所以这里一律 ^...$ 锚定：
-- 不锚定的话 "code-oss" 会连 code-oss-dev 一起抓走，"google-chrome" 同理。
--
-- 落位以 2026-11-15 的实际桌面为准（每行第一个注释写着当时那个工作区里是谁），
-- 后面缀着的条目是 awesome 时期留下、继续留在原 tag 上的常用应用。
local apps = {
  { -- 1：浏览器 —— google-chrome
    classes = {
      "^google-chrome$", "^vivaldi-stable$", "^firefox$", "^firefox-bin$",
      "^microsoft-edge-stable$", "^chromium$", "^brave-browser$", "^BraveSoftware$",
    },
  },
  { -- 2：设计 / 文档 —— so.stencil.tern（Stencil）
    classes = { "^so\\.stencil\\.tern$" },
  },
  { -- 3：IDE / 编辑器 —— code-oss-dev
    classes = {
      "^code-oss-dev$", "^code-oss$",
      "^jetbrains-clion$", "^jetbrains-webstorm$", "^jetbrains-pycharm$",
    },
  },
  { -- 4：Paseo（awesome 的 tag4 是音乐，一并留在这）
    classes = { "^Paseo$", "^spotify$", "^Spotify$", "^yesplaymusic$" },
  },
  { -- 5：IM —— 飞书（class 为空，只能靠标题；awesome 的 tag5 是游戏）
    classes = { "^steam$", "^Steam$" },
    titles = { "^飞书" },
  },
  { -- 6：IM / 聊天（该工作区是浮动模式，见上一段）—— Discord（Chrome PWA）
    classes = {
      "^chrome-discord\\.com__channels_@me-Default$",
      "^QQ$", "^Wine$", "^wechat\\.exe$", "^TelegramDesktop$",
    },
  },
  { -- 7：工具 —— clash-verge
    classes = {
      "^clash-verge$", "^clash for windows$",
      "^Solaar$", "^qBittorrent$", "^discord$",
    },
  },
  { -- 8：传输 / 笔记 —— LocalSend
    classes = {
      "^org\\.localsend\\.localsend_app$",
      "^Logseq$", "^obsidian$",
    },
  },
  { -- 9：杂项 —— magpie
    classes = { "^magpie$", "^picgo$", "^winedbg\\.exe$" },
  },
}

for workspace, app in ipairs(apps) do
  for _, class in ipairs(app.classes or {}) do
    -- awesome 把窗口塞进 tag 但不切视图；Hyprland 的 workspace 规则同样不抢焦点
    o.window({ class = class }, { workspace = tostring(workspace) })
  end
  for _, title in ipairs(app.titles or {}) do
    o.window({ title = title }, { workspace = tostring(workspace) })
  end
end

-- ---------- 4. 浮窗出现的位置 ----------
-- awesome 给所有 client 设了 placement = no_overlap + no_offscreen：
--   * 不出屏：Hyprland 自身保证，浮窗会被夹在可视区域内；
--   * 不重叠：floating 工作区由 o.workspace_mode 实现 —— 居中 + 每窗阶梯偏移
--     24px（最多 5 步），不会正好压在上一个窗口上；
--   * 对话框：补一条浮动 + 居中，和 awesome 里弹窗的表现一致。
o.window({ modal = true }, { float = true, center = true })

-- ---------- 对不上的部分（Hyprland 没有等价物）----------
-- * fair / tile.bottom / max / magnifier / corner.* 布局：Hyprland 只有
--   dwindle / master / scrolling（+ monocle 单窗口铺满），这里统一用 dwindle。
-- * awful.client.setslave（St/kitty 新窗口进 slave 区）：dwindle 没有主从区概念。
-- * tag6 在副屏用 max：如果想让工作区 6 铺满单窗口，可改成
--   o.workspace_mode({ workspace = 6, mode = "scrolling" }) 或自行用 monocle。
