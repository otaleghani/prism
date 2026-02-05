{ pkgs }:

with pkgs;
[
  # Base utils
  tmux
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
  # mpv # Video viewer
  (mpv.override {
    scripts = [
      mpvScripts.uosc
      mpvScripts.thumbfast
    ];
  })
  feh # Image viewer
  grim # Screenshots
  slurp # Screen selection for screenshots
  satty # Screenshots editing
  yazi # Terminal file manager
  findutils # find
  coreutils # sort, head, etc.

  # Window
  waybar
  wl-clipboard
  hyprpicker # Color picker
  cliphist
  hyprcursor
  papirus-icon-theme
  rose-pine-icon-theme
  rose-pine-hyprcursor # Cursor
  walker # Application runner
  rofi # Application runner
  swww # Wallpaper engine
  hyprpolkitagent # Needed for prism-portal
  swaynotificationcenter # Notification manager
  libnotify
  brightnessctl
  playerctl

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
  # prism.portal
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
  prism.session
  prism.screenshot
  prism.screenrecord
  prism.save
  prism.monitor
  prism.apps
  prism.bluetooth
  prism.wifi
  prism.music
  prism.chat
  prism.ai
  prism.settings
  prism.clipboard
  prism.timezone
  prism.keyboard
  prism.keybinds
  prism.power
  prism.users
  prism.project
]
