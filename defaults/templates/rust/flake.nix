{
  description = "{{PROJECT_NAME}} development environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };
  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
    }:
    let
      system = "x86_64-linux";
      overlays = [ (import rust-overlay) ];
      pkgs = import nixpkgs { inherit system overlays; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          (rust-bin.stable.latest.default.override {
            extensions = [
              "rust-src"
              "rust-analyzer"
            ];
          })
          pkg-config
          openssl
        ];
        shellHook = ''
          echo "Welcome to {{PROJECT_NAME}} (Rust)"
          if [ -z "$TMUX" ]; then
            exec tmux new-session -A -s {{PROJECT_NAME}}
          fi
        '';
      };
    };
}
