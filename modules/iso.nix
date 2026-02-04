{
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    # Switch to Minimal (TTY only, smaller, more reliable)
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # --- ISO Settings ---

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

  # Optional: Auto-start the installer wizard on login
  # services.getty.helpLine = lib.mkForce "Run 'prism-installer' to start the setup wizard.";
}
