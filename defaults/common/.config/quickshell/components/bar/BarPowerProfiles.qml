import QtQuick
import Quickshell.Io
import "../buttons"

ButtonRectangle {
    id: root
    statusHovered: mouseArea.containsMouse
    property string profile: ""

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    ButtonText {
        text: {
            switch (root.profile) {
            case "performance":
                return "";
            case "power-saver":
                return "";
            default:
                return "";
            }
        }
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
            proc.command = ["prism-power"];
            proc.running = false;
            proc.running = true;
        }
    }
}
