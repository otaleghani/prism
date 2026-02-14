import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../config/"
import "../../logic/"
import "../containers/"
import "../buttons/"

OverlayRectangle {
    id: root

    implicitWidth: Bar.openSize - Style.barWorkspacePadding * 2
    implicitHeight: layout.implicitHeight + Style.barWorkspacePadding

    Process {
        id: launcher
        command: ["touch", "/tmp/prism-drawer-calendar"]
    }

    ButtonMouseArea {
        onClicked: {
            launcher.running = true;
        }
    }

    ColumnLayout {
        id: layout
        anchors.centerIn: parent
        spacing: -2

        // Hours (Bold)
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatTime(ClockLogic.currentTime, "hh")
            color: Style.fg
            font: Style.textSmBold
        }

        // Minutes (Regular)
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatTime(ClockLogic.currentTime, "mm")
            color: Style.fg
            font: Style.textSmNormal
        }
    }
}
