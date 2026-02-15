{ pkgs, writeShellScriptBin }:

let
  deps = [ pkgs.lazygit ];
in
writeShellScriptBin "prism-git-tui" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Check if we are in a git repo
  if [ ! -d ".git" ] && ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
     notify-send "Prism Git" "Not a git repository." -u critical
     exit 1
  fi

  # Hand off to prism-tui to handle the Ghostty window + AppID
  exec prism-tui lazygit
''
