# Omarchy 配置

本机 [Omarchy](https://omarchy.org/)（Hyprland + Omarchy shell）的自定义配置。
**只存与 Omarchy 默认不同的部分**，其余配置继续由 `omarchy` 包维护，升级后仍能拿到上游改进。

```sh
bash omarchy/install.sh --dry-run   # 先看会做什么
bash omarchy/install.sh             # 装机：备份 → 软链/复制 → hyprctl 校验 → 重启 shell
```

## 装了些什么

| 文件 | 改了什么 |
|---|---|
| `.config/hypr/workspaces.lua` | **新增**：工作区布局与窗口落位（按 [`catppuccin/.config/awesome/rc.lua`](../catppuccin/.config/awesome/rc.lua) 移植） |
| `.config/hypr/hyprland.lua` | `require("hypr.workspaces")` |
| `.config/hypr/input.lua` | 触控板自然滚动 |
| `.config/hypr/monitors.lua` | `eDP-2` 屏幕（scale 2） |
| `.config/omarchy/plugins/ayamir.workspaces/` | Omarchy 工作区组件的用户克隆版，固定显示 1–9 号工作区 |
| `.config/chrome-flags.conf`、`.config/chromium-flags.conf` | Chrome 和 Chromium 的应用缩放设为 0.8（重启浏览器后生效） |
| `.config/ghostty/config` | `command = /usr/bin/zsh`（登录 shell 是 zsh，但旧会话的 `$SHELL` 仍是 bash） |
| `.config/kitty/kitty.conf` | JetBrainsMono Nerd Font / 9pt |
| `.config/alacritty/alacritty.toml` | 字体 family 用 Nerd Font |
| `.config/starship.toml` | 双行提示符（第一行目录+git，第二行 `❯`） |
| `.config/omarchy/shell.json` | bar 布局、时钟、idle，以及克隆的工作区组件 |
| `.config/omarchy/shell.toml` | shell 字号 |
| `.config/omarchy/branding/` | about / screensaver 文字 |
| `.config/omarchy/extensions/omarchy-menu.jsonc` | 菜单项 |
| `.config/omarchy/hooks/theme-set.d/10-owe-sync` | 切主题时通知 owe 守护进程 |
| `.config/omarchy/defaults/agent` | 默认 agent |
| `.config/autostart/` | Clash Verge、magpie 自启 |
| `.config/wireplumber/.../alsa-soft-mixer.conf` | ALSA 走软件混音（避免 Realtek 音质问题） |
| `zshrc.local` | `~/.zshrc.local`：starship 提示符、pacman/yay 缩写覆盖 |

两个例外用**复制**而不是软链，因为它们会被程序原子重写（写完 `.lock` 再 rename，软链会被替换成普通文件）：
`.config/git/config`（`git config --global`）、`.config/omarchy/shell.json`（`omarchy bar` 等命令）。

内置工作区组件的克隆版保存在仓库；第三方 shell 插件不 vendored，装的时候现拉：`omarchy plugin add <git-url>`（见 `install.sh` 里的 `PLUGINS`）。
Superwhisper 的面板插件是 `/opt/superwhisper` 自带的软链，脚本会在包存在时补上。

## 改完记得同步回仓库

```sh
bash omarchy/install.sh --save   # 把 git/config、shell.json 从本机拷回仓库
git -C ~/clone/dotfiles diff --stat
```

## 故意没放进来

- `hypr/bindings.lua`、`looknfeel.lua`、`autostart.lua`：没改过，跟随 omarchy 默认。
- 其他 `omarchy/plugins/`、`themes/`：第三方插件走 git 安装，主题用 `omarchy theme set`。
- `chromium/`、`herdr/` 等应用数据目录；`fcitx5`、`btop` 里与上游一致（只是版本差异）的生成文件。

## 注意

- 这些文件现在是软链，**改它等于改仓库**；`omarchy refresh hyprland` 之类的重置命令会直接覆盖仓库文件，跑之前先提交。
- `omarchy update` 之后如果某个默认配置有改进，你这个文件不会自动跟随（这正是覆盖的代价）。
