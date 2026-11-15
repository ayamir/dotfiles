#!/usr/bin/env bash
# Omarchy 配置整合脚本
#
#   bash install.sh            把仓库里的配置装到本机（先备份，再软链/复制）
#   bash install.sh --dry-run  只显示会做什么
#   bash install.sh --save     把会被程序改写的那几个文件同步回仓库（git 提交前跑）
#
# 只装「与 Omarchy 默认不同」的文件：其余配置仍由 omarchy 包维护，
# 升级后能继续拿到上游改进。
set -uo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
DRY=0
MODE=install
case ${1:-} in
  --dry-run) DRY=1 ;;
  --save)    MODE=save ;;
esac
run() { (( DRY )) && echo "   [dry] $*" || "$@"; }

# 由程序原子重写的文件（写 .lock 再 rename）：软链会被替换成普通文件，
# 所以这两个用复制，--save 负责把它们同步回仓库。
COPY_FILES=(.config/git/config .config/omarchy/shell.json)

# 其余稳定的配置和用户插件软链到仓库（改哪个都等于改仓库）
LINK_FILES=(
  .config/hypr/hyprland.lua
  .config/hypr/input.lua
  .config/hypr/monitors.lua
  .config/hypr/workspaces.lua
  .config/chrome-flags.conf
  .config/chromium-flags.conf
  .config/omarchy/plugins/ayamir.workspaces
  .config/ghostty/config
  .config/kitty/kitty.conf
  .config/alacritty/alacritty.toml
  .config/starship.toml
  .config/omarchy/shell.toml
  .config/omarchy/branding/about.txt
  .config/omarchy/branding/screensaver.txt
  .config/omarchy/extensions/omarchy-menu.jsonc
  .config/omarchy/hooks/theme-set.d/10-owe-sync
  .config/omarchy/defaults/agent
  ".config/autostart/Clash Verge.desktop"
  .config/autostart/magpie.desktop
  .config/wireplumber/wireplumber.conf.d/alsa-soft-mixer.conf
)

# omarchy 自带标签页里没有的第三方 shell 插件，装的时候现拉
PLUGINS=(
  https://github.com/lijiawei0305-pixel/omarchy-mihomo-plugin.git
)

if ! command -v omarchy >/dev/null 2>&1; then
  echo "未找到 omarchy 命令，这套配置只适用于 Omarchy。" >&2
  exit 1
fi

# ---------- --save：本机 → 仓库 ----------
if [[ $MODE == save ]]; then
  echo "==> 把本机改动同步回仓库"
  for f in "${COPY_FILES[@]}"; do
    if [[ -r $HOME/$f ]]; then
      run cp "$HOME/$f" "$SRC/$f"
      echo "   $HOME/$f -> $SRC/$f"
    else
      echo "   - 跳过不存在的 $HOME/$f"
    fi
  done
  echo "   检查差异: git -C $SRC/.. diff --stat"
  exit 0
fi

# ---------- 备份 + 软链 ----------
link() {  # link <仓库内相对路径> <目标绝对路径>
  local src=$SRC/$1 dest=$2
  if [[ -e $dest && ! -L $dest ]]; then
    if (( DRY )); then
      echo "   [dry] 会备份原 $dest"
    else
      mv "$dest" "$dest.bak.$(date +%s)" && echo "   已备份 $dest"
    fi
  fi
  run ln -sfn "$src" "$dest"
  echo "   $dest -> $src"
}

copy() {  # copy <仓库内相对路径> <目标绝对路径>
  local src=$SRC/$1 dest=$2
  if (( DRY )); then
    echo "   [dry] cp $src $dest（会先备份原文件）"
    return
  fi
  [[ -e $dest && ! -L $dest ]] && mv "$dest" "$dest.bak.$(date +%s)" && echo "   已备份 $dest"
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo "   $dest <- $src（复制）"
}

echo "==> 链接配置文件"
for f in "${LINK_FILES[@]}"; do
  mkdir -p "$(dirname "$HOME/$f")"
  link "$f" "$HOME/$f"
done

# ~/.zshrc.local：机器专属覆盖层（starship 提示符、pacman 缩写…）
link zshrc.local "$HOME/.zshrc.local"

echo "==> 复制会被程序改写的文件"
for f in "${COPY_FILES[@]}"; do
  mkdir -p "$(dirname "$HOME/$f")"
  copy "$f" "$HOME/$f"
done

# ---------- 第三方 shell 插件 ----------
echo "==> Omarchy shell 插件"
if (( DRY )); then
  echo "   [dry] omarchy plugin add ${PLUGINS[*]}"
else
  installed=$(omarchy plugin list 2>/dev/null || true)
  for url in "${PLUGINS[@]}"; do
    id=${url##*/}; id=${id%.git}
    case $id in
      omarchy-*-plugin) id=${id#omarchy-}; id=${id%-plugin} ;;
    esac
    if grep -qi -- "$id" <<<"$installed"; then
      echo "   $id 已安装"
    else
      run omarchy plugin add "$url" --yes || echo "   ⚠ $id 安装失败，可手动: omarchy plugin add $url"
    fi
  done
fi

# Superwhisper 自带的面板是 /opt 下的软链，包装了就有
SW=/opt/superwhisper/assets/omarchy-plugin/superwhisper-panel
if [[ -d $SW && ! -e $HOME/.config/omarchy/plugins/superwhisper-panel ]]; then
  run ln -sfn "$SW" "$HOME/.config/omarchy/plugins/superwhisper-panel"
  echo "   已链接 superwhisper 面板插件"
fi

# ---------- 生效 + 校验 ----------
echo "==> 让 Hyprland 重新加载"
if (( DRY )); then
  echo "   [dry] hyprctl reload && hyprctl configerrors"
else
  hyprctl reload >/dev/null 2>&1 && echo "   hyprctl reload ok"
  errs=$(hyprctl configerrors 2>&1)
  if [[ -n ${errs//[[:space:]]/} ]]; then
    echo "   ✗ hyprctl configerrors:"
    printf '%s\n' "$errs" | sed 's/^/     /'
  else
    echo "   hyprctl configerrors 干净 ✓"
  fi
fi

echo "==> 重启 Omarchy shell（应用 shell.json / shell.toml）"
if (( DRY )); then
  echo "   [dry] omarchy restart shell"
elif ! omarchy restart shell >/dev/null 2>&1; then
  echo "   ⚠ 重启 shell 失败，手动执行: omarchy restart shell"
fi

echo ""
echo "✅ 完成。还需要手动做的两件事："
echo "   omarchy restart terminal   # 让 kitty/alacritty/ghostty 的配置生效"
echo "   exec zsh                   # 当前终端切到新配置的 zsh"
echo ""
echo "改完 bar（omarchy bar …）或 git 全局配置后，记得同步回仓库:"
echo "   bash $SRC/install.sh --save"
