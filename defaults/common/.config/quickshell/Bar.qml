import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "./components"

PanelWindow {
    anchors {
        top: true
        bottom: true
        right: true
    }

    width: 60
    exclusionMode: ExclusionMode.Exclusive
    color: "transparent"

    // Process for the session button
    Process {
        id: sessionProc
        command: ["prism-session"]
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 5
        
        // Styling from Theme Singleton
        color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.85)
        border.width: 1
        border.color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.1)
        radius: 16

        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 15
            anchors.bottomMargin: 15
            spacing: 15

            // --- TOP: Workspaces ---
            Workspaces {
                Layout.alignment: Qt.AlignHCenter
            }
            
            // Spacer ( pushes content apart )
            Item { Layout.fillHeight: true }

            // --- MIDDLE: Clock (Placeholder for now) ---
            Text {
                text: ""
                color: Theme.foreground
                font: Theme.fontFace
                Layout.alignment: Qt.AlignHCenter
            }

            // Spacer
            Item { Layout.fillHeight: true }

            // --- BOTTOM: System Info ---
            // We will add the BottomGroup here later
            Rectangle {
                width: 40; height: 40
                radius: 20
                color: Theme.surface
                Layout.alignment: Qt.AlignHCenter
                
                Text {
                   anchors.centerIn: parent
                   text: "⏻"
                   color: Theme.urgent
                   font: Theme.fontFace
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: sessionProc.running = true
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }
}
