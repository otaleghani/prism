{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.gum
    pkgs.curl
    pkgs.coreutils
    pkgs.gnused
    pkgs.libnotify
  ];
in
writeShellScriptBin "prism-install-webapp" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH

    # Terminal auto-launch
    if [ ! -t 0 ]; then
      if command -v prism-tui >/dev/null; then
          exec prism-tui "$0" "$@"
      else
          notify-send "Prism Webapp" "Terminal wrapper not found." -u critical
          exit 1
      fi
    fi

    # Data collection
    # Checks for arguments or triggers interactive TUI mode
    if [ "$#" -lt 3 ]; then
      clear
      gum style --border double --margin "1 2" --padding "1 2" --foreground 2 "Prism Webapp Installer"
      
      APP_NAME=$(gum input --prompt "Name> " --placeholder "e.g. YouTube")
      [ -z "$APP_NAME" ] && exit 0
      
      APP_URL=$(gum input --prompt "URL> " --placeholder "https://youtube.com")
      [ -z "$APP_URL" ] && exit 0
      
      ICON_REF=$(gum input --prompt "Icon URL> " --placeholder "URL to a PNG icon")
      [ -z "$ICON_REF" ] && exit 0
      
      INTERACTIVE_MODE=true
    else
      APP_NAME="$1"
      APP_URL="$2"
      ICON_REF="$3"
      INTERACTIVE_MODE=false
    fi

    # Directory preparation
    ICON_DIR="$HOME/.local/share/applications/icons"
    DESKTOP_DIR="$HOME/.local/share/applications"
    mkdir -p "$ICON_DIR"

    # Icon processing
    # Downloads remote assets or references local paths
    ICON_PATH="$ICON_DIR/$APP_NAME.png"
    if [[ $ICON_REF =~ ^https?:// ]]; then
      echo "Downloading icon for $APP_NAME..."
      curl -sL -o "$ICON_PATH" "$ICON_REF" || {
        notify-send "Prism Webapp" "Failed to download icon for $APP_NAME." -u critical
        [ "$INTERACTIVE_MODE" = true ] && read -n 1 -s -p "Press any key to exit..."
        exit 1
      }
    else
      ICON_PATH="$ICON_REF"
    fi

    # Desktop entry generation
    # Points execution to prism-focus-webapp for instance management
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

    # Success feedback
    notify-send "Prism Webapp" "Installed $APP_NAME successfully. Available in launcher." -i system-software-install

    if [ "$INTERACTIVE_MODE" = true ]; then
      echo ""
      gum style --foreground 2 "Success! $APP_NAME has been integrated into Prism."
      echo "Press any key to close..."
      read -n 1 -s
    fi
''
