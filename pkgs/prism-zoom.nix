{ pkgs, writeShellScriptBin }:

let
  deps = with pkgs; [
    hyprland
    slurp
    jq
    gawk
  ];
in
writeShellScriptBin "prism-zoom" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  current="$(hyprctl getoption cursor:zoom_factor -j | jq -r '.float')"

  if awk -v z="$current" 'BEGIN { exit !(z > 1.001) }'; then
    hyprctl -q keyword cursor:zoom_factor 1
    exit 0
  fi

  read -r x y w h < <(slurp -f '%x %y %w %h') || exit 0
  (( w > 0 && h > 0 )) || exit 0

  cx=$((x + w / 2))
  cy=$((y + h / 2))

  read -r mw mh < <(
    hyprctl monitors -j |
      jq -r --argjson x "$cx" --argjson y "$cy" '
        first(
          .[] |
          select(
            $x >= .x and $x < (.x + .width / .scale) and
            $y >= .y and $y < (.y + .height / .scale)
          ) |
          [(.width / .scale), (.height / .scale)]
        ) | @tsv'
  ) || exit 1

  factor="$(awk -v mw="$mw" -v mh="$mh" -v w="$w" -v h="$h" '
    BEGIN {
      z = mw / w
      if (mh / h < z) z = mh / h
      if (z < 1.25) z = 1.25
      if (z > 2.0) z = 2.0
      printf "%.3f", z
    }')"

  hyprctl --batch \
    "dispatch movecursor $cx $cy ; keyword cursor:zoom_factor $factor" \
    >/dev/null
''
