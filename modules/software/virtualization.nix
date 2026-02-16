{
  pkgs,
  lib,
  config,
  ...
}:

{
  # Virtualization Backend
  # Enables the libvirtd daemon and the KVM/QEMU stack
  virtualisation.libvirtd = {
    enable = lib.mkDefault true;

    # QEMU configuration
    # Optimization for modern hardware and TPM support (required for Windows 11)
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [ pkgs.OVMFFull.fd ];
      };
    };
  };

  # GUI Management Tools
  # Includes Virt-manager for the UI and Spice-gtk for high-performance guest display
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
  ];

  # User Group Access
  # Automatically adds the main user to the necessary groups to manage VMs
  # without constant sudo prompts.
  users.users.${config.prism.user.name}.extraGroups = [
    "libvirtd"
    "kvm"
  ];

  # High-Performance Guest Access
  # Enables SPICE guest support for better clipboard sharing and resolution scaling
  services.spice-vdagentd.enable = true;

  # Shared Folders
  # Useful for moving files between Prism (Host) and the VM (Guest)
  virtualisation.spiceUSBRedirection.enable = true;

  # Persistence & Configuration
  # Ensures the virt-manager connection URI is set to system QEMU by default
  programs.virt-manager.enable = true;

  # UI Integration
  # Optional: Adds the dconf settings for Virt-manager so it follows your system theme
  programs.dconf.enable = true;
}
