# Virtualization

Prism is built to be a lab environment. Whether you need to test a new Linux distro, run Windows-only software, or isolate a development environment, the virtualization stack is pre-configured and ready to go.

## Core stack

Prism uses **KVM** (Kernel-based Virtual Machine) and **QEMU** as the engine. To manage these visually, we provide **Virt-Manager**, a powerful GUI that handles everything from disk creation to network bridging.

## Key features

The Prism virtualization module includes several "Quality of Life" features out of the box:

- **TPM Support (`swtpm`):** Enables the Software Trusted Platform Module, which is a strict requirement for installing and running **Windows 11**.
- **SPICE Integration:** Provides high-performance guest display, automatic resolution scaling, and **shared clipboards** between your Prism host and the virtual machine.
- **USB Redirection:** Allows you to plug a physical USB device into your computer and "pass it through" directly into the VM.
- **VirtIO Drivers:** Includes `virtio-win` and `win-spice` to ensure Windows guests run with the fastest possible disk and network speeds.

## Automatic user access

One of Prism's unique touches is the **Dynamic Group Injection**. In standard NixOS, you have to manually add your user to the `libvirtd` group. Prism's module automatically detects all "Normal Users" in your configuration and grants them the necessary permissions to manage VMs without needing root access.

```nix
# This logic in virtualization.nix handles it for you:
users.users = lib.genAttrs vmUsers (name: {
  extraGroups = [ "libvirtd" "kvm" ];
});
```

## How to start your first VM

1. Launch **Virt-Manager** from your app launcher (`$MOD + 0`).
2. The connection to `qemu:///system` should happen automatically.
3. Click the **"New Virtual Machine"** icon.
4. Follow the wizard to select your ISO and allocate CPU/RAM.

> [!TIP] **Performance Tip:** 
> When creating a VM, always choose **"VirtIO"** for the Disk and Network settings. It is significantly faster than the "SATA" or "e1000" emulated defaults.

---

### 🔗 Useful Links

- **[Virt-Manager Guide](https://virt-manager.org/)**: Learn the ins and outs of the management interface.
- **[NixOS Virtualization Wiki](https://nixos.wiki/wiki/Libvirt)**: Deep-dive into how NixOS handles virtual machines.