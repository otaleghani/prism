{ pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares.nix"
    # Or use 'installation-cd-minimal.nix' if you don't want a GUI desktop environment
  ];

  # ISO Settings

  # Enable Flakes in the installer
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Add our custom installer to the environment
  environment.systemPackages = with pkgs; [
    # The Wizard
    (callPackage ../pkgs/prism-installer.nix { })

    # Tools needed for manual intervention
    git
    neovim
    gparted
    gum
  ];

  # Auto-start the installer wizard on login (Optional)
  # services.getty.helpLine = lib.mkForce "Run 'prism-installer' to start the setup wizard.";
}
