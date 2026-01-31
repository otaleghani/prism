# prism-remove uninstalls a packages from the current user
{
  pkgs,
  writeShellScriptBin,
}:
let
  # Dependency: jq for parsing JSON, fzf for UI
  deps = [
    pkgs.fzf
    pkgs.jq
    pkgs.gawk
  ];
in

writeShellScriptBin "prism-remove" ''
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

  # Get list
  # 'nix profile list' gives JSON. We parse it to "Index - Name"
  # We store the Index (required for removal) and Name for display
  LIST=$(nix profile list --json | jq -r '.elements | to_entries | .[] | "\(.key) \(.value.storePaths[0] | split("-")[1:])"')

  if [ -z "$LIST" ]; then
    echo "No imperative packages installed via Prism/Nix Profile."
    exit 0
  fi

  # Select
  # We return just the Index number (field 1)
  SELECTED_INDICES=$(echo "$LIST" | fzf "''${FZF_ARGS[@]}" | awk '{print $1}')

  if [ -n "$SELECTED_INDICES" ]; then
    # Convert newlines to spaces for the command
    INDICES_ARGS=$(echo "$SELECTED_INDICES" | tr '\n' ' ')
    
    echo "[Prism] Removing packages at indices: $INDICES_ARGS"
    nix profile remove $INDICES_ARGS
  fi
''
