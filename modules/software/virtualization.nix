{
  pkgs,
  lib,
  config,
  ...
}:

let
  # Dynamically fetch normal users for VM group assignment
  vmUsers = lib.mapAttrsToList (name: userCfg: name) (
    lib.filterAttrs (name: userCfg: userCfg.isNormalUser) config.prism.users
  );
in
{
  # Virtualization Backend
  # Enables libvirtd and the KVM/QEMU stack
  virtualisation.libvirtd = {
    enable = lib.mkDefault true;

    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  # GUI Management Tools
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
  ];

  # User Group Access
  # Grants VM control to all interactive Prism users
  users.users = lib.genAttrs vmUsers (name: {
    extraGroups = [
      "libvirtd"
      "kvm"
    ];
  });

  # High-Performance Guest Access
  services.spice-vdagentd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # UI Integration
  programs.virt-manager.enable = true;
  programs.dconf.enable = true;
}
