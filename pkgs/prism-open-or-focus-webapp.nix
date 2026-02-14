{ writeShellScriptBin }:

writeShellScriptBin "prism-focus-webapp" ''
  # Usage: prism-focus-webapp <window-pattern> <url>
  # 
  # Web apps set their own window title based on the site (e.g. "YouTube").
  # We need to know what to search for (Pattern) and what to launch (URL) if missing.
  #
  # Example: prism-focus-webapp "Spotify" "https://open.spotify.com"
  # Example: prism-focus-webapp "ChatGPT" "https://chatgpt.com"

  if [ -z "$2" ]; then
    echo "Usage: prism-focus-webapp <window-pattern> <url>"
    exit 1
  fi

  PATTERN="$1"
  URL="$2"

  # Hand off to prism-focus
  # Arg 1: The Pattern to search for (e.g., "Spotify")
  # Arg 2: The Command to run if not found
  # We wrap the URL in quotes to handle special characters safely
  exec prism-focus "$PATTERN" "prism-webapp \"$URL\""
''
