#!/usr/bin/env bash
set -euo pipefail

log_dir="${XDG_STATE_HOME:-$HOME/.local/state}/hyprexpo"
mkdir -p "$log_dir"
log_file="$log_dir/install-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$log_file") 2>&1
printf '安装日志：%s\n' "$log_file"
trap 'rc=$?; printf "安装失败（退出码 %s），位置：第 %s 行，命令：%s\n日志：%s\n" "$rc" "$LINENO" "$BASH_COMMAND" "$log_file" >&2; exit "$rc"' ERR

# Pinned by upstream hyprpm.toml for Hyprland 0.56.2.
revision=59bf4d378cecde9ed849e9c562306738b1583016
hypr_revision=efb50993780079460b0cbed1363e2166a2de1d9f
die() { printf '%s\n' "$*" >&2; exit 1; }
for tool in git make g++ pkg-config python3 hyprctl; do
  command -v "$tool" >/dev/null || die "缺少命令：$tool"
done
if ! version=$(hyprctl version 2>&1); then
  printf '首次连接桌面失败：\n%s\n' "$version"
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
  shopt -s nullglob
  candidates=("$XDG_RUNTIME_DIR"/hypr/*/.socket.sock)
  shopt -u nullglob
  if (( ${#candidates[@]} == 1 )); then
    instance_dir=${candidates[0]%/.socket.sock}
    export HYPRLAND_INSTANCE_SIGNATURE="${instance_dir##*/}"
    printf '尝试连接桌面会话：%s\n' "$HYPRLAND_INSTANCE_SIGNATURE"
    if ! version=$(hyprctl version 2>&1); then
      printf '%s\n' "$version" >&2
      die '无法连接桌面接口。请在当前 Omarchy 桌面的终端中运行此脚本（不要使用 sudo）。'
    fi
  else
    die '无法唯一确定 Hyprland 会话。请在当前 Omarchy 桌面的终端中运行此脚本（不要使用 sudo）。'
  fi
fi
[[ "$version" == *"$hypr_revision"* ]] || die '请在运行 Hyprland 0.56.2 的桌面终端中执行。当前版本不匹配或无法连接桌面。'
[[ $(pkg-config --modversion hyprland) == 0.56.2 ]] || die 'Hyprland 头文件版本不匹配。'
lua_pkg=lua5.4
pkg-config --exists "$lua_pkg" || lua_pkg=lua
pkg-config --print-errors --exists hyprland pixman-1 libdrm pangocairo libinput libudev wayland-server xkbcommon "$lua_pkg"

printf '%s\n' '1/3 下载匹配版本并编译（无需 sudo）'
build_dir=$(mktemp -d "${TMPDIR:-/tmp}/hyprexpo-build.XXXXXXXX")
trap 'rm -rf -- "$build_dir"' EXIT
git -C "$build_dir" init -q
git -C "$build_dir" remote add origin https://github.com/sandwichfarm/hyprexpo.git
git -C "$build_dir" fetch --depth=1 origin "$revision"
git -C "$build_dir" checkout --detach FETCH_HEAD
[[ $(git -C "$build_dir" rev-parse HEAD) == "$revision" ]] || die '源码版本检查失败。'
make -C "$build_dir" all LUA_PKG_CONFIG="$lua_pkg"

printf '%s\n' '2/3 安装插件并配置四指上滑 / 下滑'
plugin_dir="$HOME/.local/lib/hyprland/hyprexpo/$revision"
mkdir -p "$plugin_dir"
# Rename atomically; never overwrite a potentially mapped shared library in place.
install -m755 "$build_dir/hyprexpo.so" "$plugin_dir/hyprexpo.so.new"
mv -f "$plugin_dir/hyprexpo.so.new" "$plugin_dir/hyprexpo.so"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 - "$script_dir/../.config/hypr/hyprexpo.lua" <<'PY'
import datetime
from pathlib import Path
import shutil
import sys

directory = Path.home() / '.config/hypr'
stamp = datetime.datetime.now().strftime('%Y%m%d%H%M%S%f')
main = directory / 'hyprland.lua'
module = directory / 'hyprexpo.lua'
for file in (main, module):
    if file.exists():
        shutil.copy2(file, str(file) + '.bak.' + stamp)
template = Path(sys.argv[1])
if template.resolve() != module.resolve():
    module.write_text(template.read_text())
source = main.read_text()
line = 'require("hypr.hyprexpo")'
if line not in source:
    main.write_text(source.rstrip() + '\n\n-- 四指上滑显示工作区预览。\n' + line + '\n')
print('配置备份后缀：.bak.' + stamp)
PY

printf '%s\n' '3/3 加载并检查'
hyprctl reload
loaded=$(hyprctl plugin list)
printf '%s\n' "$loaded"
[[ "$loaded" == *hyprexpo* ]] || die '插件未加载成功。请保留以上输出，以便排查。'
errors=$(hyprctl configerrors)
printf '%s\n' "$errors"
[[ -z "${errors//[[:space:]]/}" || "$errors" == 'ok' ]] || die '检测到配置错误，请保留以上输出。'
printf '%s\n' '已完成。四指上滑显示 1–9 工作区预览；点击选择，四指下滑或 Escape 返回。'
