{
  pkgs,
  writeShellScriptBin,
  symlinkJoin,
}:

let
  deps = [
    pkgs.gum
    pkgs.rofi
    pkgs.git
    pkgs.coreutils
    pkgs.findutils
    pkgs.gnused
  ];

  # PROJECT NEW
  projectNew = writeShellScriptBin "prism-project-new" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH

    WORKSPACE_DIR="$HOME/Workspace"
    TEMPLATE_DIR="$HOME/.local/share/prism/templates"

    # WIZARD 
    clear
    gum style \
      --border double --margin "1 2" --padding "2 4" --align center \
      --foreground 212 "PRISM PROJECT CREATOR"

    if [ ! -d "$WORKSPACE_DIR" ]; then
        echo "Creating Workspace directory at $WORKSPACE_DIR"
        mkdir -p "$WORKSPACE_DIR"
    fi

    # Project name
    PROJECT_NAME=$(gum input --placeholder "Project Name (e.g. my-app)" --header "Name your project")
    [ -z "$PROJECT_NAME" ] && exit 1

    TARGET_DIR="$WORKSPACE_DIR/$PROJECT_NAME"
    if [ -d "$TARGET_DIR" ]; then
        gum style --foreground 196 "Error: Directory already exists!"
        exit 1
    fi

    # Language (Scan templates directory)
    if [ ! -d "$TEMPLATE_DIR" ]; then
       echo "Error: Templates not found at $TEMPLATE_DIR"
       echo "Run 'prism-update' to install default templates."
       exit 1
    fi

    # List subdirectories in templates/
    LANGS=$(find "$TEMPLATE_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)

    LANG=$(echo "$LANGS" | gum choose --header "Select Template")
    [ -z "$LANG" ] && exit 1

    # Create and populate
    mkdir -p "$TARGET_DIR"
    echo "Generating flake.nix for $LANG..."

    TEMPLATE_FILE="$TEMPLATE_DIR/$LANG/flake.nix"

    if [ -f "$TEMPLATE_FILE" ]; then
        cp "$TEMPLATE_FILE" "$TARGET_DIR/flake.nix"
        
        # Replace {{PROJECT_NAME}} with actual name
        sed -i "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$TARGET_DIR/flake.nix"
    else
        echo "Error: Template file not found: $TEMPLATE_FILE"
        exit 1
    fi

    # Git init
    if gum confirm "Initialize Git Repository?"; then
        git init "$TARGET_DIR"
        git add $TARGET_DIR/flake.nix
        echo ".direnv/" >> "$TARGET_DIR/.gitignore"
        echo "result" >> "$TARGET_DIR/.gitignore"
    fi

    # Open editor
    gum style --foreground 212 "Opening editor..."
    $EDITOR "$TARGET_DIR/flake.nix"

    gum style --foreground 212 "Project Created!"
    echo "To enter: cd $TARGET_DIR && nix develop"
  '';

  # PROJECT OPEN (Launcher
  projectOpen = writeShellScriptBin "prism-project-open" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH
    WORKSPACE_DIR="$HOME/Workspace"

    if [ ! -d "$WORKSPACE_DIR" ]; then
        notify-send "Prism Projects" "No Workspace folder found." -u critical
        exit 1
    fi

    # List projects
    PROJECTS=$(find "$WORKSPACE_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n")

    if [ -z "$PROJECTS" ]; then
        notify-send "Prism Projects" "No projects found."
        exit 0
    fi

    # Select project
    SELECTED=$(echo "$PROJECTS" | rofi -dmenu -p "Open Project")
    [ -z "$SELECTED" ] && exit 0

    FULL_PATH="$WORKSPACE_DIR/$SELECTED"

    # Launch terminal
    CMD="nix develop \"$FULL_PATH\""

    if command -v ghostty >/dev/null; then
        setsid ghostty -e bash -c "$CMD" >/dev/null 2>&1 &
    elif command -v kitty >/dev/null; then
        setsid kitty -e bash -c "$CMD" >/dev/null 2>&1 &
    else
        notify-send "Prism Projects" "No supported terminal found." -u critical
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
