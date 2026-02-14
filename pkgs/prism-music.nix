{ writeShellScriptBin }:

writeShellScriptBin "prism-music" ''
  # Usage: prism-music <service>
  # Supported: spotify, youtube-music, apple-music, soundcloud, deezer

  SERVICE="$1"

  if [ -z "$SERVICE" ]; then
    echo "Usage: prism-music <service>"
    echo "Supported services: spotify, youtube-music, apple-music, soundcloud, deezer"
    exit 1
  fi

  case "$SERVICE" in
    "spotify")
      # Pattern matches "Spotify - Web Player" or just "Spotify"
      exec prism-focus-webapp "Spotify" "https://open.spotify.com"
      ;;
    "youtube-music")
      # Pattern matches "YouTube Music"
      exec prism-focus-webapp "YouTube Music" "https://music.youtube.com"
      ;;
    "apple-music")
      # Pattern matches "Apple Music"
      exec prism-focus-webapp "Apple Music" "https://music.apple.com"
      ;;
    "soundcloud")
      # Pattern matches "SoundCloud"
      exec prism-focus-webapp "SoundCloud" "https://soundcloud.com"
      ;;
    "deezer")
      # Pattern matches "Deezer"
      exec prism-focus-webapp "Deezer" "https://www.deezer.com"
      ;;
    *)
      echo "Error: Unknown service '$SERVICE'"
      echo "Supported: spotify, youtube-music, apple-music, soundcloud, deezer"
      exit 1
      ;;
  esac
''
