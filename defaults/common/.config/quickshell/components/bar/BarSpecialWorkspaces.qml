import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../../config/"
import "../buttons/"
import "../containers"

OverlayRectangle {
    id: root

    implicitWidth: layout.implicitWidth + Style.barWorkspacePadding
    implicitHeight: layout.implicitHeight + Style.barWorkspacePadding

    ColumnLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 5

        Repeater {
            // 1. STATIC MODEL: Define exactly what you want to see
            model: [
                {
                    id: 99,
                    icon: "",
                    name: "Music"
                },
                {
                    id: 98,
                    icon: "",
                    name: "Chat"
                },
                {
                    id: 97,
                    icon: "",
                    name: "AI"
                },
                {
                    id: -99,
                    icon: "",
                    name: "Special"
                } // -99 is the standard Scratchpad ID
            ]

            ButtonRectangle {
                id: workspaceButton

                // Get data from the static model
                required property var modelData
                property int wsId: modelData.id
                property string icon: modelData.icon

                // 2. CHECK STATUS
                // Active: Is this the workspace we are currently looking at?
                property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId

                // Occupied: Does this workspace actually contain windows right now?
                // We check if this ID exists in the live Hyprland.workspaces list
                property bool isOccupied: {
                    for (let i = 0; i < Hyprland.workspaces.values.length; i++) {
                        if (Hyprland.workspaces.values[i].id === wsId)
                            return true;
                    }
                    return false;
                }

                // 3. VISUAL STATES
                // - Active: Bright/Accent
                // - Occupied: Normal
                // - Empty: Dimmed (Opacity 0.5)
                statusActive: isActive
                statusHovered: mouseArea.containsMouse

                opacity: (isActive || isOccupied || mouseArea.containsMouse) ? 1.0 : 0.4

                ButtonText {
                    text: parent.icon
                    statusActive: parent.isActive
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 16
                }

                ButtonMouseArea {
                    id: mouseArea
                    onClicked: {
                        if (parent.wsId === -99) {
                            // Special handling for Scratchpad
                            Hyprland.dispatch("togglespecialworkspace");
                        } else {
                            // Normal switch for 99, 98, etc.
                            Hyprland.dispatch(`workspace ${parent.wsId}`);
                        }
                    }
                }

                // Optional: Tooltip to show name (Music, Chat, etc.)
                // You can add your Tooltip component here if you have one
            }
        }
    }
}
