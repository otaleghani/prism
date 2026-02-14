# `prism-music`

A unified launcher script for accessing popular music streaming services via their web interfaces. Similar to [[prism-ai]] and [[prism-chat]], this script acts as a convenience wrapper, allowing users to launch specific music platforms by name while ensuring they open with consistent window titles and URLs through the [[prism-focus-webapp]] utility.

## How it works

1. **Input Validation:** The script checks for a required argument (the service name). If the argument is missing or does not match a supported service, it displays usage instructions and exits.
2. **Service Mapping:** It maps the provided service keyword (e.g., "spotify") to the specific web URL and a clean window title for that platform.
3. **Execution:** It delegates the actual window creation and URL loading to `prism-focus-webapp` using `exec`, replacing the current shell process.

## Dependencies

- `prism-focus-webapp`: A helper script (internal to Prism) responsible for managing the actual browser window or web app instance.

## Usage

```bash
prism-music <service>
```

## Supported Services

The following keys are accepted as the `<service>` argument:

|**Service Key**|**Platform Name**|**Target URL**|
|---|---|---|
|`spotify`|Spotify|`https://open.spotify.com` (Note: Uses a specific redirect/wrapper URL)|
|`youtube-music`|YouTube Music|`https://music.youtube.com`|
|`apple-music`|Apple Music|`https://music.apple.com`|
|`soundcloud`|SoundCloud|`https://soundcloud.com`|
|`deezer`|Deezer|`https://www.deezer.com`|

## Example

To launch Spotify:

```bash
prism-music spotify
```