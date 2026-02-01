{ lib, ... }:

{
  services.displayManager.ly = {
    enable = lib.mkDefault true;
  };
}
