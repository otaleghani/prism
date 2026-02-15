# `prism-api-test`

A lightweight, TUI-based API client designed for rapid backend testing. It replaces the need for heavy GUI applications like Postman or Insomnia for common tasks. It wraps `curlie`—a modern alternative to `curl`—to provide beautifully formatted, colorized JSON responses directly in a floating Prism terminal.

## How it works

1. **Request Builder:** Uses `gum` to guide you through a three-step wizard:
    - **Method:** Choose between GET, POST, PUT, DELETE, or PATCH.
    - **URL:** Input the target endpoint.
    - **Body:** If the method isn't GET, it opens a multi-line text buffer for you to type or paste your JSON payload.
2. **Execution:** It pipes the data to `curlie`, which handles the HTTP handshake and formats the output.
3. **Output Persistence:** The window stays open after the request completes, allowing you to inspect headers and response bodies before closing.

## Usage

```bash
prism-api-test
```