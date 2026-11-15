#!/usr/bin/env bash
# zsh 环境安装脚本 — Omarchy / Arch Linux、其他 Linux、macOS
#
#   bash setup.sh             安装依赖、链接配置、核对版本
#   bash setup.sh --dry-run   只显示会做什么
#   bash setup.sh --snapshot  用当前机器重写 versions.lock（改动依赖后跑一次）
#
# 目标：装完和本仓库作者一致的环境。版本以 versions.lock 为准，
# 装完会逐项比对并报告差异（差异只提示，不视为失败）。
set -uo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
LOCK="$SRC/versions.lock"
DRY=0
case ${1:-} in
  --dry-run)  DRY=1 ;;
  --snapshot) MODE=snapshot ;;
esac
MODE=${MODE:-install}
run()   { (( DRY )) && echo "   [dry] $*" || "$@"; }
quiet() { (( DRY )) && { echo "   [dry] $*"; return 0; }; "$@" >/dev/null 2>&1; }

# ---------- 平台探测 ----------
has() { command -v "$1" >/dev/null 2>&1; }

# Omarchy 就是 Arch，只是包要走它自己的封装（omarchy pkg add / pkg aur add），
# 这样包来源、sudo、AUR 辅助工具都由发行版决定，不用在这里各写一套。
if has pacman; then
  PLATFORM=arch
  has omarchy && PLATFORM=omarchy
elif has brew; then
  PLATFORM=brew
else
  cat <<'EOF'
未找到包管理器。先二选一：
  Omarchy / Arch:  sudo pacman -S --needed base-devel git
  macOS:           /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
EOF
  exit 1
fi

# 核心：配置里大部分增强都靠它们；eza/bat 是缩写文件的默认值
CORE=(eza bat fzf fd ripgrep zoxide direnv mise
      zsh-autosuggestions zsh-syntax-highlighting fzf-tab zsh-autopair)
# 可选：缺了只是少一个功能
EXTRA=(atuin git-delta lazygit fastfetch neovim fswatch)

# 名字以 versions.lock（= brew formula 名）为准，Arch 上少数包名不同
arch_name() { case $1 in zsh-autopair) echo zsh-autopair-git ;; *) echo "$1" ;; esac; }
# 只在 AUR 里的包
is_aur() { [[ $1 == fzf-tab || $1 == zsh-autopair ]] || [[ $1 == zsh-autopair-git ]]; }
pkg_name() { [[ $PLATFORM == brew ]] && echo "$1" || arch_name "$1"; }

pkg_present() {
  if [[ $PLATFORM == brew ]]; then brew list --formula "$1" >/dev/null 2>&1
  else pacman -Q -- "$(arch_name "$1")" >/dev/null 2>&1; fi
}

# 任一来源装上就算成功；omarchy 负责决定走 pacman 还是 yay
add_pkg() {
  local name; name=$(pkg_name "$1")
  if [[ $PLATFORM == brew ]]; then
    quiet brew install "$name"
  elif is_aur "$1"; then
    if [[ $PLATFORM == omarchy ]]; then quiet omarchy pkg aur add "$name"
    elif has yay; then  quiet yay -S --noconfirm --needed -- "$name"
    elif has paru; then quiet paru -S --noconfirm --needed -- "$name"
    else echo "   ⚠ 没有 yay/paru，装不了 AUR 包 $name" >&2; return 1; fi
  elif [[ $PLATFORM == omarchy ]]; then
    quiet omarchy pkg add "$name"
  else
    quiet sudo pacman -S --noconfirm --needed -- "$name"
  fi
}

# 登录 shell 以 passwd 为准（$SHELL 在 sudo / 老会话里可能是旧值）
login_shell() { getent passwd "${USER:-$(id -un)}" 2>/dev/null | cut -d: -f7; }
LOGIN_SHELL=$(login_shell || true)
SHELL=${LOGIN_SHELL:-${SHELL:-}}

