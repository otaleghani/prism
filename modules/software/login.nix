{ lib, ... }:

{
  # NOTE: This configuration requires the 'silentSDDM' flake input
  # and module to be imported in your flake.nix.

  programs.silentSDDM = {
    enable = true;

    # Available themes in the flake usually include: "rei", "simple"
    # You can check the flake repo for specific theme names.
    theme = "rei";

    # settings = {
    #   General = {
    #     backgroundMode = "fill";
    #     backgroundColor = "#1e1e2e";
    #   };
    # };
  };

  # Ensure Wayland is enabled for SDDM (Critical for Hyprland)
  services.displayManager.sddm.wayland.enable = lib.mkDefault true;
}
