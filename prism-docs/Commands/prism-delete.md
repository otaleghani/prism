# `prism-delete`

An interactive command-line utility for uninstalling packages from the current user's environment. It is designed specifically for packages installed "imperatively" via `nix profile` or [[prism-install]], rather than those defined declaratively in the system configuration. It provides a searchable, multi-select interface to easily identify and remove software.

## How it works

1. **Package Discovery:** It queries the Nix package manager (`nix profile list --json`) to retrieve a list of all currently installed packages in the user's profile.
2. **Parsing:** It uses `jq` to parse the JSON output, extracting the internal index number and the readable package name from the store path.
3. **Selection Interface:** The list is piped into `fzf` (Fuzzy Finder), presenting a reverse-layout list where users can type to search and use `TAB` to select multiple packages at once.
4. **Execution:** Once the selection is confirmed, the script extracts the index numbers and passes them to `nix profile remove`, uninstalling the selected software.

## Dependencies

- `fzf`: Provides the interactive fuzzy-search interface.
- `jq`: Parses the JSON output from Nix.
- `gawk`: Used for text processing to isolate package indices.
- `nix`: The underlying package manager.

## Usage 
Run the command in a terminal to start the interactive selection process.

```bash
prism-delete
```

**Keybindings (within the interface)**

- **Type:** Filter the list.
- **`TAB`:** Select/Deselect a package (Multi-select).
- **`Enter`:** Confirm removal of selected packages.
- **`ESC` / `Ctrl+C`:** Cancel.

> [!Info] Note
> This tool only lists packages installed _imperatively_ (via `nix profile install` or similar). It will not list or remove packages that are "baked" into the system configuration (`configuration.nix`), as those are read-only from the user's perspective.
