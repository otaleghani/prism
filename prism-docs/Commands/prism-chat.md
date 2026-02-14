# `prism-chat`

A unified launcher script for accessing popular messaging and chat platforms via their web interfaces. Similar to [[prism-ai]], this script acts as a convenience wrapper, allowing users to launch specific chat applications by name while ensuring they open with consistent window titles and URLs through the [[prism-focus-webapp]] utility.

## How it works

1. **Input Validation:** The script checks for a required argument (the service name). If the argument is missing or does not match a supported service, it displays usage instructions and exits.
2. **Service Mapping:** It maps the provided service keyword (e.g., "discord") to the specific web URL and a clean window title for that platform.
3. **Execution:** It delegates the actual window creation and URL loading to `prism-focus-webapp` using `exec`, replacing the current shell process.

## Dependencies

- `prism-focus-webapp`: A helper script responsible for managing the actual browser window.

## Usage

```bash
prism-chat <service>
```

## Supported Services 

The following keys are accepted as the `<service>` argument:

|**Service Key**|**Platform Name**|**Target URL**|
|---|---|---|
|`whatsapp`|WhatsApp|`https://web.whatsapp.com`|
|`telegram`|Telegram|`https://web.telegram.org/k/`|
|`discord`|Discord|`https://discord.com/app`|
|`slack`|Slack|`https://app.slack.com/client`|
|`messenger`|Messenger|`https://www.messenger.com`|

## Example

To launch Discord:

```bash
prism-chat discord
```