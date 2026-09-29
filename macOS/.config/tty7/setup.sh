#!/usr/bin/env bash
# New-machine tty7 setup: copy this repo's config into place.
#
#   bash ~/clone/dotfiles/macOS/.config/tty7/setup.sh
#
# Needs tty7 installed first; its CLI lives inside the app bundle:
#   ln -sf /Applications/tty7.app/Contents/MacOS/tty7 /opt/homebrew/bin/tty7
set -euo pipefail

src="$(cd "$(dirname "$0")" && pwd)"
dst="${TTY7_CONFIG_DIR:-$HOME/.config/tty7}"

mkdir -p "$dst/themes"
cp -R "$src/themes/." "$dst/themes/"

# The tracked config.json is sanitized: ssh_profiles is empty, so importing
# ~/.ssh/config on the new machine is what fills them back in. A config that
# already exists stays untouched — it may hold that machine's own profiles.
if [ -f "$dst/config.json" ]; then
	echo "kept existing $dst/config.json; repo copy is at $src/config.json" >&2
else
	cp "$src/config.json" "$dst/"
fi

if command -v tty7 >/dev/null; then
	tty7 doctor 2>&1 | head -8
else
	echo "warn: tty7 CLI not on PATH; link it from the app bundle" >&2
fi
