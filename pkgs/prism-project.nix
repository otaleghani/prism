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

  projectNew = writeShellScriptBin "prism-project-new" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH
    WORKSPACE_DIR="$HOME/Workspace"
    TEMPLATE_DIR="$HOME/.local/share/prism/templates"

    # Terminal auto-launch
    if [ ! -t 0 ]; then
      exec prism-tui "$0" "$@"
    fi

    # Header display
    clear
    gum style --border double --margin "1 2" --padding "1 2" --foreground 4 "Prism Project Creator"

    # Directory validation
    mkdir -p "$WORKSPACE_DIR"

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
    if gum confirm "Initialize Git Repository?"; then
        cd "$TARGET_DIR"
        git init -q
        git add flake.nix
        echo ".direnv/" >> .gitignore
        echo "result" >> .gitignore
        git add .gitignore
    fi

    # Success feedback
    notify-send "Prism Projects" "Project '$PROJECT_NAME' created successfully." -i folder-new

    echo "Opening editor..."
    ''${EDITOR:-nvim} "$TARGET_DIR/flake.nix"
  '';

  projectOpen = writeShellScriptBin "prism-project-open" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH
    WORKSPACE_DIR="$HOME/Workspace"

    # Data collection
    # Sorts projects by most recently modified
    PROJECT_LIST=$(find "$WORKSPACE_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%T@ %f\n" 2>/dev/null | sort -rn | cut -d' ' -f2-)

    [ -z "$PROJECT_LIST" ] && {
        notify-send "Prism Projects" "No projects found."
        exit 0
    }

    # Selection interface
    SELECTED=$(echo "$PROJECT_LIST" | fzf \
      --prompt="Open Project> " \
      --height=60% \
      --layout=reverse \
      --border \
      --header="Select a project to enter development shell" \
      --preview "ls -Ap $WORKSPACE_DIR/{}")

    [ -z "$SELECTED" ] && exit 0

    # Output the path for the shell function to pick up
    echo "$WORKSPACE_DIR/$SELECTED"
  '';

in
symlinkJoin {
  name = "prism-project-suite";
  paths = [
    projectNew
    projectOpen
  ];
}
