{ pkgs }:

with pkgs;
[
  # Utils
  lazygit
  lazydocker
  opencode
  claude-code
  gh

  tree-sitter # Needed for nvim

  python3
  nodejs_20
  gcc
  gnumake

  prism.project
  prism.api-test
  prism.git-tui

  # Things from gamer that I still use
  mangohud
  protonup-qt
  gamescope
]
