#!/usr/bin/env bash
# herdr-file-jump.sh
#
# A tmux-copy-mode-style file jumper for herdr. Launched from a `popup`
# keybind, it reads the *source* pane's visible text, extracts every
# `path[:line[:column]]` token that resolves to a real file, lets you pick one
# with fzf, and drives `herdr edit` so the first nvim/vim pane in the workspace
# jumps to that location.
#
# It relies on the environment herdr injects into custom popup commands:
#   HERDR_ACTIVE_PANE_ID       pane whose visible text we scan (the source pane)
#   HERDR_ACTIVE_PANE_CWD      cwd used to resolve relative paths
#   HERDR_ACTIVE_WORKSPACE_ID  workspace to open the file in
#   HERDR_BIN_PATH             the running herdr binary (matches HERDR_SOCKET_PATH)
#   HERDR_SOCKET_PATH          server socket (consumed transparently by herdr)

# herdr runs popup commands under a non-login `/bin/sh -c`, which inherits only
# the server's PATH. Make sure Homebrew bins (fzf, a modern bash) are findable,
# then re-exec under bash >= 4 since we use associative arrays (macOS system
# bash is 3.2 and would fail on `declare -A`).
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
if [[ -z ${BASH_VERSINFO:-} || ${BASH_VERSINFO[0]} -lt 4 ]]; then
  for candidate in /opt/homebrew/bin/bash /usr/local/bin/bash; do
    if [[ -x $candidate ]]; then
      exec "$candidate" "$0" "$@"
    fi
  done
fi
set -euo pipefail

herdr=${HERDR_BIN_PATH:-herdr}
pane=${HERDR_ACTIVE_PANE_ID:-}
base_cwd=${HERDR_ACTIVE_PANE_CWD:-$PWD}

# herdr's CLI writes error JSON to stderr and exits nonzero, while payloads go to
# stdout. Capture stderr here so we can surface the real cause of each failure.
err_file=$(mktemp)
trap 'rm -f "$err_file"' EXIT

# Show a message, then wait for a keypress so the user can read it before the
# popup auto-closes on exit.
notify() {
  printf '%s\n\n' "$*" >&2
  printf 'press any key to close…' >&2
  read -rsn1 _ || true
}

# Pull the human-readable "message" out of herdr's error JSON; fall back to the
# raw text if it does not look like our error envelope.
herdr_err_msg() {
  local raw=$1 msg
  msg=$(sed -n 's/.*"message":"\([^"]*\)".*/\1/p' <<<"$raw")
  printf '%s' "${msg:-$raw}"
}

# --- case: no source pane -------------------------------------------------
if [[ -z $pane ]]; then
  notify "herdr-file-jump: no source pane (HERDR_ACTIVE_PANE_ID unset)."
  exit 0
fi

# --- case: pane read failed (pane gone, server down, bad binary) ----------
if ! visible=$("$herdr" pane read "$pane" --source visible 2>"$err_file"); then
  notify "herdr-file-jump: could not read pane $pane: $(herdr_err_msg "$(cat "$err_file")")"
  exit 0
fi

# --- case: screen is blank or whitespace-only -----------------------------
if [[ -z ${visible//[[:space:]]/} ]]; then
  notify "herdr-file-jump: source pane $pane screen is empty."
  exit 0
fi

# Expand a token into an absolute path, resolving relative tokens against the
# source pane's cwd. Prints nothing for a token that is not a real file.
resolve() {
  local p=$1 abs
  case $p in
    /*) abs=$p ;;
    "~/"*) abs=${p/#\~/$HOME} ;;
    *) abs=$base_cwd/$p ;;
  esac
  [[ -f $abs ]] && printf '%s' "$abs"
}

# Ordered, de-duplicated candidate list. Each fzf row is TSV:
#   <display>\t<abspath>\t<line>\t<column>
declare -A seen=()
candidates=()

add_candidate() {
  local token=$1 path line col abs key display
  # Strip wrapping punctuation the terminal often puts around a path.
  token=${token#[\(\[\{\'\"\`,]}
  token=${token%[\)\]\}\'\"\`,]}
  token=${token%:}

  if [[ $token =~ ^(.+):([0-9]+):([0-9]+)$ ]]; then
    path=${BASH_REMATCH[1]}; line=${BASH_REMATCH[2]}; col=${BASH_REMATCH[3]}
  elif [[ $token =~ ^(.+):([0-9]+)$ ]]; then
    path=${BASH_REMATCH[1]}; line=${BASH_REMATCH[2]}; col=""
  else
    path=$token; line=""; col=""
  fi

  abs=$(resolve "$path") || return 0
  [[ -z $abs ]] && return 0

  key="$abs:$line:$col"
  [[ -n ${seen[$key]:-} ]] && return 0
  seen[$key]=1

  display=$path
  [[ -n $line ]] && display+=":$line"
  [[ -n $col ]] && display+=":$col"
  candidates+=("$(printf '%s\t%s\t%s\t%s' "$display" "$abs" "$line" "$col")")
}

# Scan every whitespace-delimited word on the screen.
while IFS= read -r word; do
  [[ -n $word ]] && add_candidate "$word"
done < <(tr -s '[:space:]' '\n' <<<"$visible")

# --- case: no file paths on the screen ------------------------------------
if [[ ${#candidates[@]} -eq 0 ]]; then
  notify "herdr-file-jump: no existing file paths found on pane $pane's screen."
  exit 0
fi

selection=$(
  printf '%s\n' "${candidates[@]}" |
    fzf --delimiter=$'\t' --with-nth=1 \
        --prompt='jump> ' --height=100% --border --reverse
) || exit 0
# --- case: selection cancelled (Esc / no pick) ----------------------------
[[ -z $selection ]] && exit 0

IFS=$'\t' read -r _display abspath line col <<<"$selection"

args=("$abspath")
[[ -n $line ]] && args+=(--line "$line")
[[ -n $col ]] && args+=(--column "$col")
[[ -n ${HERDR_ACTIVE_WORKSPACE_ID:-} ]] && args+=(--workspace "$HERDR_ACTIVE_WORKSPACE_ID")

# --- case: edit failed (no workspace, send failed, etc.) ------------------
if ! "$herdr" edit "${args[@]}" >/dev/null 2>"$err_file"; then
  notify "herdr-file-jump: could not open $abspath: $(herdr_err_msg "$(cat "$err_file")")"
  exit 0
fi
