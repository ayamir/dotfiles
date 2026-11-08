#!/usr/bin/env bash
# zsh 配置安装脚本 — macOS / Linux 通用
# 用法: bash setup.sh          安装
#       bash setup.sh --dry-run  只看会做什么
set -uo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
DRY=0
[[ ${1:-} == --dry-run ]] && DRY=1
run() { (( DRY )) && echo "   [dry] $*" || "$@"; }

# ---------- Homebrew ----------
for b in "$(command -v brew || true)" /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [[ -n $b && -x $b ]] && { eval "$("$b" shellenv)"; break; }
done
if ! command -v brew >/dev/null 2>&1; then
  echo "未找到 Homebrew。先安装:"
  echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 1
fi
echo "==> $(uname -s) $(uname -m) · Homebrew: $(brew --prefix)"
if [[ $(uname -m) == arm64 && $(brew --prefix) == /usr/local ]]; then
  echo "   ⚠ 这是 Rosetta 下的 Intel Homebrew。配置两种前缀都认，"
  echo "     但两套 brew 混装会互相覆盖 PATH；建议用 /opt/homebrew 的原生包。"
fi

# ---------- 依赖（已装的自动跳过，装不上的不中断）----------
# 核心：配置里大部分增强都靠它们；eza/bat 是缩写文件的默认值
CORE=(eza bat fzf fd ripgrep zoxide direnv mise
      zsh-autosuggestions zsh-syntax-highlighting fzf-tab zsh-autopair)
# 可选：缺了只是少一个功能
EXTRA=(atuin delta lazygit fastfetch neovim fswatch)

echo "==> 安装依赖"
for f in "${CORE[@]}" "${EXTRA[@]}"; do
  if brew list --formula "$f" >/dev/null 2>&1; then
    continue
  fi
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
if command -v atuin >/dev/null 2>&1 && command -v brew >/dev/null 2>&1; then
  [[ $OSTYPE == darwin* ]] && run brew services start atuin >/dev/null 2>&1 || true
fi

echo ""
echo "✅ 完成。新开终端，或执行: exec zsh"
echo ""
echo "个人配置放 ~/.zshrc.local（不进 Git，最后加载，可覆盖一切）。示例:"
echo '  abbr -S "hr"="hrelay"                      # 仅本机的缩写'
echo '  export PATH="$HOME/.local/bin:$PATH"       # 机器专属 PATH'
echo '  export EDITOR=nvim                         # 覆盖默认值'
