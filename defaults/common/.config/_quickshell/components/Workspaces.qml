import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import ".." // Import root to access Theme
import "../theme"

ColumnLayout {
    spacing: 5

    // Store workspace data
    property var workspaces: []

    // Run the prism-workspaces script
    Process {
        id: proc
        command: ["prism-workspaces"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                try {
                    workspaces = JSON.parse(data);
                } catch (e) {
                    console.log("Error parsing JSON:", e);
                }
            }
        }
    }

    Repeater {
        model: workspaces

        Rectangle {
            // Data from the model (the JSON object)
            readonly property var ws: modelData

            width: 30
            height: 30
            radius: 8

            // Active vs Inactive Color
            color: ws.active ? Theme.accent : Theme.surface

            // Animation for color change
            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }

            Text {
                anchors.centerIn: parent
                text: ws.id
                color: ws.active ? Theme.background : Theme.foreground
                font: Theme.fontFace
            }

            // Click Handler
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var p = Quickshell.process("hyprctl", ["dispatch", "workspace", ws.id]);
                }
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
}
