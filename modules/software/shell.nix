{ pkgs, lib, ... }:
{
  programs.zsh = {
    enable = lib.mkDefault true;

    # Modern features that make the terminal easier to use
    enableCompletion = lib.mkDefault true;
    autosuggestions.enable = lib.mkDefault true; # Grey text suggesting commands
    syntaxHighlighting.enable = lib.mkDefault true; # Colors commands red/green

    # History settings
    histSize = lib.mkDefault 10000;
  };

  # Set Zsh as the default shell for all users on the system
  users.defaultUserShell = pkgs.zsh;

  # Add Zsh to the list of authorized shells in /etc/shells
  # This is required for the defaultUserShell setting to work correctly.
  environment.shells = with pkgs; [ zsh ];

  # Starship prompt
  programs.starship = {
    enable = lib.mkDefault true;
  };
}
