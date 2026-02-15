Users are the reason prism is called prism! The idea behind this is that every user has it's own purpose. This way you can divide your gaming profile from you work profile. Choosing a profile instead of another will provide you with packages and custom keybindings.

There are different types of users that you can choose from.
- Developer
- Gamer
- Custom
- Pentester (WIP)
- Creator (WIP)

The custom one is just a blank user with no other packages installed. 

Do you have to abide from this structure? Nope! You can decide how to use your system however you want! If you prefer a single user setup, go for it!

## The steam dilemma

The only thing that you need to keep in mind is that if you wish to game on your machine you'll need to add at least a "gamer" user. Reason why is that Steam has to installed system-wide, not per-user. If you do not wish to have it in your setup, just copy add this into your configuration:

```nix
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

```