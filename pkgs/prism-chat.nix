{ writeShellScriptBin }:

writeShellScriptBin "prism-chat" ''
  # Usage: prism-chat <service>
  # Supported: whatsapp, telegram, discord, slack, messenger

  SERVICE="$1"

  if [ -z "$SERVICE" ]; then
    echo "Usage: prism-chat <service>"
    echo "Supported services: whatsapp, telegram, discord, slack, messenger"
    exit 1
  fi

  case "$SERVICE" in
    "whatsapp")
      exec prism-focus-webapp "WhatsApp" "https://web.whatsapp.com"
      ;;
    "telegram")
      exec prism-focus-webapp "Telegram" "https://web.telegram.org/k/"
      ;;
    "discord")
      exec prism-focus-webapp "Discord" "https://discord.com/app"
      ;;
    "slack")
      exec prism-focus-webapp "Slack" "https://app.slack.com/client"
      ;;
    "messenger")
      exec prism-focus-webapp "Messenger" "https://www.messenger.com"
      ;;
    *)
      echo "Error: Unknown service '$SERVICE'"
      echo "Supported: whatsapp, telegram, discord, slack, messenger"
      exit 1
      ;;
  esac
''
