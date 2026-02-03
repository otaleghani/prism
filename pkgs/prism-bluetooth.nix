{
  pkgs,
  writeShellScriptBin,
}:
let
  deps = [
    pkgs.bluetui
  ];
in

writeShellScriptBin "prism-bluetooth" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  prism-tui bluetui
''
