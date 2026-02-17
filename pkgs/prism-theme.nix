{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.rofi
    pkgs.jq
    pkgs.gawk
    pkgs.glib
    pkgs.coreutils
    pkgs.hyprland
    pkgs.procps
    pkgs.libnotify
  ];
in
writeShellScriptBin "prism-theme" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Path configuration
  # Defines central storage and the active 'current' symlink
  BASE_DIR="$HOME/.local/share/prism"
  THEMES_DIR="$BASE_DIR/themes"
  CURRENT_LINK="$BASE_DIR/current"

  cmd="$1"

  # Theme discovery
  list_themes() {
    ls -1 "$THEMES_DIR"
  }

  # Selection interface
  # Launches rofi for interactive picking if no argument is provided
  if [ -z "$cmd" ]; then
    SELECTED=$(list_themes | rofi -dmenu -p "Theme")
    [ -z "$SELECTED" ] && exit 0
    cmd="$SELECTED"
  fi

  TARGET_THEME="$THEMES_DIR/$cmd"

  # Validation logic
  if [ ! -d "$TARGET_THEME" ]; then
    notify-send "Prism Theme" "Error: Theme '$cmd' not found." -u critical
    exit 1
  fi

  # Symlink management
  # Updates the global pointer to the newly selected theme directory
  ln -sfn "$TARGET_THEME" "$CURRENT_LINK"

  # Compositor reload
  # Forces Hyprland to re-parse configurations
  if pgrep Hyprland > /dev/null; then
    hyprctl reload
  fi

  # Multiplexer synchronization
  # Re-sources tmux config to pick up new theme variables
  if pgrep tmux > /dev/null; then
    tmux source-file ~/.config/tmux/tmux.conf >/dev/null 2>&1
  fi

  # Terminal hot-reload
  # Uses SIGUSR2 to trigger Ghostty's internal config refresh
  if pgrep ghostty > /dev/null; then
    kill -SIGUSR2 $(pidof ghostty)
  fi

  # CLI Tool theming
  # Links specific tool configs to the current theme assets
  [ -f "$TARGET_THEME/yazi.toml" ] && {
      mkdir -p "$HOME/.config/yazi"
      ln -sf "$CURRENT_LINK/yazi.toml" "$HOME/.config/yazi/theme.toml"
  }

  [ -f "$TARGET_THEME/btop.theme" ] && {
      mkdir -p "$HOME/.config/btop/themes"
      ln -sf "$CURRENT_LINK/btop.theme" "$HOME/.config/btop/themes/prism.theme"
  }


  # Media configuration
  # Merges theme-specific MPV settings with the base config
  MPV_CONFIG_DIR="$HOME/.config/mpv"
  if [ -d "$MPV_CONFIG_DIR" ] && [ -f "$MPV_CONFIG_DIR/base.conf" ]; then
      if [ -f "$TARGET_THEME/mpv.conf" ]; then
          cat "$TARGET_THEME/mpv.conf" "$MPV_CONFIG_DIR/base.conf" > "$MPV_CONFIG_DIR/mpv.conf"
      else
          cp "$MPV_CONFIG_DIR/base.conf" "$MPV_CONFIG_DIR/mpv.conf"
      fi
  fi

  # Interface styling
  # Links GTK CSS overrides for consistent application appearance
  if [ -f "$TARGET_THEME/gtk.css" ]; then
      mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
      ln -sf "$CURRENT_LINK/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"
      ln -sf "$CURRENT_LINK/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
  fi

  # GSettings application
  # Updates system-wide GTK and Icon schemas via JSON metadata
  THEME_CONFIG="$TARGET_THEME/theme.json"
  if [ -f "$THEME_CONFIG" ]; then
    GTK_THEME=$(jq -r '.gtk // empty' "$THEME_CONFIG")
    ICON_THEME=$(jq -r '.icon // empty' "$THEME_CONFIG")
    [ -n "$GTK_THEME" ] && gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
    [ -n "$ICON_THEME" ] && gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
  fi

  # Process cleanup
  # Restarts file manager to apply theme changes
  pgrep thunar > /dev/null && pkill thunar

  # Environment finalization
  # Triggers the wallpaper manager
  if command -v prism-wall >/dev/null; then
    prism-wall random
  fi

  # Dashboard orchestration
  # Updates Quickshell modules and restarts the process
  if [ -f "$TARGET_THEME/Theme.qml" ]; then
      QS_THEME_DIR="$HOME/.config/quickshell/theme"
      mkdir -p "$QS_THEME_DIR"
      ln -sf "$CURRENT_LINK/Theme.qml" "$QS_THEME_DIR/Theme.qml"

      if pgrep quickshell > /dev/null; then
          pkill quickshell
          quickshell -p "$HOME/.config/quickshell" >/dev/null 2>&1 & disown
      fi
  fi

  # Success feedback
  notify-send "Prism Theme" "Switched to $cmd theme." -i preferences-desktop-theme
''
