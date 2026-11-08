#!/usr/bin/env bash
# zsh 环境安装脚本 — macOS (Apple Silicon / Intel) / Linux
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
run() { (( DRY )) && echo "   [dry] $*" || "$@"; }

# 核心：配置里大部分增强都靠它们；eza/bat 是缩写文件的默认值
CORE=(eza bat fzf fd ripgrep zoxide direnv mise
      zsh-autosuggestions zsh-syntax-highlighting fzf-tab zsh-autopair)
# 可选：缺了只是少一个功能
EXTRA=(atuin delta lazygit fastfetch neovim fswatch)

# 实际生效的 zsh（登录 shell 是 zsh 就用登录 shell）
zsh_bin() { case ${SHELL:-} in */zsh) echo "$SHELL" ;; *) command -v zsh || echo /bin/zsh ;; esac; }
# 只取 major.minor：Apple 自带 5.9 与 brew 的 5.9.2 视为同一版本
zsh_mm()  { "$1" -fc 'print -r -- $ZSH_VERSION' 2>/dev/null | cut -d. -f1,2; }
brew_ver() { brew list --versions "$1" 2>/dev/null | awk '{print $2}'; }
locked()  { awk -v n="$1" '$1==n{print $2; exit}' "$LOCK" 2>/dev/null; }

# ---------- Homebrew ----------
for b in "$(command -v brew || true)" /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [[ -n $b && -x $b ]] && { eval "$("$b" shellenv)"; break; }
done
if ! command -v brew >/dev/null 2>&1; then
  echo "未找到 Homebrew。先安装:"
  echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 1
fi

# ---------- 记录快照 ----------
if [[ $MODE == snapshot ]]; then
  {
    echo "# 生成: bash setup.sh --snapshot"
    echo "zsh $(zsh_mm "$(zsh_bin)")"
    for f in "${CORE[@]}" "${EXTRA[@]}"; do
      brew list --versions "$f" 2>/dev/null | awk '{print $1, $2}'
    done
  } > "$LOCK"
  echo "已写入 $LOCK:"
  cat "$LOCK"
  exit 0
fi

echo "==> $(uname -s) $(uname -m) · Homebrew: $(brew --prefix)"
if [[ $(uname -m) == arm64 && $(brew --prefix) == /usr/local ]]; then
  echo "   ⚠ 这是 Rosetta 下的 Intel Homebrew。配置两种前缀都认，"
  echo "     但两套 brew 混装会互相覆盖 PATH；建议用 /opt/homebrew 的原生包。"
fi

# ---------- zsh 自身版本 ----------
WANT_ZSH=$(locked zsh)
CUR_ZSH=$(zsh_bin)
echo "==> zsh 版本（快照 ${WANT_ZSH:-未记录}）"
GOT_ZSH=$(zsh_mm "$CUR_ZSH")
if [[ -z $WANT_ZSH || $GOT_ZSH == "$WANT_ZSH" ]]; then
  echo "   $CUR_ZSH → zsh $GOT_ZSH ✓"
else
  echo "   $CUR_ZSH 是 zsh $GOT_ZSH，快照要求 $WANT_ZSH"
  run brew install zsh >/dev/null 2>&1 || echo "   ⚠ brew 装 zsh 失败，版本可能与作者不一致"
  BZ="$(brew --prefix)/bin/zsh"
  echo "   让新 zsh 生效（需要 sudo，脚本不代跑）:"
  echo "     grep -qx $BZ /etc/shells || echo $BZ | sudo tee -a /etc/shells"
  echo "     chsh -s $BZ"
fi

# ---------- 依赖（已装的自动跳过，装不上的不中断）----------
echo "==> 安装依赖"
for f in "${CORE[@]}" "${EXTRA[@]}"; do
  brew list --formula "$f" >/dev/null 2>&1 && continue
  if ! run brew install "$f" >/dev/null 2>&1; then
    [[ " ${CORE[*]} " == *" $f "* ]] && echo "   ⚠ 核心依赖 $f 安装失败，对应功能不可用" \
                                    || echo "   - 跳过 $f"
  fi
done

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

# ---------- 插件（brew 里没有的）----------
echo "==> 插件"
if [[ ! -d $HOME/.local/share/zsh-abbr ]]; then
  run git clone --depth 1 --recurse-submodules \
    https://github.com/olets/zsh-abbr "$HOME/.local/share/zsh-abbr"
else
  echo "   zsh-abbr 已存在"
fi
if [[ ! -d ${COBALT_SPARK_DIR:-$HOME/clone/cobalt-spark} ]]; then
  echo "   - 未安装可选提示符主题 cobalt-spark（不装也能用，提示符退回 zsh 原生）"
  echo "     想装: git clone https://github.com/ayamir/cobalt-spark ~/clone/cobalt-spark"
fi

# ---------- atuin 常驻 ----------
if command -v atuin >/dev/null 2>&1 && [[ $OSTYPE == darwin* ]]; then
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
      got=$(brew_ver "$name")
    fi
    if [[ -z $got ]]; then
      echo "   ✗ $name 未安装（快照 $ver）"; drift=1
    elif [[ $got != "$ver" ]]; then
      echo "   ~ $name $got（快照 $ver）"; drift=1
    fi
  done < "$LOCK"
  (( drift )) && echo "   ↑ 有差异。追求完全一致可 brew install 指定版本，或接受（多数差异无害）。" \
              || echo "   全部一致 ✓"
fi

echo ""
echo "✅ 完成。新开终端，或执行: exec zsh"
echo ""
echo "个人配置放 ~/.zshrc.local（不进 Git，最后加载，可覆盖一切）。示例:"
echo '  abbr -S "hr"="hrelay"                      # 仅本机的缩写'
echo '  export PATH="$HOME/.local/bin:$PATH"       # 机器专属 PATH'
echo '  export EDITOR=nvim                         # 覆盖默认值'
