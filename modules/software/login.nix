{
  pkgs,
  lib,
  config,
  ...
}:

let
  # Use fetchurl to download from the repo.
  # This avoids "pure evaluation" errors with local paths in Flakes.
  loginWallpaper = pkgs.fetchurl {
    name = "login.jpg";
    url = "https://raw.githubusercontent.com/otaleghani/prism/main/defaults/wallpapers/login.jpg";
    sha256 = "sha256-000000000000000000000000000000000000000000000";
  };
in
{
  services.displayManager.ly.enable = lib.mkDefault false;
  services.displayManager.sddm.wayland.enable = lib.mkDefault true;

  programs.silentSDDM = {
    enable = true;
    theme = "rei";

    profileIcons = lib.mkIf (config.prism.users != { }) (
      lib.mapAttrs (name: user: user.icon) (lib.filterAttrs (n: u: u.icon != null) config.prism.users)
    );

    backgrounds = {
      # We include it here to ensure it is part of the system closure
      "login.jpg" = loginWallpaper;
    };

    settings = {
      LoginScreen = {
        # The 'backgrounds' option above copies the file with a hash in its name,
        # so referring to it simply as "login.jpg" fails.
        # By interpolating the derivation here, we give SDDM the exact /nix/store/... path.
        background = "${loginWallpaper}";

        backgroundMode = "fill";
        backgroundColor = "#1e1e2e";
        textColor = "#cdd6f4";
      };

      "LoginScreen.LoginArea" = {
        backgroundColor = "transparent";
      };

      "LoginScreen.LoginArea.Avatar" = {
        shape = "circle";
        "active-border-color" = "#cba6f7";
      };
    };
  };
}
