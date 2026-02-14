pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property var themes: []
    property bool isLoading: true

    property var listProcess: Process {
        command: ["prism-theme-list"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                var clean = data.trim();
                if (clean === "")
                    return;
                try {
                    root.themes = JSON.parse(clean);
                    root.isLoading = false;
                } catch (e) {
                    console.error("Theme Parse Error: " + e);
                }
            }
        }
    }

    function refresh() {
        root.isLoading = true;
        listProcess.running = false;
        listProcess.running = true;
    }
}
