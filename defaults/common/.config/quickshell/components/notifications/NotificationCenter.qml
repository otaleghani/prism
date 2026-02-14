import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../config"
import "../../components/containers/"
import "../../components/buttons/"
import "../../logic"

Drawer {
    id: root
    edge: Qt.LeftEdge
    triggerPath: "/tmp/prism-drawer-notifications"

    drawerWidth: Style.notifContainerWidth + Style.spacingLg * 4
    drawerHeight: Screen.height - 200

    OverlayRectangle {
        implicitWidth: Style.notifContainerWidth + Style.spacingLg * 2
        implicitHeight: Screen.height - 200 - Style.spacingLg * 2
        ColumnLayout {
            id: container
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // Header
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Notifications"
                    font: Style.textMdBold
                    color: Style.fg
                    Layout.fillWidth: true
                }

                // Clear button
                BaseButton {
                    implicitWidth: 100
                    text: "Clear all"
                    onClicked: {
                        var list = NotificationsLogic.trackedNotifications.values;
                        for (var i = list.length - 1; i >= 0; i--) {
                            list[i].tracked = false;
                        }
                    }
                }
            }

            // --- The List ---
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: -Style.spacingSm

                model: NotificationsLogic.trackedNotifications

                delegate: NotificationCard {
                    width: ListView.view.width

                    // In an ObjectModel, 'modelData' is the actual Notification object
                    required property var modelData

                    summary: modelData.summary
                    body: modelData.body
                    appName: modelData.appName || "System"
                    icon: modelData.icon || ""

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        z: -1
                        // Logic to dismiss single item
                        onClicked: parent.modelData.tracked = false
                    }
                }

                // Empty State
                Text {
                    visible: parent.count === 0
                    text: "No new notifications"
                    font: Style.textSmNormal
                    color: Style.fgDim
                    anchors.centerIn: parent
                }
            }
        }
    }
}
