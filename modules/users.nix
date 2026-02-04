{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.prism.users;

  # Import the package lists
  commonPkgs = import ./packages/common.nix { inherit pkgs; };
  devPkgs = import ./packages/developer.nix { inherit pkgs; };
  gamerPkgs = import ./packages/gamer.nix { inherit pkgs; };
  pentesterPkgs = import ./packages/pentester.nix { inherit pkgs; };
  creatorPkgs = import ./packages/creator.nix { inherit pkgs; };

  # Map profile strings to package lists
  profilePackages = {
    dev = devPkgs;
    gamer = gamerPkgs;
    pentester = pentesterPkgs;
    creator = creatorPkgs;
    custom = [ ];
  };

  # Path to defaults directory (relative to this file)
  defaultsPath = ../defaults;
  rsync = "${pkgs.rsync}/bin/rsync";

  concatStringsSep = lib.strings.concatStringsSep;
  mapAttrsToList = lib.attrsets.mapAttrsToList;
in
{
  options.prism.users = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          description = lib.mkOption {
            type = lib.types.str;
            default = "Prism User";
            description = "Full name of the user (e.g., Oliviero Taleghani).";
          };
          profileType = lib.mkOption {
            type = lib.types.enum [
              "dev"
              "gamer"
              "pentester"
              "creator"
              "custom"
            ];
            default = "custom";
            description = "The persona profile for this user.";
          };
          extraFiles = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "Path to a directory of extra dotfiles to override defaults.";
          };
          packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [ ];
            description = "Specific extra packages for this persona (merged with profile packages).";
          };
          icon = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "Path to the user's profile picture.";
          };
          isNormalUser = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether this is a normal user account (default true).";
          };
          initialPassword = lib.mkOption {
            type = lib.types.str;
            default = "prism";
            description = "Initial password for the user.";
          };
          extraGroups = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [
              "wheel"
              "networkmanager"
              "video"
              "audio"
            ];
            description = "Extra groups for the user.";
          };
        };
      }
    );
    default = { };
    description = "User definitions for Prism.";
  };

  config = {
    # Install Common Packages System-Wide
    environment.systemPackages = commonPkgs;

    # Install Profile Packages Per-User
    # We now combine the Profile Packages + The User's Custom Packages
    users.users = lib.mapAttrs (name: userCfg: {
      isNormalUser = true;
      description = userCfg.description;
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "audio"
        # "vboxusers" # Only add if VirtualBox is enabled system-wide to avoid errors
      ];
      shell = pkgs.zsh;
      initialPassword = "prism"; # Default password (change immediately!)
      packages = (profilePackages.${userCfg.profileType} or [ ]) ++ userCfg.packages;
    }) cfg;

    # SCAFFOLDING SCRIPT
    # Strategy: Enforced Updates (Common -> Profile -> Override)
    system.activationScripts.prismScaffolding = lib.stringAfter [ "users" ] (
      concatStringsSep "\n" (
        mapAttrsToList (user: userCfg: ''
          echo "[Prism] Enforcing configuration state for user: ${user}..."

          USER_HOME="/home/${user}"
          COMMON_SOURCE="${defaultsPath}/common/"
          PROFILE_SOURCE="${defaultsPath}/${userCfg.profileType}/"
          USER_OVERRIDE="${toString userCfg.extraFiles}"
          THEME_SOURCE="${defaultsPath}/themes/"

          if [ -d "$USER_HOME" ]; then
            # Apply COMMON Defaults (Base Layer) - Enforced
            if [ -d "$COMMON_SOURCE" ]; then
              ${rsync} -rav --mkpath --chmod=u+rwX --chown=${user}:users "$COMMON_SOURCE" "$USER_HOME/"
            fi

            # Apply PROFILE Defaults (Layer 2) - Enforced
            if [ "${userCfg.profileType}" != "custom" ] && [ -d "$PROFILE_SOURCE" ]; then
              ${rsync} -rav --mkpath --chmod=u+rwX --chown=${user}:users "$PROFILE_SOURCE" "$USER_HOME/"
            fi

            # Apply USER OVERRIDES (Top Layer) - Enforced
            if [ -n "${toString userCfg.extraFiles}" ] && [ -d "$USER_OVERRIDE" ]; then
              echo "[Prism] Applying user overrides..."
              ${rsync} -rav --mkpath --chmod=u+rwX --chown=${user}:users "$USER_OVERRIDE/" "$USER_HOME/"
            fi
            
            # Sync Themes & Wallpapers
            THEME_DEST="$USER_HOME/.local/share/prism/themes"
            if [ -d "$THEME_SOURCE" ]; then
              ${rsync} -rav --mkpath --chmod=u+rwX --chown=${user}:users "$THEME_SOURCE" "$THEME_DEST/"
              
              # Set Default Theme (Catppuccin Mocha) if no current theme is selected
              CURRENT_LINK="$USER_HOME/.local/share/prism/current"
              DEFAULT_THEME="catppuccin-mocha"

              
              if [ ! -e "$CURRENT_LINK" ]; then
                 if [ -d "$THEME_DEST/$DEFAULT_THEME" ]; then
                     echo "[Prism] Setting default theme to $DEFAULT_THEME..."
                     ln -sfn "$THEME_DEST/$DEFAULT_THEME" "$CURRENT_LINK"
                     chown -h ${user}:users "$CURRENT_LINK"
                 fi
              fi

              # Configure all programs that do not directly take the styles from the current theme
              # Add symlink for yazi config
              if [ -f "$DEFAULT_THEME/yazi.toml" ]; then
                mkdir -p "$USER_HOME/.config/yazi"
                ln -sf "$CURRENT_LINK/yazi.toml" "$USER_HOME/.config/yazi/theme.toml"
              fi

              # Generate MPV config
              # Combines the Theme Colors with the Base Settings
              MPV_CONFIG_DIR="$HOME/.config/mpv"
              if [ -d "$MPV_CONFIG_DIR" ] && [ -f "$MPV_CONFIG_DIR/base.conf" ]; then
                  echo "Generating MPV Config..."
                  if [ -f "$CURRENT_LINK/mpv.conf" ]; then
                      cat "$CURRENT_LINK/mpv.conf" "$MPV_CONFIG_DIR/base.conf" > "$MPV_CONFIG_DIR/mpv.conf"
                  else
                      # Fallback if theme has no mpv config
                      cp "$MPV_CONFIG_DIR/base.conf" "$MPV_CONFIG_DIR/mpv.conf"
                  fi
              fi
            fi
          fi
        '') cfg
      )
    );
  };
}
