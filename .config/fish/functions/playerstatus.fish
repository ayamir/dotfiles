function playerstatus --description "player status"
  set mpris_status (playerctl status)
  if pgrep cmus
    set text (cmus-remote -C "format_print '%a - %t'")
    set tooltip "cmus - playing"
    set mpris_status "Music"
  else
    set text (playerctl metadata title)
    set tooltip (playerctl metadata --format "{{ playerName }} : {{ title }}")
  end
    echo '{"text": "'"$text"'", "alt": "'"$mpris_status"'", "tooltip": "'"$tooltip"'", "class": "'"$mpris_status"'" }'
end
