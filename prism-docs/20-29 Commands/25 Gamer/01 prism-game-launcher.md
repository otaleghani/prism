# `prism-game-launcher`

A unified "Game Center" for Prism. Instead of hunting through different storefronts or specific TUI folders, this script aggregates all installed games from Steam, Lutris, Heroic, and native Linux installations into a single, searchable **Rofi** menu. It specifically filters for applications tagged with the `Game` category in their system metadata.

## How it works

1. **Library Scanning:** The script indexes standard Linux application directories (`/run/current-system/sw/share/applications` and `~/.local/share/applications`).
2. **Metadata Filtering:** It searches inside `.desktop` files for the `Categories=Game` string, ensuring only actual games appear in the list (and not tools like Steam itself).
3. **Unified UI:** It presents the list in a fuzzy-searchable Rofi menu.
4. **Execution:** Once selected, it uses `gtk-launch` to trigger the game, ensuring it inherits the correct environment variables and storefront integration (like Steam's overlay).

## Usage

```bash
prism-game-launcher
```