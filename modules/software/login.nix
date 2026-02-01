{
  pkgs,
  lib,
  config,
  ...
}:

let
  # Path to your local wallpaper file
  wallPath = ../../../defaults/wallpapers/login.jpg;

  # Create a derivation for the wallpaper.
  # We use runCommand to copy it into the Nix store.
  # The name "login.jpg" ensures the store path ends in .jpg, which helps SDDM detect the file type.
  loginWallpaper = pkgs.runCommand "login.jpg" { } ''
    cp ${wallPath} $out
  '';
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
        # ABSOLUTE PATH to the store file.
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
