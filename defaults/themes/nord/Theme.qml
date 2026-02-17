pragma Singleton
import QtQuick

QtObject {
    property color background: "#2e3440"
    property color foreground: "#d8dee9"
    property color surface: "#3b4252"
    property color overlay: "#4c566a"
    property color accent: "#88c0d0"
    property color urgent: "#bf616a"
    property color success: "#a3be8c"

    property font fontFace: Qt.font({
        family: "JetBrainsMono Nerd Font",
        pixelSize: 12
    })
}
