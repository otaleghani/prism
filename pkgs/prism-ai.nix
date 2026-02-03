{ writeShellScriptBin }:

# This script acts as a central launcher for AI services.
# It relies on 'prism-focus-webapp' being installed in the system/user path.

writeShellScriptBin "prism-ai" ''
  # Usage: prism-ai <service>
  # Supported: chatgpt, claude, gemini, deepseek, perplexity

  SERVICE="$1"

  if [ -z "$SERVICE" ]; then
    echo "Usage: prism-ai <service>"
    echo "Supported services: chatgpt, claude, gemini, deepseek, perplexity"
    exit 1
  fi

  case "$SERVICE" in
    "chatgpt")
      exec prism-focus-webapp "ChatGPT" "https://chatgpt.com"
      ;;
    "claude")
      exec prism-focus-webapp "Claude" "https://claude.ai"
      ;;
    "gemini")
      exec prism-focus-webapp "Gemini" "https://gemini.google.com"
      ;;
    "deepseek")
      exec prism-focus-webapp "DeepSeek" "https://chat.deepseek.com"
      ;;
    "perplexity")
      exec prism-focus-webapp "Perplexity" "https://www.perplexity.ai"
      ;;
    *)
      echo "Error: Unknown service '$SERVICE'"
      echo "Supported: chatgpt, claude, gemini, deepseek, perplexity"
      exit 1
      ;;
  esac
''
