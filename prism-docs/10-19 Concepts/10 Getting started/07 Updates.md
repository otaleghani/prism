# System updates

Prism is a **Curated Distribution**. Unlike traditional Linux distros where packages update individually, or standard NixOS where you manage your own version locks, Prism uses a "Certified Release" model.

## Certified release model

When you update Prism, you aren't just getting new scripts; you are receiving a **verified snapshot** of the entire NixOS ecosystem (kernel, drivers, and apps) that I have personally tested for compatibility with Prism.

## How to update

Because your system "follows" the Prism Core, updating is a single-step process.

### Stable update (Recommended)

This is the safest way to maintain your system. It pulls the latest official "Certified" release.

```bash
prism-update
```

- **Keybinding:** `$MOD + SHIFT + CTRL + U`
- **What it does:** Updates the `prism` input in your `flake.lock`. This automatically refreshes your applications, kernel, and Prism tools to my latest verified versions.

## Unstable update (Bleeding edge)

If you want to test features currently in development:

```bash
prism-update-unstable
```

- **What it does:** Fetches the absolute latest commit from the `main` branch.
- **Warning:** Use this only if you are comfortable debugging potential "Work in Progress" issues.

## Declarative package updates

If you have added your own packages to your `flake.nix` (declaratively), they will be updated automatically whenever you run `prism-update`.

Since your configuration is tied to the Prism input:

```
# Your system uses the maintainer's tested Nixpkgs
prism = prism.inputs.nixpkgs.lib.nixosSystem { ... }
```

Your personal apps (Discord, VSCode, etc.) will always stay in perfect sync with the versions Prism expects. You will never face a situation where a system update breaks your `waybar` or `ghostty` configuration.

## Maintenance philosophy

### Atomic Rollbacks

If a "Certified Release" doesn't work well with your specific hardware, **do not panic.** Reboot your computer and at the boot menu, select a **Previous Generation**. You are now back to the exact state your computer was in before the update.

### Why this matters for you

By subscribing to the Prism input, you let me take the "bullet" of breaking upstream changes. I fix the code, I test the build, and you just run one command to get the polished result.