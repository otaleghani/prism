pragma Singleton
import QtQuick

QtObject {
    property color background: "#1d2021"
    property color foreground: "#ebdbb2"
    property color surface: "#3c3836"
    property color overlay: "#504945"
    property color accent: "#fabd2f"
    property color urgent: "#fb4934"
    property color success: "#b8bb26"

    property font fontFace: Qt.font({
        family: "JetBrainsMono Nerd Font",
        pixelSize: 12
    })
}
