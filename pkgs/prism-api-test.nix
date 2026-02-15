{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.gum
    pkgs.curlie
    pkgs.jq
    pkgs.libnotify
    pkgs.coreutils
  ];
in
writeShellScriptBin "prism-api-test" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Terminal auto-launch
  if [ ! -t 0 ]; then
    if command -v prism-tui >/dev/null; then
        exec prism-tui "$0" "$@"
    else
        notify-send "Prism API" "Terminal wrapper not found." -u critical
        exit 1
    fi
  fi

  # Header display
  clear
  gum style --border double --margin "1 2" --padding "1 2" --foreground 4 "Prism API Tester"

  # Input collection
  METHOD=$(gum choose "GET" "POST" "PUT" "DELETE" "PATCH")
  URL=$(gum input --placeholder "https://api.example.com/v1/..." --header "Endpoint URL")

  if [ -z "$URL" ]; then
    notify-send "Prism API" "Request cancelled: No URL provided."
    exit 0
  fi

  # Body collection
  if [ "$METHOD" != "GET" ]; then
    BODY=$(gum write --placeholder "Enter JSON Body (Ctrl+D to finish)" --header "Request Body")
  fi

  # Execution logic
  clear
  echo "Sending $METHOD request to $URL..."

  if [ -n "$BODY" ]; then
    RESPONSE=$(echo "$BODY" | curlie -s "$METHOD" "$URL" 2>&1)
  else
    RESPONSE=$(curlie -s "$METHOD" "$URL" 2>&1)
  fi

  # Results display
  echo "-------------------------------------------"
  echo "$RESPONSE"
  echo "-------------------------------------------"

  # Exit handling
  if [ $? -eq 0 ]; then
    notify-send "Prism API" "Request to $URL completed successfully." -i network-transmit
  else
    notify-send "Prism API" "Request failed. Check the terminal for error details." -u critical
  fi

  echo ""
  gum style --foreground 4 "Press any key to close this session..."
  read -n 1 -s
''
