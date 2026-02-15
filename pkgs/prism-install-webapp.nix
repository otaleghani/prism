{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.gum
    pkgs.curl
    pkgs.coreutils
    pkgs.gnused
  ];
in
writeShellScriptBin "prism-install-webapp" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH

    # 1. Gather Data
    if [ "$#" -lt 3 ]; then
      clear
      gum style --border double --margin "1 2" --padding "1 2" --foreground 212 "PRISM WEBAPP INSTALLER"
      
      APP_NAME=$(gum input --prompt "Name> " --placeholder "e.g. YouTube")
      [ -z "$APP_NAME" ] && exit 1
      
      APP_URL=$(gum input --prompt "URL> " --placeholder "https://youtube.com")
      [ -z "$APP_URL" ] && exit 1
      
      ICON_REF=$(gum input --prompt "Icon URL> " --placeholder "URL to a PNG icon")
      [ -z "$ICON_REF" ] && exit 1
      
      INTERACTIVE_MODE=true
    else
      APP_NAME="$1"
      APP_URL="$2"
      ICON_REF="$3"
      INTERACTIVE_MODE=false
    fi

    # 2. Setup Directories
    ICON_DIR="$HOME/.local/share/applications/icons"
    DESKTOP_DIR="$HOME/.local/share/applications"
    mkdir -p "$ICON_DIR"

    # 3. Handle Icon
    ICON_PATH="$ICON_DIR/$APP_NAME.png"
    if [[ $ICON_REF =~ ^https?:// ]]; then
      echo "[Prism] Downloading icon..."
      if ! curl -sL -o "$ICON_PATH" "$ICON_REF"; then
        gum style --foreground 196 "Error: Failed to download icon."
        exit 1
      fi
    else
      # If it's a local path or reference
      ICON_PATH="$ICON_REF"
    fi

    # 4. Generate the Desktop Entry
    # We point the Exec to prism-focus-webapp so it manages instances correctly
    DESKTOP_FILE="$DESKTOP_DIR/$APP_NAME.desktop"

    cat > "$DESKTOP_FILE" <<EOF
  [Desktop Entry]
  Version=1.0
  Name=$APP_NAME
  Comment=Web Application for $APP_NAME
  Exec=prism-focus-webapp "$APP_NAME" "$APP_URL"
  Terminal=false
  Type=Application
  Icon=$ICON_PATH
  StartupNotify=true
  Categories=Network;WebBrowser;
  EOF

    chmod +x "$DESKTOP_FILE"

    if [ "$INTERACTIVE_MODE" = true ]; then
      gum style --foreground 212 "Success! $APP_NAME is now available in your launcher."
    fi
''
