{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.gum
    pkgs.findutils
    pkgs.gnugrep
    pkgs.coreutils
  ];
in
writeShellScriptBin "prism-uninstall-webapp" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  ICON_DIR="$HOME/.local/share/applications/icons"
  DESKTOP_DIR="$HOME/.local/share/applications"

  # 1. Find apps managed by Prism
  # We look for the "prism-focus-webapp" string inside desktop files
  mapfile -t WEB_APPS < <(grep -l "prism-focus-webapp" "$DESKTOP_DIR"/*.desktop 2>/dev/null | xargs -n1 basename | sed 's/\.desktop//')

  if [ ''${#WEB_APPS[@]} -eq 0 ]; then
    gum style --foreground 196 "No custom Prism webapps found."
    exit 0
  fi

  # 2. Interactive Selection
  if [ "$#" -eq 0 ]; then
    SELECTED_APPS=$(printf "%s\n" "''${WEB_APPS[@]}" | gum choose --no-limit --header "Select apps to remove (Space to select, Enter to confirm)")
    [ -z "$SELECTED_APPS" ] && exit 0
    # Convert newline-separated list to array
    mapfile -t TO_REMOVE <<< "$SELECTED_APPS"
  else
    TO_REMOVE=("$@")
  fi

  # 3. Deletion
  for APP in "''${TO_REMOVE[@]}"; do
    if [ -n "$APP" ]; then
      echo "[Prism] Removing $APP..."
      rm -f "$DESKTOP_DIR/$APP.desktop"
      rm -f "$ICON_DIR/$APP.png"
    fi
  done

  gum style --foreground 212 "Uninstallation complete."
''
