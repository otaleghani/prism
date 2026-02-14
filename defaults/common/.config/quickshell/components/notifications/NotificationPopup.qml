pragma ComponentBehavior: Bound
// qmllint disable uncreatable-type
import QtQuick
import Quickshell
import "../../config"
import "../../logic"

PanelWindow {
    id: root

    anchors.top: true
    anchors.left: true
    width: Style.notifContainerWidth + Style.spacingMd
    implicitHeight: popupList.contentHeight + Style.spacingMd

    color: "transparent"

    Connections {
        target: NotificationsLogic

        function onNotification(notification) {
            popupModel.insert(0, {
                "notificationObject": notification
            });
        }
    }

    ListModel {
        id: popupModel
    }

    ListView {
        id: popupList
        width: parent.width
        height: contentHeight
        model: popupModel
        spacing: -Style.spacingSm
        interactive: false

        delegate: NotificationCard {
            id: card
            width: ListView.view.width

            required property int index
            required property var notificationObject
            readonly property var notif: notificationObject

            summary: notif.summary
            body: notif.body
            appName: notif.appName || "System"
            icon: notif.icon || ""

            function removeNotification() {
                if (index >= 0 && index < popupModel.count) {
                    popupModel.remove(index);
                }
            }

            onClosed: {
                if (notif)
                    notif.tracked = false; // Mark as read in system
                removeNotification();
            }

            Timer {
                interval: 4000 // 4 seconds
                running: true
                repeat: false
                onTriggered: card.removeNotification()
            }

            // Right-click to dismiss immediately
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                z: -1
                onClicked: card.removeNotification()
            }
        }
    }
}