# 实际生效的 zsh（登录 shell 是 zsh 就用登录 shell）
zsh_bin() { case ${SHELL:-} in */zsh) echo "$SHELL" ;; *) command -v zsh || echo /bin/zsh ;; esac; }
# 只取 major.minor：Apple 自带 5.9 与 brew 的 5.9.2 视为同一版本
zsh_mm()  { "$1" -fc 'print -r -- $ZSH_VERSION' 2>/dev/null | cut -d. -f1,2; }
# Arch 的版本带 pkgrel（5.9.2-1），比对时去掉
pkg_version() {
  if [[ $PLATFORM == brew ]]; then
    brew list --versions "$1" 2>/dev/null | awk '{print $2}'
  else
    pacman -Q -- "$(arch_name "$1")" 2>/dev/null | awk '{print $2}' | sed -E 's/-[0-9]+$//'
  fi
}
locked()  { awk -v n="$1" '$1==n{print $2; exit}' "$LOCK" 2>/dev/null; }

# ---------- Homebrew shellenv（仅 macOS）----------
if [[ $PLATFORM == brew ]]; then
  for b in "$(command -v brew || true)" /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -n $b && -x $b ]] && { eval "$("$b" shellenv)"; break; }
  done
fi

# ---------- 记录快照 ----------
if [[ $MODE == snapshot ]]; then
  {
    echo "# 生成: bash setup.sh --snapshot ($PLATFORM)"
    echo "zsh $(zsh_mm "$(zsh_bin)")"
    for f in "${CORE[@]}" "${EXTRA[@]}"; do
      v=$(pkg_version "$f"); [[ -n $v ]] && echo "$f $v"
    done
  } > "$LOCK"
  echo "已写入 $LOCK:"
  cat "$LOCK"
  exit 0
fi

echo "==> $(uname -s) $(uname -m) · 平台: $PLATFORM"
if [[ $PLATFORM == brew && $(uname -m) == arm64 && $(brew --prefix) == /usr/local ]]; then
  echo "   ⚠ 这是 Rosetta 下的 Intel Homebrew。配置两种前缀都认，"
  echo "     但两套 brew 混装会互相覆盖 PATH；建议用 /opt/homebrew 的原生包。"
fi

# ---------- zsh 自身 ----------
WANT_ZSH=$(locked zsh)
CUR_ZSH=$(zsh_bin)
echo "==> zsh 版本（快照 ${WANT_ZSH:-未记录}）"
GOT_ZSH=$(zsh_mm "$CUR_ZSH")
if [[ -z $WANT_ZSH || $GOT_ZSH == "$WANT_ZSH" ]]; then
  echo "   $CUR_ZSH → zsh $GOT_ZSH ✓"
else
  echo "   $CUR_ZSH 是 zsh $GOT_ZSH，快照要求 $WANT_ZSH"
  add_pkg zsh || echo "   ⚠ 装 zsh 失败，版本可能与作者不一致"
  [[ $PLATFORM == brew ]] && echo "   brew 的 zsh 在 $(brew --prefix)/bin/zsh"
fi

# ---------- 依赖（已装的自动跳过，装不上的不中断）----------
echo "==> 安装依赖"
for f in "${CORE[@]}" "${EXTRA[@]}"; do
  pkg_present "$f" && continue
  if ! add_pkg "$f"; then
    [[ " ${CORE[*]} " == *" $f "* ]] && echo "   ⚠ 核心依赖 $f 安装失败，对应功能不可用" \
                                    || echo "   - 跳过 $f"
  fi
done

# ---------- 登录 shell ----------
# Omarchy 没有切 shell 的专用命令，仍走系统自带的 chsh（/etc/shells 已含 zsh）
if [[ ${SHELL:-} == */zsh ]]; then
  echo "==> 登录 shell 已是 zsh ✓"
