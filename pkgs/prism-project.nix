{
  pkgs,
  writeShellScriptBin,
  symlinkJoin,
}:

let
  deps = [
    pkgs.fzf
    pkgs.git
    pkgs.coreutils
    pkgs.findutils
    pkgs.libnotify
    pkgs.gum
  ];

  # PROJECT OPEN
  # Terminal-based portal to enter project development shells
  projectOpen = writeShellScriptBin "prism-project-open" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH
    WORKSPACE_DIR="$HOME/Workspace"

    # Terminal auto-launch
    # Ensures the script runs inside a Prism-themed Ghostty window
    if [ ! -t 0 ]; then
      if command -v prism-tui >/dev/null; then
          exec prism-tui "$0" "$@"
      else
          notify-send "Prism Projects" "Error: prism-tui not found." -u critical
          exit 1
      fi
    fi

    # Data collection
    # Finds projects and sorts them by last access time
    [ ! -d "$WORKSPACE_DIR" ] && {
        notify-send "Prism Projects" "Workspace directory missing." -u critical
        exit 1
    }

    PROJECT_LIST=$(find "$WORKSPACE_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%T@ %f\n" 2>/dev/null | sort -rn | cut -d' ' -f2-)

    [ -z "$PROJECT_LIST" ] && {
        notify-send "Prism Projects" "No projects found in Workspace."
        exit 0
    }

    # Selection interface
    # Fast fzf filtering with a live directory preview
    SELECTED=$(echo "$PROJECT_LIST" | fzf \
      --prompt="Open Project> " \
      --height=100% \
      --layout=reverse \
      --border \
      --header="Select project to enter dev shell" \
      --preview "ls -Ap $WORKSPACE_DIR/{}")

    [ -z "$SELECTED" ] && exit 0

    TARGET_PATH="$WORKSPACE_DIR/$SELECTED"

    # Environment transition
    # Changes directory and replaces the current process with nix develop
    cd "$TARGET_PATH" || {
        echo "Error: Could not enter directory $TARGET_PATH"
        notify-send "Prism Projects" "Failed to enter project directory." -u critical
        read -n 1 -s -p "Press any key to exit..."
        exit 1
    }

    notify-send "Prism Projects" "Environment $SELECTED active." -i terminal

    # Replaces the script with the nix-shell process
    exec nix develop || {
        echo "Error: 'nix develop' failed. Is the flake.nix valid and tracked by git?"
        notify-send "Prism Projects" "Nix develop failed to start." -u critical
        read -n 1 -s -p "Press any key to exit..."
        exit 1
    }
  '';

  # PROJECT NEW (Updated with your requirements)
  projectNew = writeShellScriptBin "prism-project-new" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH
    WORKSPACE_DIR="$HOME/Workspace"
    TEMPLATE_DIR="$HOME/.local/share/prism/templates"

    if [ ! -t 0 ]; then
      exec prism-tui "$0" "$@"
    fi

    # Header display
    clear
    gum style --border double --margin "1 2" --padding "1 2" --foreground 4 "Prism Project Creator"

    # Input collection
    PROJECT_NAME=$(gum input --placeholder "Project Name" --header "Name your project")
    [ -z "$PROJECT_NAME" ] && exit 0

    TARGET_DIR="$WORKSPACE_DIR/$PROJECT_NAME"
    [ -d "$TARGET_DIR" ] && { 
        notify-send "Prism Projects" "Error: Directory already exists." -u critical
        exit 1 
    }

    # Template discovery
    LANGS=$(find "$TEMPLATE_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)
    LANG=$(echo "$LANGS" | gum choose --header "Select Environment Template")
    [ -z "$LANG" ] && exit 0

    # Scaffolding logic
    mkdir -p "$TARGET_DIR"
    cp "$TEMPLATE_DIR/$LANG/flake.nix" "$TARGET_DIR/flake.nix"
    sed -i "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$TARGET_DIR/flake.nix"

    # Git integration
    # Files must be tracked for Nix Flakes to recognize them
    if gum confirm "Initialize Git Repository?"; then
        cd "$TARGET_DIR"
        git init -q
        git add flake.nix
        echo ".direnv/" >> .gitignore
        echo "result" >> .gitignore
        git add .gitignore
        git add .
    fi

    # Success feedback
    notify-send "Prism Projects" "Project '$PROJECT_NAME' created and tracked." -i folder-new

    echo "Opening editor..."
    ''${EDITOR:-nvim} "$TARGET_DIR/flake.nix"
  '';

in
symlinkJoin {
  name = "prism-project-suite";
  paths = [
    projectNew
    projectOpen
  ];
}
