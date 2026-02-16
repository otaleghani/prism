The Developer profile is designed for those who spend their lives in the terminal. It isn't just a collection of languages; it is a workflow that automates the "boring" parts of coding, like environment setup, project scaffolding, and API testing.

## Key features

The Developer profile adds specific commands to your `PATH` that leverage Prism’s automation logic.

### `prism-project`

This is the "Project orchestrator". It leverages the power of nix reproducibility to handle developer environments using nix flakes.

- **`prism-project-new`**: Creates a new project directory based on your local templates (found in `~/.local/share/prism/templates`). It initializes Git and sets up the basic flake structure where you can define dependencies and pin those with a `flake.lock`.
- **`prism-project-open`**: Opens a fuzzy-finder to let you jump into any project directory and launch your preferred editor instantly.

###  `prism-api-test`

A lightweight wrapper around `curl` and `jq`. It allows you to quickly test an endpoint directly from the terminal with formatted output, making it easier than opening a heavy GUI like Postman.