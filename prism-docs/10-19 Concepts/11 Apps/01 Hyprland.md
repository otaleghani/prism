# Hyprland

Hyprland is a dynamic Wayland tiling compositor that provides the "smooth-as-butter" animations and the rigid tiling logic that defines your workflow.

## Configuration

Prism uses Hyprland's Lua configuration, introduced in Hyprland 0.55. The entry point is `~/.config/hypr/hyprland.lua`; its `require()` calls load the input, monitor, appearance, window-rule, keybinding, and startup modules alongside it.

- `programs.lua` defines the main modifier and application commands.
- `styles.lua` loads the active palette from `~/.local/share/prism/current/hypr.lua`.
- `mode.lua` supplies profile-specific bindings. The custom profile has an empty default.
- Startup applications are registered with `hl.on("hyprland.start", ...)`, so configuration reloads do not launch duplicate processes.

The original Hyprlang files are preserved in `~/.config/hypr/old/`. Theme originals live in each theme's `old/` directory. These are reference copies and are not loaded by the Lua configuration.

When upgrading an existing installation, migrate any saved Hyprland or theme overrides to Lua as well. Deploy the new defaults and helper packages together, then log out and back in to switch the running compositor to the Lua parser. Subsequent Lua edits can use the normal automatic reload or `hyprctl reload`.

From the Prism repository, validate all profiles and themes without starting or reloading a desktop:

```sh
python3 scripts/check-hyprland-config.py
```

## Useful links

- **[Official documentation](https://wiki.hypr.land/0.56.0/Configuring/Start/)**: Lua configuration for the Hyprland version currently used by Prism.
- **[Hyprland GitHub](https://github.com/hyprwm/Hyprland)**: Follow the development of the compositor itself.
- **[NixOS Wiki: Hyprland](https://nixos.wiki/wiki/Hyprland)**: Specific notes on running Hyprland on NixOS.
