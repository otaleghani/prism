# Packages

In the world of Nix, you have a choice between **Imperative** (doing things now) and **Declarative** (defining what should exist).

## Imperative way

This is for users who want to install a package and use it immediately without touching a configuration file. It feels like `apt`, `pacman`, or `brew`.

- **Install:** Press `$SUPER + U` to launch `prism-install`.
- **Remove:** Press `$SUPER + CTRL + U` to launch `prism-delete`.
- **Search:** Use `prism-sync` to update the local database, then search via the installer TUI.

## Declarative way

This is for users who want their system to be a mirror of their configuration file. You define your software in your Flake, and Prism ensures the system matches that definition.

### How to install packages declaratively

To add software to your system permanently, edit your flake located at `/etc/prism/flake.nix` (or `$SUPER + Z` -> **Edit system configuration**).

You can add an `environment.systemPackages` block within your module definition:

```nix
{
  # ... inside your outputs/nixosConfigurations ...
  modules = [
    ./hardware-configuration.nix
    ./users.nix
    prism.nixosModules.default
    (
      { pkgs, ... }:
      {
        # --- ADD YOUR PACKAGES HERE ---
        environment.systemPackages = with pkgs; [
          vscode
          discord
          vlc
          obsidian
        ];

        # Existing hardware config
        prism.hardware.boot.mode = "uefi";
        prism.hardware.gpu = "nvidia";
      }
    )
  ];
}
```

After saving the file, apply the changes by running:

**`$SUPER + SHIFT + CTRL + U`** (or `sudo nixos-rebuild switch --flake /etc/prism#prism`).

## Pros and cons

Choosing a path depends on whether you value **speed** or **stability**.

| **Approach**                     | **Pros**                                                                                                                                                                                                                                                                                    | **Cons**                                                                                                                                                                                              |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Imperative** (`prism-install`) | **Instant:** No need to rebuild the whole system.<br><br>  <br>**Low Friction:** Great for testing an app you might delete later.<br><br><br>**Familiar:** Works like every other Linux distro.                                                                                             | **Mutable:** If you reinstall Prism, these apps won't come back automatically.<br><br>  <br>**Harder to Debug:** You might forget _why_ you have an app installed.                                    |
| **Declarative** (Flake)          | **Reproducible:** One file describes your entire PC. Transfer it to a new laptop and get the same apps.<br><br>  <br>**Version Control:** You can use Git to track changes to your software list.<br><br>  <br>**Atomic:** Roll back to a previous "generation" if an update breaks an app. | **Slower:** Requires a system "switch" (rebuild) to take effect.<br>  <br><br>**Syntax:** Requires basic knowledge of Nix language.<br><br> <br>**Overhead:** Tiny changes require a lockfile update. |

> [!TIP]
> 
> **Hybrid strategy:** Personally I install programs declaratively only if I absolutely need them and I want to be able to have them in my next generations. Otherwise I just use the imperative way. 