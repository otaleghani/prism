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
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server

      # Enable Gamescope (the micro-compositor used on the Steam Deck)
      # Great for running games at different resolutions or fixing windowing issues
      gamescopeSession.enable = true;
    };

    # Gamemode
    programs.gamemode.enable = true;
    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    # Hardware specifics
    hardware.xpadneo.enable = true; # Xbox One controller support (bluetooth)
  };
}
