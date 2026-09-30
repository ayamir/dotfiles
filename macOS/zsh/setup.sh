#!/bin/bash
# Zsh 配置安装脚本（macOS / Apple Silicon）
# 用法: bash setup.sh
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> [1/5] 检查 Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  echo "  未安装 Homebrew，请先执行:"
  echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 1
fi

echo "==> [2/5] 安装依赖（brew）"
brew install \
  fzf fd ripgrep zoxide direnv mise \
  eza bat delta lazygit fastfetch neovim \
  fzf-tab zsh-autopair zsh-syntax-highlighting zsh-autosuggestions \
  atuin fswatch

echo "==> [3/5] 链接 ~/.zshrc"
if [[ -e "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
  mv "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%s)"
fi
ln -sf "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"

echo "==> [4/5] 部署缩写文件"
mkdir -p "$HOME/.config/zsh-abbr"
cp -f "$DOTFILES_DIR/user-abbreviations" "$HOME/.config/zsh-abbr/user-abbreviations"

echo "==> [5/5] 克隆插件与主题"
mkdir -p "$HOME/clone" "$HOME/.local/share"
if [[ ! -d "$HOME/clone/cobalt-spark" ]]; then
  git clone https://github.com/ayamir/cobalt-spark.git "$HOME/clone/cobalt-spark"
fi
if [[ ! -d "$HOME/.local/share/zsh-abbr" ]]; then
  git clone --depth 1 --recurse-submodules https://github.com/olets/zsh-abbr "$HOME/.local/share/zsh-abbr"
fi

echo "==> 启动 atuin 守护进程"
brew services start atuin || true

echo ""
echo "✅ 完成！新开一个终端，或执行: source ~/.zshrc"
echo ""
echo "提示:"
echo "  - 缩写文件是拷贝过去的（不是软链）。之后若在终端用 abbr 命令新增了缩写，"
echo "    想同步回 dotfiles 就执行: cp ~/.config/zsh-abbr/user-abbreviations $DOTFILES_DIR/user-abbreviations"
echo "  - 本脚本面向 Apple Silicon（/opt/homebrew）。Intel Mac 需把 .zshrc 里的"
echo "    /opt/homebrew 相关路径改成 /usr/local"
