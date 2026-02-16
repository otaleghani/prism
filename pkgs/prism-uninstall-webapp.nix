{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.gum
    pkgs.findutils
    pkgs.gnugrep
    pkgs.coreutils
    pkgs.libnotify
  ];
in
writeShellScriptBin "prism-uninstall-webapp" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  ICON_DIR="$HOME/.local/share/applications/icons"
  DESKTOP_DIR="$HOME/.local/share/applications"

  # Terminal auto-launch
  # Ensures the interactive picker opens in a Prism terminal if launched via GUI
  if [ ! -t 0 ]; then
    if command -v prism-tui >/dev/null; then
        exec prism-tui "$0" "$@"
    fi
  fi

  # Discovery logic
  # Scans for desktop entries containing the Prism webapp execution string
  mapfile -t WEB_APPS < <(grep -l "prism-focus-webapp" "$DESKTOP_DIR"/*.desktop 2>/dev/null | xargs -n1 basename | sed 's/\.desktop//')

  if [ ''${#WEB_APPS[@]} -eq 0 ]; then
    notify-send "Prism Webapp" "No custom webapps found to remove." -u low
    exit 0
  fi

  # Selection interface
  # Presents a multi-select list of managed webapps via gum choose
  if [ "$#" -eq 0 ]; then
    clear
    gum style --border double --margin "1 2" --padding "1 2" --foreground 1 "Prism Webapp Uninstaller"
    
    SELECTED_APPS=$(printf "%s\n" "''${WEB_APPS[@]}" | gum choose --no-limit --header "Select apps to remove (Space to mark, Enter to confirm)")
    [ -z "$SELECTED_APPS" ] && exit 0
    mapfile -t TO_REMOVE <<< "$SELECTED_APPS"
  else
    TO_REMOVE=("$@")
  fi

  # Deletion sequence
  # Purges both the desktop entry and the associated icon asset
  for APP in "''${TO_REMOVE[@]}"; do
    if [ -n "$APP" ]; then
      echo "Removing $APP..."
      rm -f "$DESKTOP_DIR/$APP.desktop"
      rm -f "$ICON_DIR/$APP.png" || true
    fi
  done

  # Finalization
  # Provides a system-wide confirmation of successful cleanup
  notify-send "Prism Webapp" "Successfully removed ''${#TO_REMOVE[@]} webapp(s)." -i trash-can
''
