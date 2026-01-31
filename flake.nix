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
          prism-portal = pkgs.callPackage ./pkgs/prism-portal.nix { };
          prism-sync = pkgs.callPackage ./pkgs/prism-sync.nix { };
          prism-update = pkgs.callPackage ./pkgs/prism-update.nix { };
          prism-install = pkgs.callPackage ./pkgs/prism-install.nix { };
          prism-delete = pkgs.callPackage ./pkgs/prism-delete.nix { };
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
            ./modules/profiles.nix
          ];

          # Inject our custom scripts package set
          nixpkgs.overlays = [
            (final: prev: {
              prism = {
                portal = self.packages.${prev.system}.prism-portal;
                sync = self.packages.${prev.sync}.prism-sync;
                update = self.packages.${prev.system}.prism-update;
                install = self.packages.${prev.system}.prism-install;
                delete = self.packages.${prev.system}.prism-delete;
              };
            })
          ];
        };

      # TODO: Create development shell

    };
}
