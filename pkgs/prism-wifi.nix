{
  pkgs,
  writeShellScriptBin,
}:
let
  deps = [
    pkgs.bluectl
  ];
in

writeShellScriptBin "prism-wifi" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  prism-tui impala
''
