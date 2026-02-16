# Boot configuration

The `prism.hardware.boot` option tells your system how to handle the handoff from your computer's hardware (firmware) to the Linux kernel. Getting this right is essential for a successful build.

## Modern PCs (UEFI)

If your computer was made in the last 10 years, it almost certainly uses **UEFI**. This mode uses **systemd-boot**, which is fast, minimal, and integrates perfectly with NixOS.

```nix
prism.hardware.boot.mode = "uefi";
# Optional: Change the mount point if your EFI partition isn't /boot
# prism.hardware.boot.efiMount = "/boot/efi"; 
```

## Virtual Machines or old PCs (Legacy/BIOS)

If you are running Prism inside a Virtual Machine (like QEMU/KVM without UEFI enabled) or on much older hardware, you should use **Legacy** mode. This uses the **GRUB** bootloader.

```nix
prism.hardware.boot.mode = "legacy";
# Optional: Specify the disk for the bootloader if it's not /dev/sda
# prism.hardware.boot.device = "/dev/nvme0n1";
```

## Which one should I choose?

If you are unsure which mode your hardware supports, you can check while booted into the Prism ISO:

1. Open a terminal.
2. Run: `ls /sys/firmware/efi`
3. **If the directory exists:** Use `uefi`.
4. **If it doesn't exist:** Use `legacy`.

## Advanced boot tweaks

For advanced users who need to modify kernel parameters (e.g., for silent boot or troubleshooting), you should add them to the standard NixOS `boot` options within your module block:

```nix
( { ... }: {
  boot.kernelParams = [ "quiet" "splash" "nvidia-drm.modeset=1" ];
  
  # Set the timeout for the boot menu (in seconds)
  boot.loader.timeout = 5;
})
```

## Note on partitioning

- **UEFI** requires a dedicated **EFI Partition** (usually FAT32, flagged as `esp`).
- **Legacy** usually installs the bootloader to the **MBR** (Master Boot Record) of the drive.