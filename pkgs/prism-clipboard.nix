{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.rofi
    pkgs.cliphist
    pkgs.wl-clipboard
    pkgs.libnotify
  ];
in
writeShellScriptBin "prism-clipboard" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Check if arguments passed (e.g. --wipe)
  if [ "$1" == "--wipe" ]; then
      cliphist wipe
      notify-send "Clipboard" "History cleared" -i edit-clear
      exit 0
  fi

  # Show History
  # cliphist list: Shows history
  # rofi: Selection menu
  # cliphist decode: Turns the selection back into the actual text/image
  # wl-copy: Puts it back into your active clipboard

  SELECTED=$(cliphist list | rofi -dmenu -p "Clipboard" -display-columns 2)

  if [ -n "$SELECTED" ]; then
      echo "$SELECTED" | cliphist decode | wl-copy
      notify-send "Clipboard" "Copied to clipboard" -i edit-copy
  fi
''
