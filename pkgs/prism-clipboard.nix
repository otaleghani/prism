{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.rofi
    pkgs.cliphist
    pkgs.wl-clipboard
    pkgs.libnotify
    pkgs.coreutils
  ];
in
writeShellScriptBin "prism-clipboard" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Management logic
  # Allows for total history erasure via command line flag
  if [ "$1" == "--wipe" ]; then
      cliphist wipe || {
          notify-send "Prism Clipboard" "Failed to clear history." -u critical
          exit 1
      }
      notify-send "Prism Clipboard" "History cleared successfully." -i edit-clear
      exit 0
  fi

  # Selection interface
  # Retrieves history list and presents it via rofi
  SELECTED=$(cliphist list | rofi -dmenu -p "Clipboard" -display-columns 2)

  # Processing logic
  # Decodes the selected item and pushes it to the system clipboard
  if [ -n "$SELECTED" ]; then
      echo "$SELECTED" | cliphist decode | wl-copy || {
          notify-send "Prism Clipboard" "Failed to decode selection." -u critical
          exit 1
      }
      
      # Feedback loop
      # Extract a snippet of the text for the notification
      SNIPPET=$(echo "$SELECTED" | cut -c 1-30)
      notify-send "Prism Clipboard" "Copied: $SNIPPET..." -i edit-copy
  fi
''
