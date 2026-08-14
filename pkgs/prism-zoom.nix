{ pkgs, writeShellScriptBin }:

let
  deps = with pkgs; [
    hyprland
    jq
  ];
in
writeShellScriptBin "prism-zoom" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  case "''${1:-}" in
    --reset)
      factor=1
      ;;
    --in|--out)
      factor="$(
        hyprctl getoption cursor:zoom_factor -j |
          jq -r --arg action "$1" '
            .float * (if $action == "--in" then 1.15 else 1 / 1.15 end)
            | if . < 1 then 1 elif . > 3 then 3 else . end
          '
      )"
      ;;
    *)
      echo "Usage: prism-zoom [--in|--out|--reset]" >&2
      exit 2
      ;;
  esac

  hyprctl -q keyword cursor:zoom_factor "$factor"
''
