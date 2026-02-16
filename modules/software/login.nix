{ lib, config, ... }:

{
  services.displayManager.ly.enable = lib.mkDefault false;
  services.displayManager.sddm.wayland.enable = lib.mkDefault true;

  programs.silentSDDM = {
    enable = true;
    theme = "default";

    profileIcons = lib.mkIf (config.prism.users != { }) (
      lib.mapAttrs (name: user: user.icon) (lib.filterAttrs (n: u: u.icon != null) config.prism.users)
    );

    # BACKGROUNDS
    backgrounds = {
      default_wall = ../../defaults/wallpapers/login.jpg;
    };

    # SETTINGS
    settings = {
      "General" = {
        scale = 2.0;
      };
      "LockScreen" = {
        background = "login.jpg";
      };
      "LoginScreen" = {
        background = "login.jpg";
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
