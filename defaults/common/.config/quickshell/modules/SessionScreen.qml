pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../config"
import "../components/containers/"
import "../components/bar/"

Floating {
    id: root

    triggerPath: "/tmp/prism-session"
    panelWidth: (Style.sessionBtnSize * 5) + (Style.sessionBtnSpacing * 4) + (Style.containerPadding * 3)
    panelHeight: (Style.sessionBtnSize * 3) + (Style.containerPadding * 5)

    // Auto-focus so keyboard works immediately
    initialFocus: sessionList

    Process {
        id: sessionCmd
        command: ["prism-session", ""]
    }

    function runAction(action) {
        if (!action)
            return;

        sessionCmd.command = ["prism-session", action];
        sessionCmd.running = false;
        sessionCmd.running = true;

        if (action !== "lock")
            root.close();
    }

    ListModel {
        id: actionsModel

        //  Shutdown |  Reboot |  Lock |  Suspend |  Logout
        ListElement {
            name: "Shutdown"
            icon: ""
            action: "shutdown"
        }
        ListElement {
            name: "Reboot"
            icon: ""
            action: "reboot"
        }
        ListElement {
            name: "Lock"
            icon: ""
            action: "lock"
        }
        ListElement {
            name: "Suspend"
            icon: ""
            action: "suspend"
        }
        ListElement {
            name: "Logout"
            icon: ""
            action: "logout"
        }
    }

    // CONTENT
    ColumnLayout {
        anchors.centerIn: parent
        spacing: Style.spacingLg

        // Time widget
        ClockExtended {
            implicitWidth: Style.sessionBtnSize * 5 + (Style.sessionBtnSpacing * 4)
            implicitHeight: Style.sessionBtnSize * 2
        }

        // Action list
        ListView {
            id: sessionList

            Layout.preferredWidth: (Style.sessionBtnSize * 5) + (Style.sessionBtnSpacing * 4)
            Layout.preferredHeight: Style.sessionBtnSize

            orientation: ListView.Horizontal
            spacing: Style.sessionBtnSpacing

            focus: true
            keyNavigationWraps: true

            Component.onCompleted: currentIndex = 2

            model: actionsModel

            // KEYBOARD FIX:
            // Access the model data of the currently highlighted index
            Keys.onReturnPressed: {
                let currentData = model.get(currentIndex);
                root.runAction(currentData.action);
            }
            Keys.onEnterPressed: {
                let currentData = model.get(currentIndex);
                root.runAction(currentData.action);
            }
            Keys.onSpacePressed: {
                let currentData = model.get(currentIndex);
                root.runAction(currentData.action);
            }
            Keys.onEscapePressed: root.close()

            // Start at "Lock" (Middle)
            Component.onCompleted: currentIndex = 2

            // Keyboard Activation
            // Keys.onReturnPressed: root.runAction(model.action)
            // Keys.onEnterPressed: root.runAction(model.action)
            // Keys.onSpacePressed: root.runAction(model.action)
            // Keys.onEscapePressed: root.close()

            delegate: Rectangle {
                id: btn
                width: Style.sessionBtnSize
                height: Style.sessionBtnSize
                radius: Style.sessionBtnRadius

                required property string name
                required property string icon
                required property string action
                required property int index
                // required property string color

                // State
                property bool isSelected: ListView.isCurrentItem
                property bool isHovered: hoverHandler.hovered

                // Style Logic
                color: (isHovered || isSelected) ? Style.accent : Style.overlayBg
                scale: (isHovered || isSelected) ? 1.05 : 1.0
                border.width: (isHovered || isSelected) ? 2 : 0
                border.color: Style.bg

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        sessionList.currentIndex = index;
                        // MOUSE FIX: Use the 'action' property directly from the delegate
                        root.runAction(action);
                    }
                }

                // MouseArea {
                //     anchors.fill: parent
                //     onClicked: {
                //         sessionList.currentIndex = index;
                //         root.runAction(btn.action);
                //     }
                // }

                // Animations
                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutBack
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Style.sessionBtnSpacing

                    Text {
                        text: btn.icon
                        font: Style.textLgNormal
                        color: (btn.isHovered || btn.isSelected) ? Style.bg : Style.fg
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: btn.name
                        font: Style.textSmNormal
                        color: (btn.isHovered || btn.isSelected) ? Style.bg : Style.fg
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                HoverHandler {
                    id: hoverHandler
                }
            }
        }
    }
}
