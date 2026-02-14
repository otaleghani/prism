import QtQuick
import Quickshell.Io
import "../buttons"
import "../../config"
import "../../logic" // Import your Singleton file

ButtonRectangle {
    id: root

    Repeater {
        id: notificationCounter
        model: NotificationsLogic.trackedNotifications

        // The delegate is just a placeholder to hold the data
        delegate: Item {
            visible: false
            required property var modelData
            property var notification: modelData
        }
    }

    // Now we just ask the Repeater how many items it has!
    property int count: notificationCounter.count
    property bool hasNotifications: count > 0

    // VISUALS
    statusHovered: mouseArea.containsMouse

    ButtonText {
        text: {
            let res = "";
            if (!root.hasNotifications) {
                res += "";
            } else {
                if (root.count > 9) {
                    res += " 9+";
                } else {
                    res += "";
                    res += root.count.toString();
                }
                // res += "";
            }
            return res;
        }

        color: root.hasNotifications ? Style.fg : Style.fgDimmer

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutBack
            }
        }
        scale: root.hasNotifications ? 1.0 : 1.0
    }

    HoverHandler {
        id: hoverHandler
    }

    // ACTIONS
    Process {
        id: proc
    }

    ButtonMouseArea {
        id: mouseArea
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                // Right Click: Clear All
                // We loop through our Repeater items to find the notifications
                for (var i = 0; i < notificationCounter.count; i++) {
                    var item = notificationCounter.itemAt(i);
                    if (item && item.notification) {
                        // Stop tracking it (removes it from the list)
                        item.notification.tracked = false;
                    }
                }
            } else {
                // Left Click: Open Drawer
                proc.command = ["touch", "/tmp/prism-drawer-notifications"];
                proc.running = false;
                proc.running = true;
            }
        }
    }
}
