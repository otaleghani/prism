{ lib, ... }:
{
  # Enable CUPS to print documents
  services.printing.enable = lib.mkDefault true;

  # Enable autodiscovery of network printers (e.g. WiFi printers)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
