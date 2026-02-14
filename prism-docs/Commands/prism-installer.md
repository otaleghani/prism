# `prism-installer`

The master installation wizard for Prism OS. It orchestrates the entire installation process by chaining together specialized sub-scripts for partitioning and configuration generation. It provides a guided, terminal-based user interface (TUI) using `gum` to ensure a smooth installation experience.

## How it works

1. **Initialization:**
    - Clears the screen and displays a stylized ASCII header.
    - Creates a temporary state file (`/tmp/prism-install.env`) to pass variables (like disk selection and hostname) between the different installation steps.
2. **Partitioning (`prism-installer-partition`):**
    - Launches the partitioning wizard (imported from `pkgs/installer/partition.nix`).
    - This step handles disk selection and formatting.
    - It saves critical variables like `BOOT_MODE` and `TARGET_DISK` to the state file.
3. **Configuration (`prism-installer-generate`):**
    - Loads the state from the partitioning step.
    - Launches the configuration wizard (imported from `pkgs/installer/generate.nix`).
    - This step generates the NixOS configuration, sets the hostname, and determines the Prism version tag (`LATEST_TAG`).
4. **Installation:**
    - Displays a summary of the configuration (Target Hostname, Version).
    - **Confirmation:** Asks the user to confirm before making permanent changes.
    - **Flake Locking:** Generates a `flake.lock` file inside the target directory (`/mnt/etc/prism`) to ensure reproducible builds and prevent installation crashes.
    - **System Install:** Executes `nixos-install --flake ...` to install the system to the mounted disk. It uses the `--no-root-passwd` flag, implying root password setup is handled elsewhere or via `sudo` configuration.
    - **Post-Install:** Fixes file ownership on the installed configuration files (`/etc/prism`) to ensure the primary user (UID 1000) can edit them later.
5. **Completion:** Offers to reboot the system immediately upon success.

**Dependencies**

- `gum`: Provides the interactive TUI elements (spinners, confirm dialogs, styling).
- `nix`: Required for flake operations.
- `nixos-install-tools`: Provides the core `nixos-install` command.
- `prism-installer-partition`: (Sub-script) Handles disk partitioning.
- `prism-installer-generate`: (Sub-script) Handles config generation.

## Usage 

To start the installation from the live environment:

```bash
prism-installer
```