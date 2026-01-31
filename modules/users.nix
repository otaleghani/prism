{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.prism.users;

  # 1. Import the package lists
  commonPkgs = import ./packages/common.nix { inherit pkgs; };
  devPkgs = import ./packages/dev.nix { inherit pkgs; };
  gamerPkgs = import ./packages/gamer.nix { inherit pkgs; };
  pentesterPkgs = import ./packages/pentester.nix { inherit pkgs; };
  creatorPkgs = import ./packages/creator.nix { inherit pkgs; };

  # 2. Map profile strings to package lists
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
    users.users = lib.mapAttrs (name: userCfg: {
      packages = (profilePackages.${userCfg.profileType} or [ ]);
    }) cfg;

    # SCAFFOLDING SCRIPT
    # Strategy: Enforced Updates (General -> Specific)
    # 1. Common (Overwrite)
    # 2. Profile (Overwrite)
    # 3. User Overrides (Overwrite)
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
             
             # Apply COMMON Defaults (Base Layer)
             if [ -d "$COMMON_SOURCE" ]; then
               ${rsync} -rav --mkpath --chown=${user}:users "$COMMON_SOURCE" "$USER_HOME/"
             fi

             # Apply PROFILE Defaults (Layer 2)
             # Overwrites common defaults if conflicts exist.
             if [ "${userCfg.profileType}" != "custom" ] && [ -d "$PROFILE_SOURCE" ]; then
               ${rsync} -rav --mkpath --chown=${user}:users "$PROFILE_SOURCE" "$USER_HOME/"
             fi

             # Apply USER OVERRIDES (Top Layer)
             # This allows the user to persistently override Prism defaults 
             # by defining the files in their flake 'extraFiles' path.
             if [ -n "${toString userCfg.extraFiles}" ] && [ -d "$USER_OVERRIDE" ]; then
               echo "[Prism] Applying user overrides..."
               ${rsync} -rav --mkpath --chown=${user}:users "$USER_OVERRIDE/" "$USER_HOME/"
             fi
             
             # Sync themes & wallpapers
             # Always sync to ensure new themes are available.
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
