{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Define the standard packages
  # This is where you define what "being a Developer" actually means in terms of software.
  profilePackages = {

    dev = with pkgs; [
      hello
      # Version Control
      # git
      # lazygit
      # Editors & Tools
      neovim
      # ripgrep
      # fd
      # fzf
      # jq
      # Languages / Runtimes
      # nodejs
      # python3
      # go
      # cargo
      # gcc
      # gnumake
      # Terminals
      # alacritty
      # tmux
    ];

    gamer = with pkgs; [
      cowsay
      # Launchers
      # steam
      # lutris
      # heroic
      # Tools
      # mangohud
      # gamemode
      # protonup-qt
      # Chat
      # discord
    ];

    pentester = with pkgs; [
      # Analysis
      # wireshark
      nmap
      # Web
      # burpsuite
      # Exploitation
      # metasploit
      # thc-hydra
    ];

    # 'custom' profiles get nothing by default
    custom = [ ];
  };

in
{
  # Logic to merge packages
  # We read the user's choice (config.prism.users.<name>.profileType)
  # and inject the corresponding packages into their system user.

  config.users.users = lib.mapAttrs (name: userCfg: {
    packages = (profilePackages.${userCfg.profileType} or [ ]);
  }) config.prism.users;
}
