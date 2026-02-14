import QtQuick
import Quickshell.Io
import "../buttons"

ButtonRectangle {
    statusHovered: mouseArea.containsMouse

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    ButtonText {
        text: ""
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
            proc.command = ["touch", "/tmp/prism-session"];
            proc.running = false;
            proc.running = true;
        }
    }
}
