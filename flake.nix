{

  #                 ''
  # '||''|, '||''|  ||  ('''' '||),,(|,
  #  ||  ||  ||     ||   `'')  || || ||
  #  ||..|' .||.   .||. `...' .||    ||.
  #  ||
  # .||

  description = "otaleghani/prism";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      # Add custom packages
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          portal = pkgs.callPackage ./pkgs/portal.nix { };
          pkg-manager = pkgs.callPackage ./pkgs/package-manager.nix { };
        }
      );

      # Core module
      nixosModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          imports = [
            ./modules/user-logic.nix
            ./modules/system.nix
          ];

          # Inject our custom scripts package set
          nixpkgs.overlays = [
            (final: prev: {
              prism = {
                portal = self.packages.${prev.system}.portal;
                # ADDED: Overlay
                pkg-manager = self.packages.${prev.system}.pkg-manager;
              };
            })
          ];
        };
    };
}
