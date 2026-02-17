pragma Singleton
import QtQuick

QtObject {
    property color background: "#FFFCF0"
    property color foreground: "#100F0F"
    property color surface: "#F2F0E5"
    property color overlay: "#E6E4D9"
    property color accent: "#24837B"
    property color urgent: "#AF3029"
    property color success: "#66800B"

    property font fontFace: Qt.font({
        family: "JetBrainsMono Nerd Font",
        pixelSize: 12
    })
}
