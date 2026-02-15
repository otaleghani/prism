{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.libnotify
    pkgs.coreutils
  ];
in
writeShellScriptBin "prism-chat" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Input validation
  SERVICE="$1"

  if [ -z "$SERVICE" ]; then
    notify-send "Prism Chat" "Usage: prism-chat <service>\n(whatsapp, telegram, discord, slack, messenger)" -u low
    exit 1
  fi

  # Service mapping
  case "$SERVICE" in
    "whatsapp")
      NAME="WhatsApp" ; URL="https://web.whatsapp.com"
      ;;
    "telegram")
      NAME="Telegram" ; URL="https://web.telegram.org/k/"
      ;;
    "discord")
      NAME="Discord" ; URL="https://discord.com/app"
      ;;
    "slack")
      NAME="Slack" ; URL="https://app.slack.com/client"
      ;;
    "messenger")
      NAME="Messenger" ; URL="https://www.messenger.com"
      ;;
    *)
      # Notify user of invalid service
      notify-send "Prism Chat" "Error: '$SERVICE' is not a recognized chat service." -u critical
      exit 1
      ;;
  esac

  # Focus execution
  # Switches to the existing workspace or launches a new instance
  prism-focus-webapp "$NAME" "$URL" || {
    notify-send "Prism Chat" "Failed to launch $NAME. Ensure the web engine is responsive." -u critical
    exit 1
  }
''
