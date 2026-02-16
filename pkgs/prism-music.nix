{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.libnotify
    pkgs.coreutils
  ];
in
writeShellScriptBin "prism-music" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Input validation
  SERVICE="$1"

  if [ -z "$SERVICE" ]; then
    notify-send "Prism Music" "Usage: prism-music <service>\n(spotify, youtube-music, apple-music, soundcloud, deezer)" -u low
    exit 1
  fi

  # Service mapping
  case "$SERVICE" in
    "spotify")
      NAME="Spotify" ; URL="https://open.spotify.com"
      ;;
    "youtube-music")
      NAME="YouTube Music" ; URL="https://music.youtube.com"
      ;;
    "apple-music")
      NAME="Apple Music" ; URL="https://music.apple.com"
      ;;
    "soundcloud")
      NAME="SoundCloud" ; URL="https://soundcloud.com"
      ;;
    "deezer")
      NAME="Deezer" ; URL="https://www.deezer.com"
      ;;
    *)
      # Notify user of invalid service
      notify-send "Prism Music" "Error: '$SERVICE' is not a supported music service." -u critical
      exit 1
      ;;
  esac

  # Focus execution
  # Switches to the existing workspace or launches the music web engine
  prism-focus-webapp "$NAME" "$URL" || {
    notify-send "Prism Music" "Failed to launch $NAME. Ensure the web engine is responsive." -u critical
    exit 1
  }
''
