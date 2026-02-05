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
          python3
          python3Packages.pip
          python3Packages.virtualenv
        ];
        shellHook = ''
          echo "Welcome to {{PROJECT_NAME}} (Python)"
          if [ -z "$TMUX" ]; then
            exec tmux new-session -A -s {{PROJECT_NAME}}
          fi
        '';
      };
    };
}
