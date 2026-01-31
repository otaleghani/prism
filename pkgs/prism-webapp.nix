{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.util-linux # for setsid
  ];
in
writeShellScriptBin "prism-webapp" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  URL="$1"

  if [ -z "$URL" ]; then
    echo "Usage: prism-webapp <URL>"
    exit 1
  fi

  # Check if chromium exists in the user's path
  if ! command -v chromium >/dev/null; then
    echo "Error: 'chromium' not found."
    echo "Prism webapps strictly require Chromium to be installed."
    exit 1
  fi

  echo "[Prism] Launching webapp: $URL"

  # Launch detached from terminal
  setsid chromium --app="$URL" >/dev/null 2>&1 &
''
