{ pkgs, writeShellScriptBin }:

writeShellScriptBin "prism-sync" ''
  export PATH=${
    pkgs.lib.makeBinPath [
      pkgs.nix
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.libnotify
    ]
  }:$PATH

  CACHE_DIR="$HOME/.cache/prism"
  mkdir -p "$CACHE_DIR"

  # Process initiation
  echo "Indexing Nixpkgs database (this may take a few moments)..."

  # Data collection
  # Queries available packages and formats them as 'AttributePath Description'
  # Filters out NixOS modules to prevent attribute set errors
  nix-env -f '<nixpkgs>' -qaP --description | grep -vE "^nixos\." > "$CACHE_DIR/pkglist.txt" || {
    notify-send "Prism Store" "Database synchronization failed." -u critical
    exit 1
  }

  # Result calculation
  PKG_COUNT=$(wc -l < "$CACHE_DIR/pkglist.txt")

  # Finalization
  echo "  [Success] -> Database updated with $PKG_COUNT packages."
  notify-send "Prism Store" "Package index updated ($PKG_COUNT entries)." -i system-software-update
''
