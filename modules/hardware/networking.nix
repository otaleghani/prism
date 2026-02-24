{ lib, ... }:

{
  networking = {
    # wireless.enable = lib.mkDefault false;
    # Enable NetworkManager (Standard for desktops)
    networkmanager = {
      enable = lib.mkDefault false;
      # wifi.backend = lib.mkDefault "iwd";
      # unmanaged = [ "type:wifi" ];
    };

    # Enable the IWD Service explicitly
    # This ensures the daemon is running and listening on DBus for Impala.
    wireless.iwd = {
      enable = lib.mkDefault true;

      settings = {
        # We don't enable 'EnableNetworkConfiguration' here because
        # NetworkManager will handle IP assignment (DHCP).
        General = {
          EnableNetworkConfiguration = true;
          # Roaming thresholds
          RoamThreshold = -70;
        };
      };
    };

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
        27036 # Steam Transfer
      ];
      allowedUDPPorts = lib.mkDefault [
        4321
        8080
        8081
        27031 # Start Steam Transfer
        27032
        27033
        27034
        27035
        27036 # End Steam Transfer
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
