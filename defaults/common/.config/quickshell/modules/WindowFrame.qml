import Quickshell
// import Quickshell.Io
import QtQuick
import "../components/containers/"
import "../config"
import "../logic/"
import "../animations/"

ShellRoot {
    id: root

    property color fillColor: Style.containerBackground
    property color strokeColor: Style.containerBorderColor
    property int pad: Style.containerPadding
    property int border: Style.containerBorderWidth
    property int marginFrame: BarLogic.size
    Behavior on marginFrame {
        BarAnimation {}
    }

    // qmllint disable uncreatable-type
    PanelWindow {
        id: leftFrame
        width: root.pad
        height: Screen.height
        color: "transparent"
        exclusionMode: ExclusionMode.Auto

        anchors {
            top: true
            bottom: true
            left: true
        }

        Rectangle {
            id: leftFrameRect
            anchors.fill: parent
            color: root.fillColor
            // Border
            Rectangle {
                width: root.border
                height: parent.height - Style.containerPadding * 2
                color: root.strokeColor
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    PanelWindow {
        id: topFrame

        width: Screen.width
        height: root.pad
        color: "transparent"
        exclusionMode: ExclusionMode.Auto

        anchors {
            top: true
            left: true
            right: true
        }

        Rectangle {
            id: topFrameRect
            anchors.fill: parent
            color: root.fillColor
            // Border
            Rectangle {
                width: parent.width - Style.containerPadding
                // width: root.sizeOpen
                height: root.border
                color: root.strokeColor
                anchors.bottom: parent.bottom
                // anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // Right frame has been moved to modules/Bar.qml
    PanelWindow {
        id: rightFrame

        implicitWidth: root.pad
        implicitHeight: Screen.height
        color: "transparent"
        exclusionMode: ExclusionMode.Auto

        anchors {
            top: true
            right: true
            bottom: true
        }

        Rectangle {
            id: rightFrameRect
            anchors.fill: parent
            color: root.fillColor
            // Border
            Rectangle {
                width: root.border
                height: parent.height - Style.containerPadding
                color: root.strokeColor
                anchors.left: parent.left
                // anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    PanelWindow {
        id: bottomFrame

        implicitWidth: Screen.width
        implicitHeight: root.pad
        color: "transparent"
        exclusionMode: ExclusionMode.Auto

        anchors {
            left: true
            right: true
            bottom: true
        }

        Rectangle {
            id: bottomFrameRect
            anchors.fill: parent
            color: root.fillColor
            // Border
            Rectangle {
                width: parent.width
                height: root.border
                color: root.strokeColor
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    FrameCorner {
        corner: 0
        radius: 24
        padX: root.pad - root.border
        padY: root.pad - root.border
        borderWidth: root.border
        fillColor: root.fillColor
        strokeColor: root.strokeColor
    }
    FrameCorner {
        corner: 1
        radius: 24
        padX: root.pad - root.border
        padY: root.pad - root.border
        marginX: marginFrame
        borderWidth: root.border
        fillColor: root.fillColor
        strokeColor: root.strokeColor
    }
    FrameCorner {
        corner: 2
        radius: 24
        padX: root.pad - root.border
        padY: root.pad - root.border
        borderWidth: root.border
        fillColor: root.fillColor
        strokeColor: root.strokeColor
    }
    FrameCorner {
        corner: 3
        radius: 24
        padX: root.pad - root.border
        padY: root.pad - root.border
        marginX: marginFrame
        borderWidth: root.border
        fillColor: root.fillColor
        strokeColor: root.strokeColor
    }
}
