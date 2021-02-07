# Add manga to library

function addmanga --description "Add manga to my library"
  set -l old (ls -t ~/.mangas | wc -l)
  set -l url "$argv[1]"
  set -l number (math $argv[2]+1)
  set -l latest (ls -t ~/.mangas/(ls -t ~/.mangas | head -1) | head -1)
  if echo $url | grep -o 'mangadex'
    printf "$url\n$number" | ./mangadex-dl.py
  else
    ~/.mangadl-bash/mangadl $url -d ~/.mangas/ -r $number
  end
  set -l new (ls -t ~/.mangas | wc -l)
  set title (ls -t ~/.mangas | head -1)
  if test $new -gt $old
    mkdir ~/.mangas/$title/.chapter/
    if echo $url | grep -o 'mangadex'
      echo "$url" > ~/.mangas/$title/.url
      set url (curl -s "$url/covers/" | grep -o 'https://mangadex.org/images/covers.*?' | sed 's/["].*//'| sort -r  |head -1)
      curl -o "$HOME/.mangas/.covers/$title.jpg" $url
    end
  end
  set -l nlatest (ls -t ~/.mangas/(ls -t ~/.mangas | head -1) | head -1)
  if test "$nlatest" != "$latest"
    set chap (ls -t ~/.mangas/$title/ | head -1 )
    set dir (echo "$HOME/.mangas/$title/$chap" | sed 's| |\\\ |g')
    set number (math $number-1)
    touch ~/.mangas/$title/.chapter/$title$number.desktop
    echo "[Desktop Entry]
Type=Application
Name=$title Ch.$number
Icon=$HOME/.mangas/.covers/$title.jpg
Exec=fish -c '"openmanga $dir"'
Categories=Manga" > ~/.mangas/$title/.chapter/$title$number.desktop
  end
end
