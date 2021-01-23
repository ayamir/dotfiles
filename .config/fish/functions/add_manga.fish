# Add manga to library

function add_manga --description "Add manga to my library"
  set -l old (ls -t ~/.mangas | head -1)
  set -l url "$argv[1]"
  set -l number "$argv[2]"
  printf "$url\n$number" | ./mangadex-dl.py
  set -l new (ls -t ~/.mangas | head -1)

  if test "$old" != "$new"
    touch ~/.mangas/$new/.url
    mkdir ~/.mangas/$new/.chapter
    set url (curl "$url/covers/" | grep -o 'https://mangadex.org/images/covers.*?' | sed 's/["].*//'| sort -r  |head -1)
    curl -o "/home/$USER/.mangas/.covers/$new.jpg" $url
    echo "$url" > ~/.mangas/$new/.url
  end
  set chap (ls -t ~/.mangas/$NEW/ | head -1 )
  set dir "'/home/$USER/.mangas/$NEW/$chap'"
  touch ~/.mangas/$new/.chapter/$new$number.desktop
  echo "[Desktop Entry]
Type=Application
Name=$new Ch.$number
Icon=/home/$USER/.mangas/.covers/$new.jpg
Exec=cd $dir ; ls ./ | imv
Categories=Manga" > ~/.mangas/$new/.chapter/$new$number.desktop
end
