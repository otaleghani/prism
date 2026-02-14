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

    // The content inside the drawer
    default property alias content: contentLayout.data

    // Configuration
    property int drawerWidth: 300
    property int drawerHeight: 100
    property string triggerPath: ""

    // Position: Qt.LeftEdge, Qt.RightEdge, Qt.TopEdge, Qt.BottomEdge
    property int edge: Qt.LeftEdge
    property int screenMargin: Style.containerPadding - Style.containerBorderWidth

    // Set this to the button you want focused when it opens
    property Item initialFocus: null

    // Helper booleans for layout logic
    readonly property bool isVertical: edge === Qt.LeftEdge || edge === Qt.RightEdge
    readonly property bool isHorizontal: edge === Qt.TopEdge || edge === Qt.BottomEdge

    function open() {
        internal.open();
    }
    function close() {
        internal.close();
    }
    function toggle() {
        internal.toggle();
    }

    // FOCUS GRABBER
    HyprlandFocusGrab {
        id: grab
        active: false
        windows: [drawerWindow]
        onCleared: internal.close()
    }

    // INTERNAL LOGIC
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

    Timer {
        id: focusTimer
        interval: 100
        onTriggered: {
            if (internal.isOpen && root.initialFocus)
                root.initialFocus.forceActiveFocus();
        }
    }

    // OPEN LOGIC
    FileView {
        path: root.triggerPath !== "" ? root.triggerPath : ""
        watchChanges: true
        onFileChanged: {
            if (root.triggerPath !== "") {
                internal.toggle();
                reload();
            }
        }
    }

    // DRAWER WINDOW — ALWAYS VISIBLE, never toggled
    PanelWindow {
        id: drawerWindow
        visible: true // <-- ALWAYS visible

        implicitWidth: root.drawerWidth
        height: root.drawerHeight

        color: "transparent"

        anchors {
            left: root.edge === Qt.LeftEdge
            right: root.edge === Qt.RightEdge
            top: root.edge === Qt.TopEdge
            bottom: root.edge === Qt.BottomEdge
        }

        margins {
            left: root.edge === Qt.LeftEdge ? root.screenMargin : 0
            right: root.edge === Qt.RightEdge ? root.screenMargin : 0
            top: root.edge === Qt.TopEdge ? root.screenMargin : 0
            bottom: root.edge === Qt.BottomEdge ? root.screenMargin : 0
        }

        exclusionMode: ExclusionMode.Ignore

        // Input mask: only accept input when open, otherwise pass through
        mask: Region {
            x: contentScope.x
            y: contentScope.y
            width: internal.isOpen ? contentScope.width : 0
            height: internal.isOpen ? contentScope.height : 0
        }

        Shortcut {
            sequence: "Escape"
            onActivated: internal.close()
        }
        Shortcut {
            sequence: "q"
            onActivated: internal.close()
        }

        // Slide wrapper
        Item {
            id: drawerFrame
            anchors.fill: parent

            property real slideOffset: internal.isOpen ? 0 : 1

            Behavior on slideOffset {
                DrawerAnimation {}
            }

            opacity: internal.isOpen ? 1 : 0
            Behavior on opacity {
                DrawerAnimation {}
            }

            transform: Translate {
                x: {
                    if (!root.isVertical)
                        return 0;
                    if (root.edge === Qt.LeftEdge)
                        return -root.drawerWidth * drawerFrame.slideOffset;
                    else
                        return root.drawerWidth * drawerFrame.slideOffset;
                }
                y: {
                    if (!root.isHorizontal)
                        return 0;
                    if (root.edge === Qt.TopEdge)
                        return -root.drawerHeight * drawerFrame.slideOffset;
                    else
                        return root.drawerHeight * drawerFrame.slideOffset;
                }
            }

            Rectangle {
                id: drawerContainer
                anchors.fill: parent

                color: Style.containerBackground
                radius: Style.containerRadius
                border.width: Style.containerBorderWidth
                border.color: Style.containerBorderColor

                // Sharp Corner Patch
                Rectangle {
                    color: parent.color
                    width: root.isVertical ? 12 : parent.width
                    height: root.isHorizontal ? 12 : parent.height

                    anchors.left: root.edge === Qt.RightEdge ? undefined : parent.left
                    anchors.right: root.edge === Qt.RightEdge ? parent.right : undefined
                    anchors.top: root.edge === Qt.BottomEdge ? undefined : parent.top
                    anchors.bottom: root.edge === Qt.BottomEdge ? parent.bottom : undefined

                    Rectangle {
                        color: Style.containerBorderColor
                        width: root.isVertical ? parent.width : Style.containerBorderWidth
                        height: root.isVertical ? Style.containerBorderWidth : parent.height
                        anchors.top: root.isVertical ? parent.top : undefined
                        anchors.left: root.isHorizontal ? parent.left : undefined
                    }

                    Rectangle {
                        color: Style.containerBorderColor
                        width: root.isVertical ? parent.width : Style.containerBorderWidth
                        height: root.isVertical ? Style.containerBorderWidth : parent.height
                        anchors.bottom: root.isVertical ? parent.bottom : undefined
                        anchors.right: root.isHorizontal ? parent.right : undefined
                    }
                }

                MouseArea {
                    anchors.fill: parent
                }

                FocusScope {
                    id: contentScope
                    anchors.fill: parent

                    Rectangle {
                        id: contentLayout
                        anchors.fill: parent
                        anchors.margins: Style.containerPadding * 1.5
                        color: "transparent"
                    }
                }
            }
        }
    }
}
