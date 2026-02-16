{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.jq
    pkgs.findutils
    pkgs.coreutils
  ];
in
writeShellScriptBin "prism-wallpaper-list" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  THEME_DIR="$HOME/.local/share/prism/current/wall"
  CUSTOM_DIR="$HOME/.local/share/prism/wallpapers"

  # Find all images (dereference symlinks with -L)
  # Look in both theme and custom folders
  FILES=$(find -L "$THEME_DIR" "$CUSTOM_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) 2>/dev/null | sort -u)

  if [ -z "$FILES" ]; then
      echo "[]"
      exit 0
  fi

  # Convert list to JSON objects {path, name}
  # Chunk into sub-arrays of 3 for the grid layout
  echo "$FILES" | jq -R -s -c '
  split("\n") 
  | map(select(length > 0)) 
  | map({
      path: ., 
      name: (split("/") | last)
    })
  '
''
