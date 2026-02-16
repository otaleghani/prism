# Users

The name **Prism** comes from the idea of taking a single system and splitting it into distinct "spectral" profiles. Each user account on your machine is more than just a login; it is a **Persona** with a specific set of tools, keybindings, and behaviors. To do this Prism gives you the [[07 prism-users]] utility that allows you to easily add and remove users without touching your NixOs configuration.

## Available users profiles

When defining a user in your `flake.nix`, you assign them a `profileType`. This dictates what "layer" of defaults Prism applies to their home directory.

| Persona       | Purpose           | Key Features                                                                             |
| ------------- | ----------------- | ---------------------------------------------------------------------------------------- |
| **Developer** | Coding & DevOps   | `prism-project-new`, `prism-project-open`, `prism-api-test`, and specialized dev shells. |
| **Custom**    | Minimalist        | A blank slate. No profile-specific packages or scripts; just the core Prism environment. |
| **Gamer**     | High-Perf Play    | (WIP) Includes optimizations for low-latency input and game launchers.                   |
| **Pentester** | Security Research | (WIP) Pre-configured network tools and isolated security environments.                   |
| **Creator**   | Media Production  | (WIP) Low-latency audio (Pipewire/Jack) and video editing suites.                        |

## Configuration flexibility

Prism does not force a multi-user setup on you. If you prefer one "God User" who does everything, simply create a single account. However, the multi-user approach allows you to:

- **Isolate Work:** Keep your production SSH keys and project files away from your gaming account.
- **Custom Keybinds:** Use `$MOD + CTRL + [1-9]` for different scripts depending on who is logged in.
- **Dependency Management:** Ensure your "Gamer" profile doesn't bloat your "Developer" profile with wine/proton dependencies.

## The Steam dilemma

While most things in Prism are per-user, some software is "heavy" and requires deep system-level integration. **Steam** is the primary example.

Because Steam requires specific firewall rules, 32-bit libraries, and kernel-level performance tweaks (like Gamescope and Gamemode), it must be enabled at the **system level** in your `flake.nix` rather than just added to a user's package list.

#### How to enable Gaming Support

If you wish to take a non-gamer user and giving it gaming capabilities, add this block to your main NixOS configuration:

```nix
{
  # ... inside your configuration ...
  
  # Enable Steam & Gamescope
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; 
    dedicatedServer.openFirewall = true; 
    gamescopeSession.enable = true;
  };

  # Feral Gamemode for performance optimization
  programs.gamemode.enable = true;

  # Standalone Gamescope (Micro-compositor)
  programs.gamescope = {
    enable = true;
    capSysNice = true; 
  };

  # Controller Support
  hardware.xpadneo.enable = true; # Xbox controller drivers
}
```