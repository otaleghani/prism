{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.fzf
    pkgs.jq
    pkgs.gawk
    pkgs.glib # contains gsettings
    pkgs.coreutils
  ];

in
writeShellScriptBin "prism-theme" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # --- CONFIGURATION ---
  # These are defined here (in Bash) because $HOME is determined at runtime.
  # We use $VAR (no braces) so Nix doesn't try to interpolate them.
  BASE_DIR="$HOME/.local/share/prism"
  THEMES_DIR="$BASE_DIR/themes"
  CURRENT_LINK="$BASE_DIR/current"

  cmd="$1"

  # Helper: List available themes
  list_themes() {
    ls -1 "$THEMES_DIR"
  }

  # Mode 1: Interactive Selection (if no argument passed)
  if [ -z "$cmd" ]; then
    echo "[Prism] Select a theme:"
    SELECTED=$(list_themes | fzf --prompt="Theme> " --height=40% --layout=reverse --border)
    if [ -z "$SELECTED" ]; then exit 0; fi
    cmd="$SELECTED"
  fi

  TARGET_THEME="$THEMES_DIR/$cmd"

  # Validation
  if [ ! -d "$TARGET_THEME" ]; then
    echo "Error: Theme '$cmd' not found in $THEMES_DIR"
    exit 1
  fi

  echo "[Prism] Switching to theme: $cmd"

  # Update Symlink
  ln -sfn "$TARGET_THEME" "$CURRENT_LINK"

  # Reload Hyprland
  if pgrep Hyprland > /dev/null; then
    echo "Reloading Hyprland..."
    hyprctl reload
  fi

  # Reload waybar
  if pgrep waybar > /dev/null; then
    echo "Reloading Waybar..."
    pkill waybar
    waybar & disown
  fi

  # KITTY REMOVED, using ghostty
  # if pgrep kitty > /dev/null; then
  #   echo "Reloading Kitty..."
  #   kill -SIGUSR1 $(pidof kitty)
  # fi

  # WALKER REMOVED, using rofi
  # if pgrep walker > /dev/null; then
  #   echo "Reloading Walker..."
  #   pkill walker
  #   # waybar --deamon & disown # Preloading walker not necessary
  # fi
  # Walker Paths 
  # WALKER_CONFIG_DIR="$HOME/.config/walker/themes"
  # # GENERATE WALKER CSS (Dynamic Import Strategy)
  # # We construct a valid style.css by writing an absolute @import line (using file://)
  # # followed by the base structural CSS. This avoids relative path issues in Walker.
  # if [ -d "$WALKER_CONFIG_DIR" ]; then
  #     echo "Generating Walker CSS..."
  #
  #     # Write the absolute path import: @import url("file:///home/user/.../walker.css");
  #     echo "@import url(\"file://$TARGET_THEME/walker.css\");" > "$WALKER_CONFIG_DIR/prism.css"
  #
  #     # Append the structure styles
  #     cat "$WALKER_CONFIG_DIR/base.css" >> "$WALKER_CONFIG_DIR/prism.css"
  #
  #     # Restart Walker to load new config
  #     if pgrep walker > /dev/null; then
  #       pkill walker
  #     fi
  # fi

  # Apply GTK Theme (if theme.json exists)
  THEME_CONFIG="$TARGET_THEME/theme.json"
  if [ -f "$THEME_CONFIG" ]; then
    GTK_THEME=$(jq -r '.gtk // empty' "$THEME_CONFIG")
    ICON_THEME=$(jq -r '.icon // empty' "$THEME_CONFIG")

    if [ -n "$GTK_THEME" ]; then
      echo "Setting GTK Theme: $GTK_THEME"
      gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
    fi
    
    if [ -n "$ICON_THEME" ]; then
      echo "Setting Icon Theme: $ICON_THEME"
      gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
    fi
  fi

  # Reset Wallpaper
  # Calls the separate prism-wall command (which is in the PATH via style-manager)
  if command -v prism-wall >/dev/null; then
    prism-wall random
  else
    echo "Warning: prism-wall not found, skipping wallpaper update."
  fi
''
