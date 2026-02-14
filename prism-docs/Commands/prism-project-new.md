# `prism-project-new

An interactive scaffolding wizard for creating new development projects. It automates the creation of project directories, applies boilerplate Nix templates, and sets up version control.

## How it works

1. **Project Initialization:** Asks the user for a project name and ensures the workspace directory exists (defaults to `~/Workspace`).
2. **Template Selection:** Scans the local template library (`~/.local/share/prism/templates`). It presents the available languages/frameworks to the user via a `gum` selection menu.
3. **Variable Injection:** Copies the template's `flake.nix` to the new project folder and uses `sed` to replace placeholders (like `{{PROJECT_NAME}}`) with the user's chosen name.
4. **Git Integration:** Offers to initialize a Git repository and automatically creates a `.gitignore` pre-configured for Nix (ignoring `.direnv/` and `result`).
5. **Environment Handoff:** Opens the new `flake.nix` in the system's `$EDITOR` and provides instructions on how to enter the development shell.

## Usage

```bash
prism-project-new
```
`