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

  # Paths (Relative to this file)
  defaultsPath = ../defaults;
  overridesPath = ../overrides;

  # Check if overrides exist in the source tree to avoid errors
  hasOverrides = builtins.pathExists overridesPath;

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
          icon = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "Path to the user's profile picture.";
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
          # Removed 'extraFiles' option as it is now handled automatically via /overrides/USERNAME
          packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [ ];
            description = "Specific extra packages for this persona (merged with profile packages).";
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
    users.users = lib.mapAttrs (name: userCfg: {
      isNormalUser = userCfg.isNormalUser;
      description = userCfg.description;
      extraGroups = userCfg.extraGroups;
      shell = pkgs.zsh;
      initialPassword = userCfg.initialPassword;
      packages = (profilePackages.${userCfg.profileType} or [ ]) ++ userCfg.packages;
    }) cfg;

    # SCAFFOLDING SCRIPT
    system.activationScripts.prismScaffolding = lib.stringAfter [ "users" ] (
      concatStringsSep "\n" (
        mapAttrsToList (user: userCfg: ''
          echo "[Prism] Enforcing configuration state for user: ${user}..."

          USER_HOME="/home/${user}"
          COMMON_SOURCE="${defaultsPath}/common/"
          PROFILE_SOURCE="${defaultsPath}/${userCfg.profileType}/"
          THEME_SOURCE="${defaultsPath}/themes/"

          if [ -d "$USER_HOME" ]; then
             
             # --- Permissions Pre-Flight ---
             mkdir -p "$USER_HOME/.config" "$USER_HOME/.local/share"
             chown -R ${user}:users "$USER_HOME/.config" "$USER_HOME/.local"
             chmod -R u+rwX "$USER_HOME/.config" "$USER_HOME/.local"

             # Apply COMMON Defaults (Enforced)
             if [ -d "$COMMON_SOURCE" ]; then
               ${rsync} -rav --mkpath --chmod=u+rwX --chown=${user}:users "$COMMON_SOURCE" "$USER_HOME/"
             fi

             # Apply PROFILE Defaults (Enforced)
             if [ "${userCfg.profileType}" != "custom" ] && [ -d "$PROFILE_SOURCE" ]; then
               ${rsync} -rav --mkpath --chmod=u+rwX --chown=${user}:users "$PROFILE_SOURCE" "$USER_HOME/"
             fi

             # Apply USER OVERRIDES (Enforced)
             # Automatically looks in ../overrides/<username>
             ${
               if hasOverrides then
                 ''
                   USER_OVERRIDE="${overridesPath}/${user}"
                   if [ -d "$USER_OVERRIDE" ]; then
                       echo "[Prism] Applying user overrides from repo/overrides/${user}..."
                       ${rsync} -rav --mkpath --chmod=u+rwX --chown=${user}:users "$USER_OVERRIDE/" "$USER_HOME/"
                   fi
                 ''
               else
                 ""
             }
             
             # Sync Themes
             THEME_DEST="$USER_HOME/.local/share/prism/themes"
             if [ -d "$THEME_SOURCE" ]; then
                mkdir -p "$USER_HOME/.local/share/prism"
                chown ${user}:users "$USER_HOME/.local/share/prism"
                
                ${rsync} -rav --mkpath --chmod=u+rwX --chown=${user}:users "$THEME_SOURCE" "$THEME_DEST/"
                
                CURRENT_LINK="$USER_HOME/.local/share/prism/current"
                DEFAULT_THEME="catppuccin-mocha"
                
                if [ ! -e "$CURRENT_LINK" ]; then
                   if [ -d "$THEME_DEST/$DEFAULT_THEME" ]; then
                       ln -sfn "$THEME_DEST/$DEFAULT_THEME" "$CURRENT_LINK"
                       chown -h ${user}:users "$CURRENT_LINK"
                   fi
                fi
             fi

             # Fix Nvim Permissions
             if [ -d "$USER_HOME/.local/share/nvim" ]; then
                 chown -R ${user}:users "$USER_HOME/.local/share/nvim"
                 chmod -R u+rwX "$USER_HOME/.local/share/nvim"
             fi
          fi
        '') cfg
      )
    );
  };
}
