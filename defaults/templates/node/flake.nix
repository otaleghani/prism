{
  description = "{{PROJECT_NAME}} development environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nodejs_22
          yarn
        ];
        shellHook = ''
          echo "Welcome to {{PROJECT_NAME}} (Node.js)"
          if [ -z "$TMUX" ]; then
            exec tmux new-session -A -s {{PROJECT_NAME}}
          fi
        '';
      };
    };
}
