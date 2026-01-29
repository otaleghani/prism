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

            # Only proceed if user home exists
            if [ -d "$USER_HOME" ]; then
              
              # Apply COMMON defaults (Shells, Theme Settings)
              # --ignore-existing: Do NOT overwrite if user has edited the file on disk
              ${rsync} -ravn --ignore-existing --mkpath --chown=${user}:users "$COMMON_SOURCE" "$USER_HOME/"

              # Apply PROFILE defaults (Dev vs Gamer)
              if [ -d "$PROFILE_SOURCE" ] && [ "${userCfg.profileType}" != "custom" ]; then
                 ${rsync} -ravn --ignore-existing --mkpath --chown=${user}:users "$PROFILE_SOURCE" "$USER_HOME/"
              fi

              # Apply USER OVERRIDES (From their flake)
              if [ -n "${toString userCfg.extraFiles}" ] && [ -d "$USER_OVERRIDE" ]; then
                 echo "[Prism] Applying user overrides for ${user}..."
                 ${rsync} -ravn --ignore-existing --mkpath --chown=${user}:users "$USER_OVERRIDE/" "$USER_HOME/"
              fi
            fi
          '') cfg.users
        );
      in
      stringAfter [ "users" ] script;
  };
}
