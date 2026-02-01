{ lib, config, ... }:

{
  services.displayManager.ly.enable = lib.mkDefault false;

  # Ensure Wayland is enabled for SDDM
  services.displayManager.sddm.wayland.enable = lib.mkDefault true;

  programs.silentSDDM = {
    enable = true;
    theme = "default"; # The default layout

    # 1. PROFILE ICONS (Dynamic Integration)
    # We automatically map the 'icon' defined in prism.users to SilentSDDM.
    profileIcons = lib.mkIf (config.prism.users != { }) (
      lib.mapAttrs (name: user: user.icon) (lib.filterAttrs (n: u: u.icon != null) config.prism.users)
    );

    # 2. BACKGROUNDS
    # Define a wallpaper to be used in settings
    backgrounds = {
      # OPTION A: Local file in your repo (Recommended)
      # Create this file: defaults/wallpapers/login.png
      default_wall = ../../defaults/wallpapers/login.jpg;

      # OPTION B: Download from internet
      # default_wall = pkgs.fetchurl {
      #   url = "https://raw.githubusercontent.com/catppuccin/wallpapers/main/misc/footsteps.png";
      #   sha256 = lib.fakeSha256; # Build once, get error, paste hash here
      # };
    };

    # 3. SETTINGS (Theme Overrides)
    # Customize colors to match Catppuccin Mocha
    settings = {
      LoginScreen = {
        # Referenced from the 'backgrounds' option above
        background = "default_wall";

        # Ensure it covers the whole screen
        backgroundMode = "fill";

        # Fallback color (if image fails or loads slowly)
        backgroundColor = "#1e1e2e";

        # Color of the User Name text
        textColor = "#cdd6f4";
      };

      "LoginScreen.LoginArea" = {
        # Transparent background for the login box so wallpaper shows through
        backgroundColor = "transparent";
      };

      "LoginScreen.LoginArea.Avatar" = {
        shape = "circle"; # or "rectangle"
        "active-border-color" = "#cba6f7"; # Mauve
      };
    };
  };
}
