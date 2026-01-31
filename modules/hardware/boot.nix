{ config, lib, ... }:
let
  cfg = config.prism.hardware.boot;
in
{
  options.prism.hardware.boot = {
    mode = lib.mkOption {
      type = lib.types.enum [
        "uefi"
        "legacy"
        "none"
      ];
      default = "none";
      description = "Select bootloader mode: 'uefi' (systemd-boot) or 'legacy' (GRUB).";
    };

    device = lib.mkOption {
      type = lib.types.str;
      default = "/dev/sda";
      description = "Disk device for GRUB installation (Legacy mode only). Check 'lsblk'.";
    };

    efiMount = lib.mkOption {
      type = lib.types.str;
      default = "/boot";
      description = "Mount point for the EFI partition (UEFI mode only).";
    };
  };

  config = lib.mkMerge [

    # UEFI (systemd-boot)
    # Best for: Modern Laptops, Desktops, most new VMs
    (lib.mkIf (cfg.mode == "uefi") {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.efi.efiSysMountPoint = cfg.efiMount;
    })

    # LEGACY BIOS (GRUB)
    # Best for: Older hardware, certain Cloud VMs, QEMU without OVMF
    (lib.mkIf (cfg.mode == "legacy") {
      boot.loader.systemd-boot.enable = false; # Ensure systemd-boot is off
      boot.loader.grub = {
        enable = true;
        efiSupport = false;
        device = cfg.device; # e.g., "/dev/vda" or "/dev/sda"
      };
    })
  ];
}
