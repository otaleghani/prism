# Prism: Your OS, refracted.

> **A fully configured, stable-by-design, opinionated Linux. Powered by Nix.**

**Prism** is a NixOS-based distribution designed with a **"state-first"** philosophy. It doesn't just manage your packages; it enforces your environment through the reproducibility of Nix. Prism provides the tools to keep your digital life organized by treating users as a refraction of specific identities—ensuring that whether you are coding, gaming, or creating, your system is perfectly tuned to your current self.

[[#Get started]] - [[#Why Prism?]] - [GitHub](https://github.com/otaleghani/prism)

---

## Why Prism?

Most distributions become "cluttered" over time. You start with good intentions, but eventually, work mixes with play, and play mixes with study. Within months, your system is a mess, and you're wishing for a fresh start. Prism solves this by giving you the tools to organize your life into distinct, isolated states.

### Profile engine

Stop mixing your work life with your play life. Prism refracts a single OS into multiple, purpose-driven identities:

- **Developer:** Pre-configured with simple, flake-powered dev environments that actually work the way you want.
- **Gamer (WIP):** System-wide optimizations for Steam, Gamescope, and low-latency input.
- **Pentester (WIP):** Specialized toolchains for security, including custom scripts and hardened defaults.
- **Creator (WIP):** Media production software suites designed to finally let you ditch Adobe.
- **Custom:** A blank slate for the minimalist purist who wants to build from scratch.

### Stability and reliability

- **Unified Updates:** One command (`prism-update`) refreshes your entire machine—kernel, drivers, and UI—to a maintainer-verified snapshot. Stay stable, even 100 updates in.
- **Package Isolation:** Thanks to Nix, every package is built in total isolation. If the configuration is correct, the system builds; if it builds, it works.
- **Atomic Rollbacks:** Broken update? No problem. NixOS allows you to rollback to a previous generation instantly. You are never more than a reboot away from a working system.
- **Override System:** Don't like the defaults? Use the built-in override system to "save" your custom dotfiles, ensuring your personal touch survives system updates.

### Keyboard first design

Built on **Hyprland** and **Quickshell**, Prism offers an easy-to-follow "home-row" workflow:

- **Home Row Apps:** Launch your Terminal, Browser, and AI Assistant without moving your hands from the typing position.
- **Dynamic Groups:** Tab your windows together into logical stacks with `$SUPER + R`.
- **The Scratchpad:** A hidden "drawer" for your most-used tools, summoned instantly with `$SUPER + T`.   
- **Dedicated Workspaces:** Music players and messaging apps have their own permanent, specialized workspaces so they never clutter your view.

## Built for speed

Prism isn't just a skin; it's a high-performance engine built on modern primitives:

- **Ghostty:** The next-generation, GPU-accelerated terminal for ultimate responsiveness.
- **Quickshell:** A reactive, QML-based UI engine powering your bars and dashboards.
- **Yazi:** An asynchronous, Rust-based terminal file manager for blazing-fast navigation.
- **Neovim:** A fully-fledged, IDE-grade text editing experience pre-baked into the core.

## Get started

Prism can be installed via ISO, built as a custom image, or layered onto an existing NixOS installation.

### New installation

Download the ISO and run the interactive TUI installer:

```bash
prism-installer
```

_(Choose your persona, partition your disk, and reboot. Done.)_

### Transition from existing NixOS

Already on NixOS? Transition to Prism by creating a `flake.nix` that points to the Prism source:

```
{
  description = "Your Prism System";

  inputs = {
    prism.url = "github:otaleghani/prism";
  };

  outputs = { self, prism, ... }@inputs: {
    nixosConfigurations.prism = prism.inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hardware-configuration.nix
        ./users.nix
        prism.nixosModules.default
        ( { ... }: {
          prism.hardware.boot.mode = "uefi";
          prism.hardware.gpu = "nvidia"; # Or amd/intel
        })
      ];
    };
  };
}
```

---

## Make it yours

Every persona needs a style. Prism’s theming is dynamic and instantaneous.

- **Live Theming:** Switch styles with `$MOD + CTRL + T`. Everything (Waybar, Terminal, GTK) updates instantly via symlink magic.
- **Webapp Integration:** Turn any website into a standalone, "focused" window using `prism-install-webapp`.
- **Virtualization Ready:** KVM/QEMU is pre-configured with TPM support. Spin up Windows 11 or other Linux distros with near-native performance.

---

## Community and contributing

Prism is open source and driven by the pursuit of the **"Perfect State."**

- **Found a Bug?** Open an issue on [GitHub](https://github.com/otaleghani/prism).
- **Want to help?** We are currently building out the **Pentester** and **Creator** personas.
- **Love the Project?** Give us a star and join the refraction!