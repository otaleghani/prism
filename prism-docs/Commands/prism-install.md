# prism-install

The primary package manager interface for the user. It provides a fast, fuzzy-searchable list of available packages to install imperatively into the user's profile. It relies on a local cache of package data to ensure instant search results without needing to query the internet every time.

## How it works

1. **Cache Verification:**
    - It checks for the existence of the package database at `~/.cache/prism/pkglist.txt`.
    - If the database is missing, it automatically triggers `prism-sync` to download/generate it before proceeding.
2. **Interactive Search:**
    - It loads the package list into `fzf` (Fuzzy Finder).
    - **Preview Window:** As you scroll through the list, a preview pane at the top displays the description of the currently highlighted package.
    - **Search Scope:** The search is restricted to package names (ignoring descriptions) for cleaner matching.
3. **Installation:**
    - Once a package is selected, the script extracts the package attribute name (e.g., `firefox`).
    - It runs `nix profile install "nixpkgs#<name>"`, pulling the package from the configured Nix channels and installing it into the user's environment.

## Dependencies

- `fzf`: Powered the interactive search UI.
- `prism-sync`: An external script required to generate/update the package cache (likely fetches the latest package list from Nixpkgs).
- `nix`: The underlying package manager.
- `gawk`: Used to parse the selection string.

## Usage

```bash
prism-install
```

**Keybindings (within the interface)**

- **Type:** Filter the package list.
- **`Enter`:** Install the selected package
- **`ESC` / `Ctrl+C`:** Cancel.

> [!note] Imperative package management
> Packages installed via this tool are managed "imperatively." This means they are installed for the current user session and won't necessarily persist if you wipe your user directory, unlike "declarative" packages defined in your system configuration. To remove them, use [[prism-delete]].