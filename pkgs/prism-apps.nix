{
  pkgs,
  writeShellScriptBin,
}:
let
  deps = [
    pkgs.rofi
  ];
in

writeShellScriptBin "prism-apps" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH
  rofi -show drun
''
