# prism-sync fetches the available packages from the nix repository
{
  pkgs,
  writeShellScriptBin,
}:

writeShellScriptBin "prism-sync" ''
  CACHE_DIR="$HOME/.cache/prism"
  mkdir -p "$CACHE_DIR"

  echo "[Prism] Indexing Nixpkgs (this takes ~10-20 seconds)..."

  # We use nix-env -qa because it's reliable for fetching available packages
  # Format: package.attr.path  Description
  # Filter out 'nixos.' attributes (modules/functions) which cause "not an attribute set" errors
  ${pkgs.nix}/bin/nix-env -f ${pkgs.path} -qaP --description | grep -vE "^nixos\." > "$CACHE_DIR/pkglist.txt"

  echo "[Prism] Database updated. $(wc -l < $CACHE_DIR/pkglist.txt) packages indexed."
''
