# Installation

Installing **Prism** is designed to be a streamlined experience, moving from a live environment to a fully configured NixOS system in minutes.

## Prerequisites

- A USB drive (minimum 8GB).
- An active internet connection (Ethernet is recommended, though Wi-Fi is supported).
- **Backup your data:** The default installation path will erase the target disk.

## Prepare the Media

Download the latest **Prism ISO** from the official GitHub repository:

> [!info] Download link
>  You can download the minimal ISO from the [GitHub latest release page](https://github.com/otaleghani/prism/releases/latest)

Flash the ISO to your USB drive using `dd`, [BalenaEtcher](https://etcher.balena.io/), or [Raspberry Pi Imager](https://www.raspberrypi.com/software/).

```bash
# Example using dd
sudo dd if=prism-os.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

## Booting & Partitioning

Boot your machine from the USB drive. You will land in the Prism Live TUI environment.

### Disk Setup

Before running the installer, you must decide how to handle your partitions:

- **Automatic (Wipe):** The installer can handle this for you, but it **will erase the entire disk**.
- **Manual (GParted):** If you need a specific partition layout (Dual boot, separate `/home`), launch GParted from the terminal:

```bash
gparted
```

## Running the Installer

Once your partitions are ready (or if you've decided to wipe the disk), launch the interactive Prism installation wizard:

```bash
prism-installer
```

The Wizard Workflow:

1. **Network Check:** Ensures you are connected to the internet to fetch the latest Nix flakes.
2. **Hardware Detection:** Scans for NVIDIA/AMD GPUs and optimizes kernel modules.
3. **User Creation:** Sets up your primary Prism user and initial password.
4. **Profile Selection:** Choose your "Persona" (Developer, Gamer, Creator, etc.) to pre-install specific toolchains.
5. **Installation:** The system will fetch the latest `prism` flake and build your environment.

## First boot

Once the installer finishes, remove the USB drive and reboot your system:

```bash
reboot
```

Upon logging in, Prism will run its **Scaffolding Script**. This is normal! It is steamrolling the default themes, wallpapers, and configurations into your `$HOME` directory to ensure you land in a pixel-perfect environment.

## Post-Installation

If you used the latest ISO, your system should be up to date. But to ensure it you can run the following command. 

```bash
prism-update
```