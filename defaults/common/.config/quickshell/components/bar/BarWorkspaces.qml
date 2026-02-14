import Quickshell.Hyprland
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

        Repeater {
            model: Hyprland.workspaces

            ButtonRectangle {
                id: workspace
                required property var modelData
                property int wsId: modelData.id

                // FILTER LOGIC
                // Only show if ID is between 1 and 9
                readonly property bool isStandard: wsId >= 1 && wsId <= 9
                visible: isStandard

                // Collapse space if hidden
                Layout.preferredHeight: isStandard ? implicitHeight : 0
                Layout.preferredWidth: isStandard ? implicitWidth : 0

                // EXISTING LOGIC
                property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
                statusActive: isActive
                statusHovered: mouseArea.containsMouse

                ButtonText {
                    text: parent.wsId
                    statusActive: parent.isActive
                }

                ButtonMouseArea {
                    id: mouseArea
                    onClicked: Hyprland.dispatch(`workspace ${parent.wsId}`)
                }
            }
        }
    }
}
