{ lib, ... }:
{
  services.power-profiles-daemon.enable = lib.mkDefault true;
}
