# prism-remove installs a package for the current user
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

writeShellScriptBin "prism-install" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH
  CACHE_FILE="$HOME/.cache/prism/pkglist.txt"

  # Check for DB
  if [ ! -f "$CACHE_FILE" ]; then
    echo "Package database not found. Running prism-sync..."
    prism-sync
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

  # awk filters standard output to just the attribute path
  SELECTED=$(cat "$CACHE_FILE" | fzf "''${FZF_ARGS[@]}" | awk '{print $1}')

  if [ -n "$SELECTED" ]; then
    echo "[Prism] Installing $SELECTED..."
    
    # We use 'nix profile' for imperative, fast user installs
    nix profile install "nixpkgs#$SELECTED"
    
    echo "Done! Run 'prism-remove' to uninstall."
  fi
''
