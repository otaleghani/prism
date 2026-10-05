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

## A small Windows 11 VM

On an x86_64 Prism host, download the **Windows 11 x64 ISO** from
[Microsoft](https://www.microsoft.com/en-us/software-download/windows11), then run
this command from the Prism repository (no system rebuild needed):

```sh
nix run .#prism-windows -- /absolute/path/to/windows-11-x64.iso
```

This creates a VM named `prism-windows` with 4 CPU cores, 8 GiB RAM, an 80 GiB
QCOW2 disk that grows as used, a TPM 2.0, and Secure Boot-capable UEFI. The host's
default firmware does not have Secure Boot keys enrolled; Secure Boot enforcement
is not enabled by this command. Internet uses QEMU's user networking, and display
and sound use a local SPICE connection. SATA storage and an emulated Intel network
adapter avoid loading VirtIO drivers during the initial installation.

1. Press a key when prompted to boot the Windows installer. Install ordinary
   Windows 11 Home or Pro, matching your license. Avoid an **N** edition for this
   use: it [omits media components](https://support.microsoft.com/en-us/windows/experience/platform-variants/media-feature-pack-for-windows-n).
   Complete the account and privacy prompts;
   decline optional offers and restoration from another PC for a clean start.
2. On the attached VirtIO driver CD, run `virtio-win-guest-tools.exe` to install
   guest drivers and SPICE integration. Restart Windows and install Windows updates.
3. For bundled-app cleanup, open **Windows PowerShell as administrator**. Find
   the CD labelled `PRISM_SETUP` in File Explorer and run the following, replacing
   `E:` with that CD's drive letter:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File E:\cleanup.ps1
   ```

   The execution-policy override applies only to this process. The script removes
   an explicit list of optional apps, including Copilot, Teams, Clipchamp, Outlook,
   and consumer Office/game promotions, for existing and future users. It keeps
   Windows Update, Defender, Store, Edge/WebView2, and media/DRM components. Review
   or edit the list in `pkgs/windows/cleanup.ps1` before building. This is a trimmed
   standard installation; Windows updates can add apps again, and the script can
   be rerun. It does not create a custom or fully unattended Windows installer.
4. Open an up-to-date Windows browser and test the actual NOW programme you want
   to watch, including audio and full-screen playback. A working Windows desktop
   does not establish that protected video works.

Use **Virtual Machine Manager** to start `prism-windows` afterward and to adjust
RAM/CPU allocation while it is shut down. Running the creation command again
refuses an existing VM with that name. Shut Windows down through its Start menu;
closing the viewer leaves the VM running. Eject the installer and helper CDs in
Virtual Machine Manager after setup so the VM no longer depends on those files.
Driver and cleanup CDs are copied to `~/.local/share/prism/windows` (or under
`$XDG_DATA_HOME` when set) to keep libvirt from indexing the entire Nix store.

The flake pins the launcher, driver media, and cleanup script. Windows itself is
installed interactively from your ISO and remains a mutable libvirt disk outside
the Nix store; rebuilding Prism does not recreate or reset it. The optional package
can also be installed through `environment.systemPackages` using
`inputs.prism.packages.${pkgs.stdenv.hostPlatform.system}.prism-windows`.

The cleanup selection can be checked on Linux without a Windows guest:

```sh
nix build .#prism-windows.tests.cleanup
```

### NOW playback limits

NOW currently supports Windows and macOS browsers and explicitly excludes Linux
and Chromebooks ([Italy](https://www.nowtv.it/assistenza/articolo/attraverso-quali-computer-posso-utilizzare-now),
[UK](https://www.nowtv.com/gb/help/article/what-laptops-computers-can-i-use-to-watch)).
Those pages do not confirm virtual-machine support. A Windows VM supplies a
Windows browser, but playback is still an experiment: DRM, graphics drivers and
output protection can prevent playback or limit quality. This preset provides
no GPU passthrough or hardware video acceleration, and makes no HD/UHD guarantee.
For dependable viewing, use a device listed by NOW or Windows running directly
on supported hardware if the VM test fails.

---

### 🔗 Useful Links

- **[Virt-Manager Guide](https://virt-manager.org/)**: Learn the ins and outs of the management interface.
- **[NixOS Virtualization Wiki](https://nixos.wiki/wiki/Libvirt)**: Deep-dive into how NixOS handles virtual machines.
