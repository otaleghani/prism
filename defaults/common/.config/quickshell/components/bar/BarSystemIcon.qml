import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../../config/"
import "../buttons/"
import "../containers"

OverlayRectangle {
    id: root

    // Hide the entire container if no standard workspaces exist (rare, but good practice)
    visible: layout.children.length > 0

    implicitWidth: layout.implicitWidth + Style.barWorkspacePadding
    implicitHeight: layout.implicitHeight + Style.barWorkspacePadding

    ColumnLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 5

        ButtonRectangle {
            id: workspace

            // Collapse space if hidden
            Layout.preferredHeight: implicitHeight
            Layout.preferredWidth: implicitWidth

            statusActive: false
            statusHovered: mouseArea.containsMouse

            ButtonText {
                text: "󱄅"
            }

            Process {
                id: proc
            }

            ButtonMouseArea {
                id: mouseArea
                onClicked: {
                    proc.command = ["prism-apps"];
                    proc.running = false;
                    proc.running = true;
                }
            }
        }
    }
}
