{ pkgs, inputs }:

with pkgs;
[
  # Utils
  lazygit
  lazydocker
  opencode
  claude-code
  inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
  gh
  # nodejs_25

  tree-sitter # Needed for nvim

  python3
  # nodejs_20
  gcc
  gnumake

  prism.project
  prism.api-test
  prism.git-tui

  # Things from gamer that I still use
  mangohud
  protonup-qt
  gamescope

  fuse3
]
