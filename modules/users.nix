{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.prism;
  defaultsPath = ../defaults;
in
{
  options.prism = {
    users = mkOption {
      description = "Map of personas to configure";
      default = { };
      type = types.attrsOf (
        types.submodule {
          options = {
            profileType = mkOption {
              type = types.enum [
                "dev"
                "gamer"
                "pentester"
                "custom"
              ];
              default = "custom";
              description = "Which core default set to apply";
            };

            extraFiles = mkOption {
              type = types.nullOr types.path;
              default = null;
              description = "Path to a local folder containing overrides (Applied over core defaults)";
            };

            packages = mkOption {
              type = types.listOf types.package;
              default = [ ];
              description = "Specific packages for this persona";
            };
          };
        }
      );
    };
  };

  config = {
    # Standard NixOS user creation
    users.users = mapAttrs (name: userCfg: {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "audio"
      ];
      shell = pkgs.zsh;
      packages = userCfg.packages;
      initialPassword = "prism";
    }) cfg.users;

    # 3-way merge script
    system.activationScripts.prismScaffold =
      let
        rsync = "${pkgs.rsync}/bin/rsync";

        script = concatStringsSep "\n" (
          mapAttrsToList (user: userCfg: ''
            echo "[Prism] Checking scaffolding for persona: ${user}..."

            USER_HOME="/home/${user}"
            COMMON_SOURCE="${defaultsPath}/common/"
            PROFILE_SOURCE="${defaultsPath}/${userCfg.profileType}/"
            USER_OVERRIDE="${toString userCfg.extraFiles}"
            THEME_SOURCE="${defaultsPath}/themes/"

            # Only proceed if user home exists
            if [ -d "$USER_HOME" ]; then
              
              # STRATEGY: Reverse Order (Specific -> General)
              # We apply overrides first so they "win" (occupy the slot)
              # preventing defaults from writing there.
              
              # Apply USER OVERRIDES (Highest priority)
              if [ -n "${toString userCfg.extraFiles}" ]; then
                if [ -d "$USER_OVERRIDE" ]; then
                   echo "[Prism] Applying user overrides for ${user}..."
                   ${rsync} -rav --ignore-existing --mkpath --chown=${user}:users "$USER_OVERRIDE/" "$USER_HOME/"
                else
                   echo "[Prism] Warning: User override path defined but missing: $USER_OVERRIDE"
                fi
              fi

              # Apply PROFILE defaults (Medium priority)
              if [ "${userCfg.profileType}" != "custom" ]; then
                if [ -d "$PROFILE_SOURCE" ]; then
                   ${rsync} -rav --ignore-existing --mkpath --chown=${user}:users "$PROFILE_SOURCE" "$USER_HOME/"
                else
                   echo "[Prism] Note: No profile defaults found for ${userCfg.profileType} (Skipping)"
                fi
              fi

              # Apply COMMON defaults (Lowest priority)
              if [ -d "$COMMON_SOURCE" ]; then
                ${rsync} -rav --ignore-existing --mkpath --chown=${user}:users "$COMMON_SOURCE" "$USER_HOME/"
              else
                echo "[Prism] Note: No common defaults found at $COMMON_SOURCE (Skipping)"
              fi

              # Apply THEMES & WALLPAPERS (System Data)
              # Destination: ~/.local/share/prism/themes
              # This ensures prism-theme/prism-wall have data to work with.
              THEME_DEST="$USER_HOME/.local/share/prism/themes"
              
              if [ -d "$THEME_SOURCE" ]; then
                 echo "[Prism] Deploying themes and wallpapers..."
                 ${rsync} -rav --ignore-existing --mkpath --chown=${user}:users "$THEME_SOURCE" "$THEME_DEST/"
              else
                 echo "[Prism] Warning: No themes found at $THEME_SOURCE"
              fi
            fi
          '') cfg.users
        );
      in
      stringAfter [ "users" ] script;
  };
}
