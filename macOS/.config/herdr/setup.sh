#!/usr/bin/env bash
# New-machine herdr setup: copy the configs into place, then install the four
# plugins this repo was exported from, pinned to the same commits.
#
#   bash ~/clone/dotfiles/macOS/.config/herdr/setup.sh
#
# Build deps herdr runs during install: cargo (agent-progress, herdr-projects),
# node (herdr-radar), curl+bash (annotate). Run `tsk setup herdr` separately if
# you also want the tsk board plugin (tsk ships its own installer).
set -euo pipefail

src="$(cd "$(dirname "$0")" && pwd)"
dst="${XDG_CONFIG_HOME:-$HOME/.config}/herdr"

command -v herdr >/dev/null || {
	echo "herdr not installed: https://herdr.dev" >&2
	exit 1
}

mkdir -p "$dst/plugins/config"
cp "$src/config.toml" "$src/config-gpui.toml" "$src/herdr-file-jump.sh" "$dst/"
cp -R "$src/plugins/config/." "$dst/plugins/config/"

for c in cargo node curl; do
	command -v "$c" >/dev/null || echo "warn: $c missing; a plugin build needs it" >&2
done

# Pinned refs as installed on the exporting machine (herdr plugin list).
herdr plugin install eliasstravik/herdr-agent-progress --ref 7f3a3fe4f197686703749f65d48bc281caca5df8 --yes
herdr plugin install plannotator/herdr-annotate --ref d02b0b42cf1955a3b206959659f1833622f213b8 --yes
herdr plugin install eliasstravik/herdr-projects --ref a4cdb0a69713d982d96f9062548cf885f013c442 --yes
herdr plugin install hhdebb/herdr-radar --ref 1869b06800ac5466ab8da1754c41b14aa880bbb8 --yes

echo "done; restart herdr, then check: herdr plugin list"
