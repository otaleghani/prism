{ pkgs, lib, ... }:

{
  # ================================================================
  # LOGIN MANAGER (Ly)
  # ================================================================

  services.displayManager.sddm.enable = lib.mkDefault false;

  services.displayManager.ly = {
    enable = lib.mkDefault true;

    settings = {
      # animation: none, doom, matrix, fire
      animation = "doom";

      # Enable the cool big clock
      big_clock = true;
      clock = true;

      # The box around the login prompt
      blank_box = true;
      hide_borders = false;

      # Hide build users (nixbld*) which start at UID 30000
      max_uid = 29000;

      # Hide system users (below 1000)
      min_uid = 1000;

      # NOTE: Ly does not easily allow showing Root (UID 0)
      # while hiding other system users (UID 1-999).
      # You can usually still log in as root by typing the name manually
      # if the interface allows, or just use 'sudo' from your normal user.
    };
  };
}
