# `prism-users`

`prism-users` is an interactive TUI (Terminal User Interface) utility designed to manage user accounts within the Prism ecosystem. Rather than manually editing Nix expressions and worrying about syntax errors, this script provides a guided wizard to add, list, or remove users by directly manipulating the `users.nix` configuration file.

## How it Works

1. **Config Location:** The script identifies your primary configuration directory, checking `/etc/prism` (global) or `~/.config/prism` (user-level) to locate the `users.nix` file.
2. **Guided Wizard (`gum`):** Using the `gum` toolkit, it provides a polished interface for:
    - **Listing:** Greps the configuration file to show currently defined Prism users.
    - **Adding:** Collects username, full name, password, and a **Profile Type** (e.g., `dev`, `gamer`, `pentester`). It then injects a pre-formatted Nix block into the configuration.
    - **Removing:** Identifies user blocks via specific comment markers (`# --- USER: name ---`) and uses `sed` to cleanly excise the entire block.
3. **Declarative Integrity:** All changes are made to the `.nix` source files. To make the changes "real" on the system, the script offers to trigger a `nixos-rebuild switch` immediately after editing the file.

## Key Features

- **Profile Integration:** When adding a user, you can assign a `profileType`. This triggers specific package sets or configurations (e.g., a `gamer` profile might auto-enable Steam and MangoHud).
- **Safety Markers:** The script uses comment markers to track where a user's configuration starts and ends, ensuring that deletions are precise and don't "leak" into other parts of the system config.
- **Automation:** It handles group assignments (like `wheel` for sudo access and `networkmanager`) automatically for every new Prism user.

## Usage

Run the command in a terminal to launch the wizard:

```
prism-users
```

## Actions available

| Action | Description |
| :--- | :--- |
| List Users | Displays all users currently managed in users.nix. |
| Add User | Guides you through creating a new account with profile selection. |
| Remove User | Lets you pick a user to delete and scrubs their block from the config. |
