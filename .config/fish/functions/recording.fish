function recording --description 'stop button for wf-recorder'
  if pgrep wf-recorder
    set -l text (swaymsg -t get_tree | jq  -r  '.nodes[].nodes[] | if .nodes then [recurse(.nodes[])] else [] end + .floating_nodes | .[] | select(.nodes==[]) | ((.id | tostring) + " " + .name)' | awk '{print $2}' | grep recorder)
    set -l tooltip "$text - recording"
    echo '{"text": "壘", "tooltip": "'"$tooltip"'" }'
  end
end
