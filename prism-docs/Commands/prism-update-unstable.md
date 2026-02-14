
For users who want the "bleeding edge" features or bug fixes that haven't been tagged in a release yet.

## How it works

1. **Branch Update:** Instead of looking for a tag, it simply instructs the Flake to update the `prism` input to the latest commit on the main branch.
2. **System Rebuild:** Follows the same rebuild process as the stable script.

## Usage

```bash
prism-update-unstable
```

> [!caution] `--reset-dotfiles`
> This script supports the `--reset-dotfiles` flag. This feature is deprecated and should not be used. Learn more about [[Overrides]] instead.