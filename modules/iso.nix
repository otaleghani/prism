{
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    # The Wizard
    (pkgs.callPackage ../pkgs/prism-installer.nix { })

    # Tools needed for manual/auto intervention
    git
    neovim
    gum
    parted # For partitioning
    dosfstools # For FAT32 (EFI) formatting
    e2fsprogs # For Ext4 formatting
  ];
}
