# `prism-update`

The standard method for keeping Prism up to date. It queries GitHub for the latest official release tag, updates the Flake lockfile to point to that specific version, and then performs a system rebuild.

## How it works

1. **Release Discovery:** Uses `curl` to hit the GitHub API and `jq` to parse the `tag_name` of the latest stable release.
2. **Flake Locking:** Executes `nix flake lock` with an override to pin the `prism` input to the discovered tag.
3. **System Rebuild:** Triggers `nixos-rebuild switch`, applying all system and home-manager changes defined in the new version.

## Usage

```
prism-update
```


> [!caution] `--reset-dotfiles`
> This script supports the `--reset-dotfiles` flag. This feature is deprecated and should not be used. Learn more about [[Overrides]] instead.