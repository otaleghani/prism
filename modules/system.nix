{ pkgs, ... }:

{
  #  Global Tools required for Prism to function
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    rsync

    # Prism toolset
    prism.portal
    prism.pkg-manager
  ];

  programs.zsh.enable = true;
  security.polkit.enable = true;
  programs.hyprland.enable = true;

  system.activationScripts.createSharedDir = ''
    mkdir -p /home/shared
    chown root:users /home/shared
    chmod 770 /home/shared
  '';
}
