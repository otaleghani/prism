# `prism-update`

The standard method for keeping Prism up to date. It queries GitHub for official release tags, updates the Flake lockfile to point to the selected version, and then performs a system rebuild.

## How it works

1. **Release Discovery:** Uses GitHub releases, falling back to Git tags when the API is unavailable or rate-limited.
2. **Flake Locking:** Updates the `prism` input and lockfile to the selected tag.
3. **System Rebuild:** Triggers `nixos-rebuild switch`, applying all system and home-manager changes defined in the new version.

## Usage

```
prism-update
```

For the unstable `main` branch:

```bash
prism-update unstable
```

## GitHub rate limits

If GitHub rate-limits your network, retry later or configure a GitHub token for Nix:

```bash
mkdir -p ~/.config/nix
printf 'access-tokens = github.com=YOUR_TOKEN\n' >> ~/.config/nix/nix.conf
```
