{ pkgs }:

with pkgs;
[
  # Base utils
  ffmpeg
  git
  wget
  curl
  rsync
  rclone
  unzip
  fastfetch
  fzf
  ripgrep
  fd # find alternative
  bat # cal alternative
  eza # ls alternative
  starship
  mpv # Video viewer
  feh # Image viewer
  grim # Screenshots
  slurp # Screen selection for screenshots
  satty # Screenshots editing
  yazi # Terminal file manager

  # Window
  wl-clipboard
  hyprpicker # Color picker
  walker # Application runner

  # Terminal
  ghostty # Emulator
  neovim # Editor
  wiremix # Volume
  impala # Wifi
  bluetui # Bluetooth
  nload # Traffic monitor?

  # Nix
  nil

  # Browser
  chromium

  # Prism
  prism.portal
  prism.sync
  prism.update
  prism.install
  prism.delete
  prism.theme
  prism.open-tui
]
