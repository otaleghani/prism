{ pkgs, lib, ... }:
{
  programs.zsh = {
    enable = lib.mkDefault true;
    enableCompletion = lib.mkDefault true;
    autosuggestions.enable = lib.mkDefault true;
    syntaxHighlighting.enable = lib.mkDefault true;
    histSize = lib.mkDefault 10000;
  };

  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  # Starship prompt
  programs.starship = {
    enable = lib.mkDefault true;
  };
}
