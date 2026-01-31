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
          prism-theme = pkgs.callPackage ./pkgs/prism-theme.nix { };
          prism-open-tui = pkgs.callPackage ./pkgs/prism-open-tui.nix { };
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
            ./modules/users.nix
            ./modules/packages.nix
            ./modules/hardware/audio.nix
            ./modules/hardware/bluetooth.nix
            ./modules/hardware/boot.nix
            ./modules/hardware/garbage-collector.nix
            ./modules/hardware/graphics.nix
            ./modules/hardware/locale.nix
            ./modules/hardware/networking.nix
            ./modules/hardware/print.nix
            ./modules/hardware/settings.nix
            ./modules/software/fonts.nix
            ./modules/software/shared-folder.nix
            ./modules/software/shell.nix
            ./modules/software/steam.nix
            ./modules/software/wacom.nix
            ./modules/software/window-manager.nix
          ];

          # Inject our custom scripts package set
          nixpkgs.overlays = [
            (final: prev: {
              prism = {
                portal = self.packages.${prev.system}.prism-portal;
                sync = self.packages.${prev.system}.prism-sync;
                update = self.packages.${prev.system}.prism-update;
                install = self.packages.${prev.system}.prism-install;
                delete = self.packages.${prev.system}.prism-delete;
                theme = self.packages.${prev.system}.prism-theme;
                open-tui = self.packages.${prev.system}.prism-open-tui;
              };
            })
          ];
        };

      # TODO: Create development shell

    };
}
