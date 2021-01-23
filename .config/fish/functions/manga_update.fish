# Update manga library

function update_mangas --description 'Udate my manag library'
  ls ~/.mangas/ | while read manga
    echo "$manga"
    set url ( cat ~/.mangas/$manga/.url )
    set chap (ls ~/.mangas/$manga | sort -r | sed -n "1p" | grep -o "^[a-z0-9]*" | sed "s/[a-z]//g" | sed "s/0*//")
    chap="$(($CHAP+1))"
    add_manga $url $chap
  end
end
