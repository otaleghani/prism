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
  devPkgs = import ./packages/dev.nix { inherit pkgs; };
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
        };
      }
    );
    default = { };
    description = "User definitions for Prism.";
  };

  config = {
    # Install common packages system-wide
    environment.systemPackages = commonPkgs;

    # Install profile packages per-user
    # We now combine the Profile Packages + The User's Custom Packages
    users.users = lib.mapAttrs (name: userCfg: {
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
               ${rsync} -rav --mkpath --chown=${user}:users "$COMMON_SOURCE" "$USER_HOME/"
             fi

             # Apply PROFILE Defaults (Layer 2) - Enforced
             if [ "${userCfg.profileType}" != "custom" ] && [ -d "$PROFILE_SOURCE" ]; then
               ${rsync} -rav --mkpath --chown=${user}:users "$PROFILE_SOURCE" "$USER_HOME/"
             fi

             # Apply USER OVERRIDES (Top Layer) - Enforced
             if [ -n "${toString userCfg.extraFiles}" ] && [ -d "$USER_OVERRIDE" ]; then
               echo "[Prism] Applying user overrides..."
               ${rsync} -rav --mkpath --chown=${user}:users "$USER_OVERRIDE/" "$USER_HOME/"
             fi
             
             # Sync Themes & Wallpapers
             THEME_DEST="$USER_HOME/.local/share/prism/themes"
             if [ -d "$THEME_SOURCE" ]; then
                ${rsync} -rav --mkpath --chown=${user}:users "$THEME_SOURCE" "$THEME_DEST/"
                
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
             fi
          fi
        '') cfg
      )
    );
  };
}
