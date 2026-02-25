{ pkgs }:

with pkgs;
[
  # Utils
  lazygit
  lazydocker
  opencode
  claude-code

  python3
  nodejs_20
  gcc
  gnumake

  prism.project
  prism.api-test
  prism.git-tui
]
