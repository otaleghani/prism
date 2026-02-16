{
  pkgs,
  lib,
  config,
  ...
}:

let
  # Extract the list of usernames defined in your prism.users option
  # that are intended to be normal interactive users.
  vmUsers = lib.mapAttrsToList (name: userCfg: name) (
    lib.filterAttrs (name: userCfg: userCfg.isNormalUser) config.prism.users
  );
in
{
  # Virtualization Backend
  # Enables the libvirtd daemon and the KVM/QEMU stack
  virtualisation.libvirtd = {
    enable = lib.mkDefault true;

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
  # Injects the 'libvirtd' and 'kvm' groups into every user defined in your Prism config.
  users.users = lib.genAttrs vmUsers (name: {
    extraGroups = [
      "libvirtd"
      "kvm"
    ];
  });

  # High-Performance Guest Access
  # Enables SPICE guest support for better clipboard sharing and resolution scaling
  services.spice-vdagentd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # UI Integration
  # Ensures the virt-manager connection URI is set to system QEMU by default
  programs.virt-manager.enable = true;
  programs.dconf.enable = true;
}
