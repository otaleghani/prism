pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    // This property holds the list for the entire app session
    property var wallpapers: []
    property bool isLoading: true

    // The process runs ONLY once when the app starts
    property var listProcess: Process {
        command: ["prism-wallpaper-list"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                var clean = data.trim();
                if (clean === "")
                    return;
                try {
                    root.wallpapers = JSON.parse(clean);
                    root.isLoading = false;
                } catch (e) {
                    console.error("Wallpaper Parse Error: " + e);
                }
            }
        }
    }

    // Helper to force a refresh if you add new wallpapers manually
    function refresh() {
        root.isLoading = true;
        listProcess.running = false;
        listProcess.running = true;
    }
}
