{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.rofi
    pkgs.coreutils
    pkgs.libnotify
    # Note: We assume prism-* scripts (monitor, theme, wall, tui) are installed in the user profile
  ];
in
writeShellScriptBin "prism-settings" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # --- Options ---
  OPT_CONFIG="  Edit Configuration"
  OPT_DOTFILES="  Edit Dotfiles"
  OPT_WIFI="  Wi-Fi"
  OPT_BLUETOOTH="  Bluetooth"
  OPT_MONITOR="  Monitors"
  OPT_AUDIO="  Audio Mixer"
  OPT_THEME="🎨  Switch Theme"
  OPT_WALL="  Wallpaper Picker"
  OPT_USERS="  Manage Users"
  OPT_TIMEZONE="Change timezone"
  OPT_KEYBOARD="Change keyboard layout"
  OPT_POWER="Power profiles"

  # Menu
  # We could customize the look by creating ~/.config/rofi/settings.rasi
  SELECTED=$(echo -e "$OPT_CONFIG\n$OPT_DOTFILES\n$OPT_WIFI\n$OPT_BLUETOOTH\n$OPT_MONITOR\n$OPT_AUDIO\n$OPT_THEME\n$OPT_WALL\n$OPT_USERS\n$OPT_TIMEZONE\n$OPT_KEYBOARD\n$OPT_POWER" | rofi -dmenu -p "Settings")

  case "$SELECTED" in
    "$OPT_CONFIG")
      # Edit the Flake configuration
      # Assumes your config is at ~/.config/prism
      FLAKE_DIR="/etc/prism"
      if [ -d "$FLAKE_DIR" ]; then
         # Launch editor using prism-focus-tui so it floats and centers
         # Using 'nvim' (or your preferred editor)
         exec prism-focus-tui "nvim" "$FLAKE_DIR"
      else
         notify-send "Prism Settings" "Config not found at ~/.config/prism" -u critical
      fi
      ;;

    "$OPT_DOTFILES")
      exec prism-focus-tui "nvim" "~/.config"
      ;;
      
    "$OPT_WIFI")
      # Launch Impala (TUI Wifi)
      exec prism-focus-tui "impala"
      ;;
      
    "$OPT_BLUETOOTH")
      # Launch Bluetui (TUI Bluetooth)
      exec prism-focus-tui "bluetui"
      ;;
      
    "$OPT_MONITOR")
      # Launch Prism Monitor Wizard
      exec prism-focus-tui prism-monitor
      ;;
      
    "$OPT_AUDIO")
      # Launch WireMix (TUI Audio)
      # If you prefer GUI, change this to: exec pavucontrol
      exec prism-focus-tui "wiremix"
      ;;
      
    "$OPT_THEME")
      # Launch Theme Switcher
      exec prism-theme
      ;;
      
    "$OPT_WALL")
      # Launch Wallpaper Picker
      exec prism-wall select
      ;;

    "$OPT_USERS") 
      exec prism-users 
      ;;

    "$OPT_TIMEZONE") 
      exec prism-timezone
      ;;

    "$OPT_KEYBOARD") 
      exec prism-keyboard
      ;;

    "$OPT_POWER") 
      exec prism-power
      ;;
      
    "$OPT_KEYBINDS") 
      exec prism-keybinds
      ;;
    

    *)
      exit 0
      ;;
  esac
''
