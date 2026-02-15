{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.gum
    pkgs.curlie
    pkgs.jq
  ];
in
writeShellScriptBin "prism-api-test" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  METHOD=$(gum choose "GET" "POST" "PUT" "DELETE" "PATCH")
  URL=$(gum input --placeholder "https://api.example.com/v1/..." --header "Endpoint URL")

  if [ "$METHOD" != "GET" ]; then
    BODY=$(gum write --placeholder "Enter JSON Body (Ctrl+D to finish)" --header "Request Body")
  fi

  clear
  echo "[Prism] Sending $METHOD to $URL..."

  if [ -n "$BODY" ]; then
    echo "$BODY" | curlie "$METHOD" "$URL"
  else
    curlie "$METHOD" "$URL"
  fi

  # Keep window open to see results
  read -n 1 -s -r -p "Press any key to close..."
''
