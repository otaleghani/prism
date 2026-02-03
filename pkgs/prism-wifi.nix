{
  pkgs,
  writeShellScriptBin,
}:
let
  deps = [
    pkgs.impala
  ];
in

writeShellScriptBin "prism-wifi" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  prism-tui impala
''
