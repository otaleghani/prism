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
        text: root.connected ? "" : "󰤮"
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
            proc.command = ["prism-wifi"];
            proc.running = false;
            proc.running = true;
        }
    }
}
