{ pkgs, lib, ... }:

{
  programs.hyprland = {
    enable = lib.mkDefault true;

    # XWayland support is crucial for compatibility with many apps
    # (games, older tools, Electron apps not in Wayland mode)
    xwayland.enable = lib.mkDefault true;
  };

  # Environment Variables
  environment.sessionVariables = {
    # Hint Electron apps to use Wayland directly instead of XWayland
    # This usually improves performance and scaling.
    NIXOS_OZONE_WL = lib.mkDefault "1";

    # Ensure backend uses Wayland
    GDK_BACKEND = lib.mkDefault "wayland,x11,*";
    QT_QPA_PLATFORM = lib.mkDefault "wayland;xcb";
    SDL_VIDEODRIVER = lib.mkDefault "wayland";
    CLUTTER_BACKEND = lib.mkDefault "wayland";
  };

  # Portals
  # Required for screen sharing, file pickers, and opening links.
  # 'programs.hyprland.enable' adds xdg-desktop-portal-hyprland automatically,
  # but we often need a fallback for file pickers (GTK).
  xdg.portal = {
    enable = lib.mkDefault true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Security (Polkit)
  # Essential for GUI authentication prompts (like "Enter password to update system")
  security.polkit.enable = lib.mkDefault true;
}
