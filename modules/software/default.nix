{ pkgs, ... }:

{
  # Global tools required for Prism to function
  environment.systemPackages = with pkgs; [
    git
    neovim
    wget
    rsync

    # Prism toolset
    prism.portal
    prism.pkg-manager
  ];
}
