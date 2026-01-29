{
  pkgs,
  writeShellScriptBin,
  symlinkJoin,
}:

let
  # Dependency: jq for parsing JSON, fzf for UI
  deps = [
    pkgs.fzf
    pkgs.jq
    pkgs.gawk
  ];

  # --- 1. THE SYNC TOOL ---
  # Generates a local cache of packages: "attributeName | Description"
  prismSync = writeShellScriptBin "prism-sync" ''
    CACHE_DIR="$HOME/.cache/prism"
    mkdir -p "$CACHE_DIR"

    echo "[Prism] Indexing Nixpkgs (this takes ~10-20 seconds)..."

    # We use nix-env -qa because it's reliable for fetching available packages
    # Format: package.attr.path  Description
    ${pkgs.nix}/bin/nix-env -qaP --description > "$CACHE_DIR/pkglist.txt"

    echo "[Prism] Database updated. $(wc -l < $CACHE_DIR/pkglist.txt) packages indexed."
  '';

  # --- 2. THE INSTALL TOOL ---
  prismInstall = writeShellScriptBin "prism-install" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH
    CACHE_FILE="$HOME/.cache/prism/pkglist.txt"

    # Check for DB
    if [ ! -f "$CACHE_FILE" ]; then
      echo "Package database not found. Running prism-sync..."
      ${prismSync}/bin/prism-sync
    fi

    # FZF Args
    FZF_ARGS=(
      --prompt="Install> "
      --layout=reverse
      --height=80%
      --border
      --preview "echo {2..}" # Show description in preview
      --preview-window="top:3:wrap"
      --with-nth=1 # Only search the package name
      --color='hl:148,hl+:154,pointer:032,marker:010,bg+:237,gutter:237'
    )

    # 1. Select
    # awk filters standard output to just the attribute path
    SELECTED=$(cat "$CACHE_FILE" | fzf "''${FZF_ARGS[@]}" | awk '{print $1}')

    if [ -n "$SELECTED" ]; then
      echo "[Prism] Installing $SELECTED..."
      
      # We use 'nix profile' for imperative, fast user installs
      nix profile install "nixpkgs#$SELECTED"
      
      echo "Done! Run 'prism-remove' to uninstall."
    fi
  '';

  # --- 3. THE REMOVE TOOL ---
  prismRemove = writeShellScriptBin "prism-remove" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH

    # FZF Args
    FZF_ARGS=(
      --prompt="Remove> "
      --layout=reverse
      --height=50%
      --border
      --header="Select packages to remove (TAB to multi-select)"
      --multi
      --color='prompt:196,hl:196,pointer:196'
    )

    # 1. Get List
    # 'nix profile list' gives JSON. We parse it to "Index - Name"
    # We store the Index (required for removal) and Name for display
    LIST=$(nix profile list --json | jq -r '.elements | to_entries | .[] | "\(.key) \(.value.storePaths[0] | split("-")[1:])"')

    if [ -z "$LIST" ]; then
      echo "No imperative packages installed via Prism/Nix Profile."
      exit 0
    fi

    # 2. Select
    # We return just the Index number (field 1)
    SELECTED_INDICES=$(echo "$LIST" | fzf "''${FZF_ARGS[@]}" | awk '{print $1}')

    if [ -n "$SELECTED_INDICES" ]; then
      # Convert newlines to spaces for the command
      INDICES_ARGS=$(echo "$SELECTED_INDICES" | tr '\n' ' ')
      
      echo "[Prism] Removing packages at indices: $INDICES_ARGS"
      nix profile remove $INDICES_ARGS
    fi
  '';

in
symlinkJoin {
  name = "prism-pkg-manager";
  paths = [
    prismSync
    prismInstall
    prismRemove
  ];
}
