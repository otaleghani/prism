# `prism-save`

`prism-save` is Prism’s built-in **dotfile persistence manager**. It bridges the gap between your live home directory and the immutable nature of NixOS. Since Prism configurations are reset on reboot, `prism-save` allows you to "track" specific local files or folders and back them up into your Prism repository, which will override the standard Prism configuration.

## How it works

1. **Repository Detection:** The script automatically looks for your Prism configuration repository at `/etc/prism` or `~/.config/prism`.
2. **Tracking Mechanism:** It maintains a hidden list at `~/.prismsave`. Any file added here is remembered for future syncs.
3. **Override Mirroring:** When a file is "saved," the script calculates its path relative to your `$HOME` and mirrors that exact structure inside the Prism repository under `overrides/[your-username]/`.
4. **Idempotency:** It ensures that files are safely copied and that empty parent directories are cleaned up when a file is removed from tracking.

## Dependencies

- `coreutils`: For path resolution (`realpath`) and file operations (`cp`, `mkdir`).
- `findutils`: For directory management.
- `gnugrep`: For managing the tracking list.

## Usage

|**Command**|**Action**|
|---|---|
|`prism-save <file>`|Starts tracking a file/folder and copies it to overrides immediately.|
|`prism-save`|Synchronizes all currently tracked files to the repository.|
|`prism-save delete <file>`|Stops tracking a file and deletes its copy from the repository.|

## **Example Scenario**

If you want to persist your Neovim configuration:

```bash
prism-save ~/.config/nvim
```

This will copy your Neovim folder to `/etc/prism/overrides/user/.config/nvim`. When you eventually rebuild your system, move to a new machine or just reboot, these overrides can be linked back into place.

## The persistence workflow

1. **Modify:** You change a config file in your home directory.
2. **Save:** You run `prism-save`.
3. **Persist:** The script mirrors the file into the `/etc/prism` repository.
4. **Commit:** You can now commit your `/etc/prism` changes to Git, making your custom tweaks permanent and portable.