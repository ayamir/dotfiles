# Wofi file browser


function lsi --description "ls with icons"
  echo "   .. "
  if test "$argv[2]" != ""
    echo "$argv[2] here"
  end
  if test $SHOW_HIDDEN=true
    set all -A
  end
  ls $all $argv[1] | while read entry
    if test -d "$argv[1]/$entry"
      echo "   $entry"
    else
      switch ( echo "$entry" | sed 's/.*\.//' )
        case sh c js
          echo "   $entry"
        case md txt log rc
          echo "   $entry"
        case jpg png svg webp 
          echo "   $entry"
        case fish
          echo "   $entry"
        case py
          echo "   $entry"
        case pdf
          echo "   $entry"
        case mp3 m4a
          echo "   $entry"
        case mp4
          echo "辶   $entry"
        case tar zip
          echo "遲    $entry"
        case '*'
          echo "   $entry"
      end
    end
  end
end

function prompt
  if ! test -f $argv[1]
    set -l name (echo $argv[1] | sed "s|//|/|")
    echo "   Open directory in $FM"
    echo "   Copy "(pwd)
    echo "   Move "(pwd)
    echo "   Delete "(pwd)
  else
    echo "   Launch $argv[1]"
    switch ( echo $argv[1] | sed 's/.*\.//' )
      case png jpeg jpg gif mp4 webp svg
        echo "   Upload $argv[1] to imgur"
      case zip tar.gz
        echo "遲   Extract $argv[1]"
    end
    echo "   Edit $argv[1] in $EDITOR"
    echo "   Send $argv[1] with KDE Connect"
	  echo "  Execute $argv[1]"
    echo "   Copy $argv[1]"
    echo "   Move $argv[1]"
    echo "   Upload $argv[1] to gofile.io"
    echo "   Rename $argv[1]"
    echo "   Delete $argv[1]"
  end
end

function menu --description "file/folder menu options"
  set -l OPTION ( prompt "$argv[1]"\
  			| wofi -i -c ~/wofer/config -s ~/wofer/style.css | sed 's|^[^a-zA-Z0-9]*||' );
  set LOC ''
  if test -d $argv[1]
    set LOC (pwd)
    set d "-r"
  else
    set LOC $argv[1]
  end
  switch (echo "$OPTION" | sed 's/ .*//')
    case Execute
      ./$LOC
      exit
    case Edit
      $TERM -e nvim "$LOC" &
      exit
    case Launch
      launcher "$LOC"
    case Open
      $FM "$LOC" &
      exit
    case Send
      ~/wofer/extensions/kdeconnect "$LOC"
    case Copy
      set -l DESTINATION (wofer "Copy")
      cp $d "$LOC" "$DESTINATION" 
    case Move
      set -l DESTINATION (wofer "Move")
      mv "$LOC" "$DESTINATION" 
      cd "$DESTINATION"
    case Rename
      mv "$LOC" (echo   Enter the new name | wofi -c ~/wofer/config -s ~/wofer/style.css)
    case Upload
      if contains imgur $OPTIONS
        ~/wofer/extensions/imgur "$LOC"
      else
        gofile "$LOC"
        set -l link (wl-paste)
        notify-send 'Done!' (wl-paste) 
      end
    case Extract
      set -l DESTINATION ( wofer "Extract" )
      if unzip -q "$LOC" -d "$DESTINATION"
        :
      else
        tar xzf "$LOC" -C "$DESTINATION"
      end
    case Delete
      rm $d -f "$LOC"
    end
end

function launcher
  switch ( echo "$argv[1]" | sed 's/.*\.//' )
    case jpg jpeg png webp svg gif
      imv "$argv[1]" &
    case md
      export PATH="$HOME/.cargo/bin:$PATH"
      $TERM -e nvim "$argv[1]" -c Illuminate &
    case pdf
      zathura -c ~/.config/zathura/ "$argv[1]" &
    case '*'
      xdg-open "$argv[1]"
    end
  exit
end

function shortcuts
  switch $argv[1]
    case '?'
      menu 
    case ':help'
      xdg-open https://gitlab.com/snakedye/wofer
      exit
    case ':h' ':hidden'
      if test $SHOW_HIDDEN = "true"
        set SHOW_HIDDEN true
      else
        set SHOW_HIDDEN false
      end
    case '!delete'
      rm -r "(pwd)"
    case ':m'
      ~/wofer/extensions/manga &
    case '*'
      if echo $argv[1] | grep '?.*'
        set -l query ( echo "$argv[1]" | grep -o '[^?].*' )
        set -l finder ( fd $query | wofi -i -c ~/wofer/config -s ~/wofer/style.css )
        if ! cd $finder
          menu "$finder"
        end
      else if contains / "$argv[1]"
        cd $argv[1]
      else
        set -l finder (fd $argv[1] | head -1)
        if ! cd "$finder"
          menu "$finder"
      end
    end
  end
end

function wofar
 # set -l TERM alacritty
 set EXTENSIONS ~/wofer/extensions
 # set -l EDITOR nvim
 set FM "$TERM -e ranger"
 set SHOW_HIDDEN false

  while true
    set stdout (lsi (pwd) $argv[1] | wofi -i -c ~/wofer/config -s ~/wofer/style.css | sed 's|^~|/home/bryan|' )
    set ENTRY ( echo "$stdout" | grep -o " .*" | sed "s| *||" )
    if test -z $stdout
      break
    else if test -f "$ENTRY"
      menu "$ENTRY"
    else if test -d "$stdout"
      cd "$stdout"
    else if test -d "$ENTRY"
      cd "$ENTRY"
    else if contains "$argv[1] here" $stdout
      echo (pwd)
      break
    else if test '..'=$ENTRY
      cd ..
    else
      shortcuts $stdout
    end
  end
end
