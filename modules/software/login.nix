{ lib, ... }:

{
  services.displayManager.sddm = {
    enable = lib.mkDefault true;

    # Critical for Hyprland: run SDDM in Wayland mode
    wayland.enable = lib.mkDefault true;

    # We leave the theme unset to use the default SDDM theme.
    # To add a custom theme later, you would add the package to
    # environment.systemPackages and set 'theme = "name";' here.
  };
}
