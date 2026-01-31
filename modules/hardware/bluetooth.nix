{ lib, ... }:
{
  hardware.bluetooth = {
    enable = lib.mkDefault true;
    powerOnBoot = lib.mkDefault true;
    settings = {
      General = {
        # Helps with battery reporting on some headsets
        Experimental = true;
      };
    };
  };
}
