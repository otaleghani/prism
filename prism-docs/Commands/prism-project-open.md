# `prism-project-open`

A quick-access launcher for existing projects. It allows users to jump into a development environment without manually navigating directories or typing shell commands.

## How it works

1. **Project Scanning:** Indexes the first-level directories within `~/Workspace`.
2. **Selection UI:** Displays the list of projects in a `rofi` menu for fuzzy searching.
3. **Environment Launch:** Once a project is selected, the script:
    - Identifies the project's full path.
    - Automatically attempts to launch a new terminal (preferring **Ghostty**, then **Kitty**).
    - Executes `nix develop` inside that terminal, dropping the user directly into the project's pre-configured development shell.

## Usage 

```bash
prism-project-open
```