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
    silentSDDM.url = "github:uiriansan/SilentSDDM";
    silentSDDM.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      silentSDDM,
      ...
    }@inputs:
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
          # prism-portal = pkgs.callPackage ./pkgs/prism-portal.nix { };
          prism-sync = pkgs.callPackage ./pkgs/prism-sync.nix { };
          prism-update = pkgs.callPackage ./pkgs/prism-update.nix { };
          prism-install = pkgs.callPackage ./pkgs/prism-install.nix { };
          prism-delete = pkgs.callPackage ./pkgs/prism-delete.nix { };
          prism-theme = pkgs.callPackage ./pkgs/prism-theme.nix { };
          prism-wall = pkgs.callPackage ./pkgs/prism-wall.nix { };
          prism-open-tui = pkgs.callPackage ./pkgs/prism-open-tui.nix { };
          prism-open-or-focus = pkgs.callPackage ./pkgs/prism-open-or-focus.nix { };
          prism-open-or-focus-tui = pkgs.callPackage ./pkgs/prism-open-or-focus-tui.nix { };
          prism-open-webapp = pkgs.callPackage ./pkgs/prism-open-webapp.nix { };
          prism-open-or-focus-webapp = pkgs.callPackage ./pkgs/prism-open-or-focus-webapp.nix { };
          prism-session = pkgs.callPackage ./pkgs/prism-session.nix { };
          prism-screenshot = pkgs.callPackage ./pkgs/prism-screenshot.nix { };
          prism-screenrecord = pkgs.callPackage ./pkgs/prism-screenrecord.nix { };
          prism-save = pkgs.callPackage ./pkgs/prism-save.nix { };
          prism-monitor = pkgs.callPackage ./pkgs/prism-monitor.nix { };
          prism-apps = pkgs.callPackage ./pkgs/prism-apps.nix { };
          prism-bluetooth = pkgs.callPackage ./pkgs/prism-bluetooth.nix { };
          prism-wifi = pkgs.callPackage ./pkgs/prism-wifi.nix { };
          prism-music = pkgs.callPackage ./pkgs/prism-music.nix { };
          prism-chat = pkgs.callPackage ./pkgs/prism-chat.nix { };
          prism-ai = pkgs.callPackage ./pkgs/prism-ai.nix { };
          prism-settings = pkgs.callPackage ./pkgs/prism-settings.nix { };
          prism-clipboard = pkgs.callPackage ./pkgs/prism-clipboard.nix { };
          prism-installer = pkgs.callPackage ./pkgs/prism-installer.nix { };
          prism-timezone = pkgs.callPackage ./pkgs/prism-timezone.nix { };
          prism-keyboard = pkgs.callPackage ./pkgs/prism-keyboard.nix { };
          prism-keybinds = pkgs.callPackage ./pkgs/prism-keybinds.nix { };
          prism-power = pkgs.callPackage ./pkgs/prism-power.nix { };
          prism-users = pkgs.callPackage ./pkgs/prism-users.nix { };
          prism-project = pkgs.callPackage ./pkgs/prism-project.nix { };
          prism-workspaces = pkgs.callPackage ./pkgs/prism-workspaces.nix { };
          prism-active-window = pkgs.callPackage ./pkgs/prism-active-window.nix { };
          prism-audio-status = pkgs.callPackage ./pkgs/prism-audio-status.nix { };
          prism-net-status = pkgs.callPackage ./pkgs/prism-net-status.nix { };
          prism-notif-status = pkgs.callPackage ./pkgs/prism-notif-status.nix { };
          prism-notifications = pkgs.callPackage ./pkgs/prism-notifications.nix { };
          prism-audio-mixer = pkgs.callPackage ./pkgs/prism-audio-mixer.nix { };
          prism-brightness = pkgs.callPackage ./pkgs/prism-brightness.nix { };
          prism-wallpaper-list = pkgs.callPackage ./pkgs/prism-wallpaper-list.nix { };
          prism-themes-list = pkgs.callPackage ./pkgs/prism-themes-list.nix { };
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
            silentSDDM.nixosModules.default
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
            ./modules/hardware/input.nix
            ./modules/hardware/power.nix
            ./modules/software/fonts.nix
            ./modules/software/shared-folder.nix
            ./modules/software/shell.nix
            ./modules/software/steam.nix
            ./modules/software/wacom.nix
            ./modules/software/window-manager.nix
            ./modules/software/login.nix
          ];

          # Inject our custom scripts package set
          nixpkgs.overlays = [
            (final: prev: {
              prism = {
                # portal = self.packages.${prev.system}.prism-portal;
                sync = self.packages.${prev.system}.prism-sync;
                update = self.packages.${prev.system}.prism-update;
                install = self.packages.${prev.system}.prism-install;
                delete = self.packages.${prev.system}.prism-delete;
                theme = self.packages.${prev.system}.prism-theme;
                wall = self.packages.${prev.system}.prism-wall;
                focus = self.packages.${prev.system}.prism-open-or-focus;
                open-tui = self.packages.${prev.system}.prism-open-tui;
                focus-tui = self.packages.${prev.system}.prism-open-or-focus-tui;
                open-webapp = self.packages.${prev.system}.prism-open-webapp;
                focus-webapp = self.packages.${prev.system}.prism-open-or-focus-webapp;
                session = self.packages.${prev.system}.prism-session;
                screenshot = self.packages.${prev.system}.prism-screenshot;
                screenrecord = self.packages.${prev.system}.prism-screenrecord;
                save = self.packages.${prev.system}.prism-save;
                monitor = self.packages.${prev.system}.prism-monitor;
                apps = self.packages.${prev.system}.prism-apps;
                bluetooth = self.packages.${prev.system}.prism-bluetooth;
                wifi = self.packages.${prev.system}.prism-wifi;
                music = self.packages.${prev.system}.prism-music;
                chat = self.packages.${prev.system}.prism-chat;
                ai = self.packages.${prev.system}.prism-ai;
                settings = self.packages.${prev.system}.prism-settings;
                clipboard = self.packages.${prev.system}.prism-clipboard;
                installer = self.packages.${prev.system}.prism-installer;
                timezone = self.packages.${prev.system}.prism-timezone;
                keyboard = self.packages.${prev.system}.prism-keyboard;
                keybinds = self.packages.${prev.system}.prism-keybinds;
                power = self.packages.${prev.system}.prism-power;
                users = self.packages.${prev.system}.prism-users;
                project = self.packages.${prev.system}.prism-project;
                workspaces = self.packages.${prev.system}.prism-workspaces;
                active-window = self.packages.${prev.system}.prism-active-window;
                audio-status = self.packages.${prev.system}.prism-audio-status;
                net-status = self.packages.${prev.system}.prism-net-status;
                notif-status = self.packages.${prev.system}.prism-notif-status;
                notifications = self.packages.${prev.system}.prism-notifications;
                audio-mixer = self.packages.${prev.system}.prism-audio-mixer;
                brightness = self.packages.${prev.system}.prism-brightness;
                wallpaper-list = self.packages.${prev.system}.prism-wallpaper-list;
                themes-list = self.packages.${prev.system}.prism-themes-list;
              };
            })
          ];
        };

      nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./modules/iso.nix
        ];
      };

      # TODO: Create development shell
    };
}
