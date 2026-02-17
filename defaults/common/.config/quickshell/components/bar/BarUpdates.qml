import QtQuick
import Quickshell.Io
import "../buttons"
import "../../config"

ButtonRectangle {
    id: root

    // FIX: Use hoverHandler.hovered instead of mouseArea.containsMouse
    // This avoids the "null" error because hoverHandler initializes earlier/differently
    statusHovered: hoverHandler.hovered

    property string statusIcon: "..."
    property bool updateAvailable: false
    property bool isUnstable: false

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    ButtonText {
        text: root.statusIcon
        color: (root.updateAvailable || root.isUnstable) ? Style.fg : Style.fgDimmer
    }

    HoverHandler {
        id: hoverHandler
    }

    // --- Checker Process ---
    Process {
        id: checkProc
        command: ["prism-update-check"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                const result = data.trim();
                if (result === "")
                    return;

                root.statusIcon = result;
                root.updateAvailable = (result === "󰚰");
                root.isUnstable = (result === "");
            }
        }
    }

    // Updater process
    Process {
        id: proc
    }

    ButtonMouseArea {
        id: mouseArea
        onClicked: {
            proc.command = ["prism-tui", "prism-update"];
            proc.running = false;
            proc.running = true;
        }
    }
}
