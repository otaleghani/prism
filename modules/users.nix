{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.prism.users;

  # 1. Import the package lists
  commonPkgs = import ./packages/common.nix { inherit pkgs; };
  devPkgs = import ./packages/developer.nix { inherit pkgs; };
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

  # Paths
  # FIX: Use inputs.self to reliably find the flake root
  flakeRoot = inputs.self;
  defaultsPath = flakeRoot + /defaults;
  overridesPath = flakeRoot + /overrides;

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
          TEMPLATE_SOURCE="${defaultsPath}/templates/"

          if [ -d "$USER_HOME" ]; then
             
             # --- Permissions Pre-Flight ---
             mkdir -p "$USER_HOME/.config" "$USER_HOME/.local/share"
             chown -R ${user}:users "$USER_HOME/.config" "$USER_HOME/.local"
             chmod -R u+rwX "$USER_HOME/.config" "$USER_HOME/.local"

             # 1. Apply COMMON Defaults (Enforced - Steamroll)
             # Defaults will overwrite local changes to enforce state.
             if [ -d "$COMMON_SOURCE" ]; then
               echo "  -> Applying Common Defaults..."
               ${rsync} -rav --mkpath --chmod=u+rwX --chown=${user}:users "$COMMON_SOURCE" "$USER_HOME/"
             else
               echo "  -> [INFO] No Common Defaults found."
             fi

             # 2. Apply PROFILE Defaults (Enforced - Steamroll)
             if [ "${userCfg.profileType}" != "custom" ] && [ -d "$PROFILE_SOURCE" ]; then
               echo "  -> Applying Profile Defaults (${userCfg.profileType})..."
               ${rsync} -rav --mkpath --chmod=u+rwX --chown=${user}:users "$PROFILE_SOURCE" "$USER_HOME/"
             fi

             # 4. Sync Themes (Data)
             THEME_DEST="$USER_HOME/.local/share/prism/themes"
             if [ -d "$THEME_SOURCE" ]; then
                mkdir -p "$USER_HOME/.local/share/prism"
                chown ${user}:users "$USER_HOME/.local/share/prism"
                
                echo "  -> Syncing Themes..."
                ${rsync} -rav --mkpath --chmod=u+rwX --chown=${user}:users "$THEME_SOURCE" "$THEME_DEST/"
                
                # Set Default Theme
                CURRENT_LINK="$USER_HOME/.local/share/prism/current"
                DEFAULT_THEME="catppuccin-mocha"
                
                if [ ! -e "$CURRENT_LINK" ]; then
                   if [ -d "$THEME_DEST/$DEFAULT_THEME" ]; then
                       echo "     -> Setting default theme: $DEFAULT_THEME"
                       ln -sfn "$THEME_DEST/$DEFAULT_THEME" "$CURRENT_LINK"
                       chown -h ${user}:users "$CURRENT_LINK"
                   fi
                fi
             fi
             
             # 5. Sync Project Templates
             TEMPLATE_DEST="$USER_HOME/.local/share/prism/templates"
             if [ -d "$TEMPLATE_SOURCE" ]; then
                echo "  -> Syncing Project Templates..."
                mkdir -p "$TEMPLATE_DEST"
                chown ${user}:users "$TEMPLATE_DEST"
                ${rsync} -rav --mkpath --chmod=u+rwX --chown=${user}:users "$TEMPLATE_SOURCE" "$TEMPLATE_DEST/"
             fi

             # 6. Fix Nvim Permissions
             if [ -d "$USER_HOME/.local/share/nvim" ]; then
                 chown -R ${user}:users "$USER_HOME/.local/share/nvim"
                 chmod -R u+rwX "$USER_HOME/.local/share/nvim"
             fi

             # 3. Apply USER OVERRIDES (Enforced)
             # Automatically looks in ../overrides/<username>
             ${
               if hasOverrides then
                 ''
                   USER_OVERRIDE="${overridesPath}/${user}"

                   if [ -d "$USER_OVERRIDE" ]; then
                       echo "  -> Applying User Overrides from repo/overrides/${user}..."
                       ${rsync} -rav --mkpath --chmod=u+rwX --exclude 'themes' --exclude 'wallpapers' --chown=${user}:users "$USER_OVERRIDE/" "$USER_HOME/"
                       
                       # Sub-overrides for themes
                       if [ -d "$USER_OVERRIDE/themes" ]; then
                           echo "     -> Applying custom themes..."
                           ${rsync} -rav --mkpath --chmod=u+rwX --chown=${user}:users "$USER_OVERRIDE/themes/" "$USER_HOME/.local/share/prism/themes/"
                       fi
                       # Sub-overrides for wallpapers
                       if [ -d "$USER_OVERRIDE/wallpapers" ]; then
                           echo "     -> Applying custom wallpapers..."
                           ${rsync} -rav --mkpath --chmod=u+rwX --chown=${user}:users "$USER_OVERRIDE/wallpapers/" "$USER_HOME/.local/share/prism/wallpapers/"
                       fi
                   else
                       echo "  -> [INFO] No overrides found for user ${user} in overrides/"
                   fi
                 ''
               else
                 ''
                   echo "  -> [INFO] Overrides directory does not exist in the flake source (git add overrides/ ?)"
                 ''
             }
             
          fi
        '') cfg
      )
    );
  };
}
