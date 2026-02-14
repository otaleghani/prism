import QtQuick
import Quickshell.Io
import "../buttons"
import "../../config"

ButtonRectangle {
    id: root
    statusHovered: mouseArea.containsMouse
    property bool connected: false

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    ButtonText {
        text: ""
        color: root.connected ? Style.fg : Style.fgDimmer
    }

    HoverHandler {
        id: hoverHandler
    }

    Process {
        id: proc
    }

    ButtonMouseArea {
        id: mouseArea
        onClicked: {
            proc.command = ["prism-bluetooth"];
            proc.running = false;
            proc.running = true;
        }
    }
}
