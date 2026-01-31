{ lib, ... }:

{
  networking = {
    # Enable NetworkManager (Standard for desktops)
    networkmanager.enable = lib.mkDefault true;

    # Firewall Settings
    firewall = {
      enable = lib.mkDefault true;

      # Common development ports (Web servers, Vite, Astro, etc.)
      # We open these by default for convenience, but users can override
      # this list if they want stricter security.
      allowedTCPPorts = lib.mkDefault [
        4321 # Astro / Vite
        8080 # Generic Web
        8081 # Generic Web Alt
      ];
      allowedUDPPorts = lib.mkDefault [
        4321
        8080
        8081
      ];
    };

    # Default DNS (Cloudflare)
    # Fast and reliable defaults.
    nameservers = lib.mkDefault [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
  };
}
