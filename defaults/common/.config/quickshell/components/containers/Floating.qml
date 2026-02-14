// qmllint disable unresolved-type
// qmllint disable unqualified
// qmllint disable missing-property
// qmllint disable uncreatable-type
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../../config"
import "../../animations"

Item {
    id: root

    // Content alias
    default property alias content: contentLayout.data

    // Configuration
    property int panelWidth: 400
    property int panelHeight: 300
    property string triggerPath: ""

    // Focused item when opened
    property Item initialFocus: null

    // API
    function open() {
        internal.open();
    }
    function close() {
        internal.close();
    }
    function toggle() {
        internal.toggle();
    }

    // --- LOGIC ---

    // 1. Focus Grabber (Hyprland specific)
    HyprlandFocusGrab {
        id: grab
        active: false
        windows: [panelWindow]
        onCleared: internal.close()
    }

    // 2. Internal State
    QtObject {
        id: internal
        property bool isOpen: false

        function open() {
            grab.active = true;
            isOpen = true;
            focusTimer.restart();
        }

        function close() {
            grab.active = false;
            isOpen = false;
        }

        function toggle() {
            if (isOpen)
                close();
            else
                open();
        }
    }

    // 3. Focus Timer
    Timer {
        id: focusTimer
        interval: 100
        onTriggered: {
            if (internal.isOpen && root.initialFocus)
                root.initialFocus.forceActiveFocus();
        }
    }

    // 4. TRIGGER (The Better Way)
    FileView {
        path: root.triggerPath !== "" ? root.triggerPath : ""
        watchChanges: true
        onFileChanged: {
            if (root.triggerPath !== "") {
                internal.toggle();
                // If you need to reload content, you can emit a signal here
            }
        }
    }

    // --- WINDOW ---

    PanelWindow {
        id: panelWindow
        visible: true // Always visible, we control opacity/mask

        // Fill the screen so we can dim the background
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        // INPUT MASK
        // When Open: Cover screen (block clicks).
        // When Closed: Empty (let clicks pass through to desktop).
        mask: Region {
            width: internal.isOpen ? panelWindow.width : 0
            height: internal.isOpen ? panelWindow.height : 0
        }

        // --- KEYBOARD SHORTCUTS ---
        Shortcut {
            sequence: "Escape"
            enabled: internal.isOpen
            onActivated: internal.close()
        }

        // --- BACKGROUND DIMMER ---
        Rectangle {
            id: dimmer
            anchors.fill: parent
            color: "#80000000" // 50% Black dim

            // Animation: Fade in/out
            opacity: internal.isOpen ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            // Click outside to close
            MouseArea {
                anchors.fill: parent
                enabled: internal.isOpen
                onClicked: internal.close()
            }
        }

        // --- THE PANEL CONTAINER ---
        Item {
            id: panelFrame
            width: root.panelWidth
            height: root.panelHeight
            anchors.centerIn: parent

            // Animation: Scale Up + Fade In
            transformOrigin: Item.Center
            scale: internal.isOpen ? 1 : 0.95
            opacity: internal.isOpen ? 1 : 0

            Behavior on scale {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutBack
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            // The Visual Box
            Rectangle {
                anchors.fill: parent

                color: Style.containerBackground
                radius: Style.containerRadius
                border.width: Style.containerBorderWidth
                border.color: Style.containerBorderColor

                // Block clicks from hitting the dimmer (so clicking the panel doesn't close it)
                MouseArea {
                    anchors.fill: parent
                }

                // Content Holder
                FocusScope {
                    id: contentScope
                    anchors.fill: parent

                    Rectangle {
                        id: contentLayout
                        anchors.fill: parent
                        anchors.margins: Style.containerPadding
                        color: "transparent"
                    }
                }
            }
        }
    }
}
