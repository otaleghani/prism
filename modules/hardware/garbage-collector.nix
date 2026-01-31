{ lib, ... }:
{
  # Clean up old generations automatically to prevent disk fill-up
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };
}
