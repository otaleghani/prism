A specialized wrapper for **Lazygit**, the industry-standard terminal interface for Git. This script ensures that version control management is consistent with the Prism "floating utility" philosophy, allowing you to stage, commit, and push changes without losing your place in your main code editor.

## How it works

1. **Context Check:** It first verifies that the current directory is actually a Git repository. If not, it sends a system notification and exits.
2. **Orchestration:** It delegates the launch to `prism-tui`.
3. **Visual Rules:** By using the Prism TUI engine, the window is assigned the `org.prism.lazygit` class. This triggers Hyprland to:
    - Center the window on the screen.
    - Enable floating mode.
    - Apply the active Prism theme colors to the Git interface.

## Usage

```bash
prism-git-tui
```