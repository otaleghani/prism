{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.rofi
    pkgs.coreutils
    pkgs.libnotify
  ];
in
writeShellScriptBin "prism-settings" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Menu definitions
  # Standardized labels for the Rofi selection interface
  OPT_CONFIG="󱇦  Edit system configuration"
  OPT_DOTFILES="󰏘  Edit dotfiles"
  OPT_THEME="󱥚  Switch theme"
  OPT_WALL="󰸉  Wallpaper picker"
  OPT_FONT="󰬶  Change system font"
  OPT_WIFI="󰖩  Wi-Fi configuration"
  OPT_BT="󰂯  Bluetooth configuration"
  OPT_AUDIO="󱄠  Audio mixer"
  OPT_WEB_INS="󰖟  Install webapp"
  OPT_WEB_REM="󰖟  Uninstall webapp"
  OPT_KB="󰌌  Change keyboard layout"
  OPT_POWER="󰓅  Change power profile"
  OPT_UPDATE="󰚰  Update system (Stable)"
  OPT_UPDATE_UN="󱓞  Update system (Unstable)"

  # Selection interface
  # Compiles options into a searchable list
  OPTIONS=(
    "$OPT_CONFIG"
    "$OPT_DOTFILES"
    "$OPT_THEME"
    "$OPT_WALL"
    "$OPT_FONT"
    "$OPT_WIFI"
    "$OPT_BT"
    "$OPT_AUDIO"
    "$OPT_WEB_INS"
    "$OPT_WEB_REM"
    "$OPT_KB"
    "$OPT_POWER"
    "$OPT_UPDATE"
    "$OPT_UPDATE_UN"
  )

  # Launch rofi
  SELECTED=$(printf "%s\n" "''${OPTIONS[@]}" | rofi -dmenu -p "Settings" -i -no-show-icons)

  # Execution logic
  # Routes selection to the corresponding Prism utility
  case "$SELECTED" in
    "$OPT_CONFIG")
      # Focuses the editor on the root flake directory
      FLAKE_DIR="/etc/prism"
      [ -d "$FLAKE_DIR" ] || FLAKE_DIR="$HOME/.config/prism"
      exec prism-focus-tui "nvim" "$FLAKE_DIR"
      ;;

    "$OPT_DOTFILES")
      exec prism-focus-tui "nvim" "$HOME/.config"
      ;;

    "$OPT_THEME")
      exec prism-theme
      ;;

    "$OPT_WALL")
      # exec prism-wall select
      exec prism-ctl wallpapers
      ;;

    "$OPT_FONT")
      # Triggers the font manager (will auto-launch prism-tui)
      exec prism-tui prism-font
      ;;

    "$OPT_WIFI")
      exec prism-focus-tui "impala"
      ;;

    "$OPT_BT")
      exec prism-focus-tui "bluetui"
      ;;

    "$OPT_AUDIO")
      exec prism-focus-tui "wiremix"
      ;;

    "$OPT_WEB_INS")
      # Interactive webapp creation
      exec prism-tui prism-install-webapp
      ;;

    "$OPT_WEB_REM")
      # Interactive webapp removal
      exec prism-tui prism-uninstall-webapp
      ;;

    "$OPT_KB")
      exec prism-keyboard
      ;;

    "$OPT_POWER")
      # Assumes a prism-power TUI or picker exists
      exec prism-power
      ;;

    "$OPT_UPDATE")
      # Stable track update via terminal portal
      exec prism-tui prism-update
      ;;

    "$OPT_UPDATE_UN")
      # Unstable track update via terminal portal
      exec prism-tui prism-update unstable
      ;;

    *)
      exit 0
      ;;
  esac
''
