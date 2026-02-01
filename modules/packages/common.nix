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
  findutils # find
  coreutils # sort, head, etc.

  # Window
  wl-clipboard
  hyprpicker # Color picker
  walker # Application runner
  swww # Wallpaper engine

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
  prism.wall
  prism.focus
  prism.open-tui
  prism.focus-tui
  prism.open-webapp
  prism.focus-webapp
]
