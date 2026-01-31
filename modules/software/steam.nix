{
  config,
  lib,
  ...
}:

let
  # Get all users defined in your config
  allUsers = lib.attrValues config.prism.users;

  # Check if ANY user has profileType = "gamer"
  # lib.any returns true if the condition is met for at least one item
  hasGamerProfile = lib.any (user: user.profileType == "gamer") allUsers;

in
{
  # Only apply this configuration if a gamer exists
  config = lib.mkIf hasGamerProfile {

    # Steam configuration
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server

      # Enable Gamescope (the micro-compositor used on the Steam Deck)
      # Great for running games at different resolutions or fixing windowing issues
      gamescopeSession.enable = true;
    };

    # Gamemode
    # Optimises system performance on demand
    programs.gamemode.enable = true;

    # Gamescope (Standalone)
    programs.gamescope = {
      enable = true;
      capSysNice = true; # Allow gamescope to renice itself for performance
    };

    # Hardware specifics
    # If using a controller, we might want to enable udev rules
    hardware.xpadneo.enable = true; # Xbox One controller support (bluetooth)
  };
}
