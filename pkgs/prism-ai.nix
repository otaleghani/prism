{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.libnotify
    pkgs.coreutils
  ];
in
writeShellScriptBin "prism-ai" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Input validation
  SERVICE="$1"

  if [ -z "$SERVICE" ]; then
    notify-send "Prism AI" "Usage: prism-ai <service>\n(chatgpt, claude, gemini, deepseek, perplexity)" -u low
    exit 1
  fi

  # Service mapping
  case "$SERVICE" in
    "chatgpt")
      NAME="ChatGPT" ; URL="https://chatgpt.com"
      ;;
    "claude")
      NAME="Claude" ; URL="https://claude.ai"
      ;;
    "gemini")
      NAME="Gemini" ; URL="https://gemini.google.com"
      ;;
    "deepseek")
      NAME="DeepSeek" ; URL="https://chat.deepseek.com"
      ;;
    "perplexity")
      NAME="Perplexity" ; URL="https://www.perplexity.ai"
      ;;
    *)
      # Notify user of invalid service
      notify-send "Prism AI" "Error: '$SERVICE' is not a recognized AI service." -u critical
      exit 1
      ;;
  esac

  # Focus execution
  # Following prism-focus-webapp logic for single-instance management
  prism-focus-webapp "$NAME" "$URL" || {
    notify-send "Prism AI" "Failed to launch $NAME. Ensure the web engine is responsive." -u critical
    exit 1
  }
''
