# gofile api for fish

function gofile --description 'Upload files'
  set file "$argv[1]"
  set email 'ndjeutcha@gmail.com'
  set server 'srv-store1'
  # Uncomment if you don't already know your server. I recommend running this command once to make things faster once and for all.
  # set server (curl https://apiv2.gofile.io/getServer | jq .data.server | sed 's/["]//g')
  set message (curl -sF email="$email" -F file=@"$file" https://"$server".gofile.io/uploadFile)
  set code (echo $message | jq .data.code | sed 's/["]//g')
  echo $message >> "$HOME/.config/gofile/log"
  set -l url "https://gofile.io/d/$code"
  wl-copy "$url"
  notify-send "$file - $email" "$url" -i (pwd)/$file
end