else
  case $PLATFORM in
    brew) BZ="$(brew --prefix)/bin/zsh" ;;
    *)    BZ=/usr/bin/zsh ;;
  esac
  echo "==> 登录 shell 还不是 zsh（当前 ${SHELL:-未知}）"
  echo "   在终端里执行（chsh 需要密码）:"
  echo "     chsh -s $BZ"
  echo "   或在没有终端的环境下:"
  echo "     sudo chsh -s $BZ $USER"
fi

# ---------- 链接配置 ----------
link() {  # link <源文件> <目标>
  if [[ -e $2 && ! -L $2 ]]; then
    if (( DRY )); then
      echo "   [dry] 会备份原 $2"
    elif ! mv "$2" "$2.bak.$(date +%s)"; then
      echo "备份 $2 失败"; return 1
    else
      echo "   已备份原 $2"
    fi
  fi
  run ln -sfn "$1" "$2"
  echo "   $2 -> $1"
}

echo "==> 链接 ~/.zshrc"
link "$SRC/zshrc" "$HOME/.zshrc"

echo "==> 链接缩写文件"
mkdir -p "$HOME/.config/zsh-abbr"
link "$SRC/user-abbreviations" "$HOME/.config/zsh-abbr/user-abbreviations"

# ---------- 插件（包管理器里没有的）----------
echo "==> 插件"
# Arch/Omarchy 用 AUR 的 zsh-abbr 包，交给 add_pkg；brew 那边没有，直接 clone
if [[ $PLATFORM == brew ]]; then
  if [[ ! -d $HOME/.local/share/zsh-abbr ]]; then
    run git clone --depth 1 --recurse-submodules \
      https://github.com/olets/zsh-abbr "$HOME/.local/share/zsh-abbr"
  else
    echo "   zsh-abbr 已存在"
  fi
elif ! pkg_present zsh-abbr; then
  add_pkg zsh-abbr || echo "   ⚠ zsh-abbr 安装失败，缩写（ls→eza 等）不可用"
fi
if [[ ! -d ${COBALT_SPARK_DIR:-$HOME/clone/cobalt-spark} ]]; then
  echo "   - 未安装可选提示符主题 cobalt-spark（不装也能用，提示符退回 zsh 原生）"
  echo "     想装: git clone https://github.com/ayamir/cobalt-spark ~/clone/cobalt-spark"
fi

# ---------- atuin 常驻 ----------
if [[ $PLATFORM == brew ]] && command -v atuin >/dev/null 2>&1 && [[ $OSTYPE == darwin* ]]; then
  run brew services start atuin >/dev/null 2>&1 || true
fi

# ---------- 版本核对 ----------
echo "==> 与 versions.lock 比对"
drift=0
if [[ ! -r $LOCK ]]; then
  echo "   - 没有 versions.lock，跳过"
else
  while read -r name ver; do
    [[ -z $name || $name == \#* ]] && continue
    if [[ $name == zsh ]]; then
      got=$(zsh_mm "$(zsh_bin)")
    else
      got=$(pkg_version "$name")
    fi
    if [[ -z $got ]]; then
      echo "   ✗ $name 未安装（快照 $ver）"; drift=1
    elif [[ $got != "$ver" ]]; then
      echo "   ~ $name $got（快照 $ver）"; drift=1
    fi
  done < "$LOCK"
  (( drift )) && echo "   ↑ 有差异。快照来自 macOS/Homebrew，Arch 的包版本本就不同，多数差异无害。" \
              || echo "   全部一致 ✓"
fi

echo ""
echo "✅ 完成。新开终端，或执行: exec zsh"
echo ""
echo "个人配置放 ~/.zshrc.local（不进 Git，最后加载，可覆盖一切）。示例:"
if [[ $PLATFORM == brew ]]; then
  echo '  abbr -S "hr"="hrelay"                      # 仅本机的缩写'
else
  echo '  abbr -S --force "up"="yay -Syu"            # 覆盖上游的 brew 缩写'
  echo '  abbr -S --force "c"="yay -Sc"'
fi
echo '  export PATH="$HOME/.local/bin:$PATH"       # 机器专属 PATH'
echo '  export EDITOR=nvim                         # 覆盖默认值'
