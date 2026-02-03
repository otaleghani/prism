{
  pkgs,
  writeShellScriptBin,
}:
let
  deps = [
    pkgs.bluectl
  ];
in

writeShellScriptBin "prism-bluetooth" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  prism-tui bluetui
''
