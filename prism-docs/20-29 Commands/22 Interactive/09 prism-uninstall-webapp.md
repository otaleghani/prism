# `prism-uninstall-webapp`

A cleanup utility designed to safely remove the web applications created by Prism. It provides a visual checklist of all installed web apps, allowing for bulk removal of both the launch entries and their associated icons.

## How it works

1. **Smart Discovery:** Scans your local applications folder and filters for files that contain the `prism-focus-webapp` command. This ensures it only lists apps created through Prism, protecting your system-installed software (like Firefox or Discord) from accidental deletion.
2. **Multi-Select UI:** Uses `gum choose` to present a list of detected apps. You can use the `Space` bar to select multiple apps and `Enter` to confirm.
3. **Logic:**
    - Deletes the `.desktop` file.
    - Deletes the cached icon from the Prism icon directory.
4. **Feedback:** Provides a summary of the removed applications to the terminal.

## Usage

```bash
prism-uninstall-webapp
```