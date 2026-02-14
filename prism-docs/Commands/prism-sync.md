# `prism-sync`

`prism-sync` is the background maintenance utility for the Prism package management system. Its sole responsibility is to build and maintain a local "package database." This database allows `prism-install` to provide near-instantaneous fuzzy search results without needing to query the internet or the vast Nixpkgs tree in real-time.

## How it works

1. **Cache Preparation:** It ensures the directory `~/.cache/prism` exists.
2. **Package Indexing:** It runs `nix-env -qaP --description`.
    - **-q (Query):** Looks for packages.
    - **-a (Available):** Looks for what _can_ be installed, not just what _is_ installed.
    - **-P (Path):** Includes the attribute path (e.g., `nixpkgs.firefox` instead of just `firefox`).
    - **--description:** Fetches the brief summary of each package.
3. **Sanitization:** It uses `grep` to filter out `nixos.` attribute paths. These are often internal modules or configuration functions rather than installable binaries, and attempting to index them can cause the script to error out.
4. **Storage:** The final output is saved to `~/.cache/prism/pkglist.txt`, which serves as the "source of truth" for the `prism-install` UI.

## Dependencies

- `nix`: The primary tool used to query the repository.
- `coreutils`: For directory management (`mkdir`) and line counting (`wc`).

## Usage

This script is typically run automatically by `prism-install` if the cache is missing, but can be run manually to refresh the list after a Nix channel update.

```bash
prism-sync
```