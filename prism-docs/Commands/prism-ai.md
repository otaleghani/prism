# `prism-ai`

A unified launcher script for accessing various popular AI web services. It serves as a convenience wrapper that streamlines the process of opening specific AI platforms by name, ensuring consistent window titling and URL handling via the underlying `prism-focus-webapp` utility.

## How it works

1. **Input Validation:** The script checks for a required argument (the service name). If missing or invalid, it prints usage instructions and exits.
2. **Service Mapping:** It matches the provided service name (e.g., "gemini") to its corresponding official URL and a clean display title.
3. **Execution:** It hands off the execution to `prism-focus-webapp` using `exec`, replacing the current shell process with the web app instance.

## Dependencies

- `prism-focus-webapp`: A helper script responsible for managing the actual browser window.

## Usage

```bash
prism-ai <service>
```

## Supported Services 

The following keys are accepted as the `<service>` argument:

|**Service Key**|**Platform Name**|**Target URL**|
|---|---|---|
|`chatgpt`|ChatGPT|`https://chatgpt.com`|
|`claude`|Claude|`https://claude.ai`|
|`gemini`|Gemini|`https://gemini.google.com`|
|`deepseek`|DeepSeek|`https://chat.deepseek.com`|
|`perplexity`|Perplexity|`https://www.perplexity.ai`|

## Example 

To launch Google Gemini:
``` bash
prism-ai gemini
```
