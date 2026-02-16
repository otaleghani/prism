{
  pkgs,
  writeShellScriptBin,
  symlinkJoin,
}:

let
  deps = [
    pkgs.gum
    pkgs.fzf
    pkgs.git
    pkgs.coreutils
    pkgs.findutils
    pkgs.gnused
    pkgs.libnotify
  ];

  # PROJECT NEW
  # Interactive wizard to scaffold new Nix-based development environments
  projectNew = writeShellScriptBin "prism-project-new" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH
    WORKSPACE_DIR="$HOME/Workspace"
    TEMPLATE_DIR="$HOME/.local/share/prism/templates"

    # Terminal auto-launch
    if [ ! -t 0 ]; then
      prism-tui "$0" "$@" || exit 1
    fi

    # Header display
    clear
    gum style --border double --margin "1 2" --padding "1 2" --foreground 4 "Prism Project Creator"

    # Directory validation
    mkdir -p "$WORKSPACE_DIR"

    # Input collection
    PROJECT_NAME=$(gum input --placeholder "Project Name (e.g. aurora-api)" --header "Name your project")
    [ -z "$PROJECT_NAME" ] && exit 0

    TARGET_DIR="$WORKSPACE_DIR/$PROJECT_NAME"
    [ -d "$TARGET_DIR" ] && { 
        notify-send "Prism Projects" "Error: Directory already exists." -u critical
        exit 1 
    }

    # Template discovery
    [ ! -d "$TEMPLATE_DIR" ] && {
       notify-send "Prism Projects" "Templates not found at $TEMPLATE_DIR" -u critical
       exit 1
    }

    LANGS=$(find "$TEMPLATE_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)
    LANG=$(echo "$LANGS" | gum choose --header "Select Environment Template")
    [ -z "$LANG" ] && exit 0

    # Scaffolding logic
    # Populates the directory and injects project-specific metadata
    mkdir -p "$TARGET_DIR"
    TEMPLATE_FILE="$TEMPLATE_DIR/$LANG/flake.nix"

    if [ -f "$TEMPLATE_FILE" ]; then
        cp "$TEMPLATE_FILE" "$TARGET_DIR/flake.nix"
        sed -i "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$TARGET_DIR/flake.nix"
    else
        notify-send "Prism Projects" "Template file missing for $LANG." -u critical
        exit 1
    fi

    # Git integration
    # Crucial: Nix flakes require files to be tracked by git to be visible
    if gum confirm "Initialize Git Repository?"; then
        cd "$TARGET_DIR"
        git init -q
        git add flake.nix
        echo ".direnv/" >> .gitignore
        echo "result" >> .gitignore
        git add .gitignore
        echo "Git initialized and flake.nix tracked."
    fi

    # Finalization
    notify-send "Prism Projects" "Project '$PROJECT_NAME' created in Workspace." -i folder-new

    echo ""
    gum style --foreground 4 "Project Created! Opening editor..."
    ''${EDITOR:-nvim} "$TARGET_DIR/flake.nix"
  '';

  # PROJECT OPEN
  # High-speed launcher to enter development shells
  projectOpen = writeShellScriptBin "prism-project-open" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH
    WORKSPACE_DIR="$HOME/Workspace"

    # Terminal auto-launch
    if [ ! -t 0 ]; then
      exec prism-tui "$0" "$@"
    fi

    # Data collection
    # Finds projects and grabs the last modified time for better context
    [ ! -d "$WORKSPACE_DIR" ] && {
        notify-send "Prism Projects" "Workspace folder not found." -u critical
        exit 1
    }

    PROJECT_LIST=$(find "$WORKSPACE_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%T@ %f\n" | sort -rn | cut -d' ' -f2-)

    [ -z "$PROJECT_LIST" ] && {
        notify-send "Prism Projects" "No projects found in Workspace."
        exit 0
    }

    # Selection interface
    # Uses fzf for fast searching with a directory preview
    SELECTED=$(echo "$PROJECT_LIST" | fzf \
      --prompt="Open Project> " \
      --height=60% \
      --layout=reverse \
      --border \
      --header="Select a project to enter development shell" \
      --preview "ls -Ap $WORKSPACE_DIR/{}")

    [ -z "$SELECTED" ] && exit 0

    FULL_PATH="$WORKSPACE_DIR/$SELECTED"

    # Execution logic
    # Launches a new terminal, changes directory, and enters nix shell
    notify-send "Prism Projects" "Entering $SELECTED development environment..." -i terminal

    # We use ghostty -e to run a shell that stays open in the correct DIR
    if command -v ghostty >/dev/null; then
        setsid ghostty --working-directory="$FULL_PATH" -e bash -c "nix develop || bash" >/dev/null 2>&1 &
    else
        notify-send "Prism Projects" "Ghostty terminal not found." -u critical
        exit 1
    fi
  '';

in
symlinkJoin {
  name = "prism-project-suite";
  paths = [
    projectNew
    projectOpen
  ];
}
