pragma Singleton
import QtQuick

QtObject {
    property color background: "#272e33"
    property color foreground: "#d3c6aa"
    property color surface: "#374145"
    property color overlay: "#414b50"
    property color accent: "#a7c080"
    property color urgent: "#e67e80"
    property color success: "#83c092"

    property font fontFace: Qt.font({
        family: "JetBrainsMono Nerd Font",
        pixelSize: 12
    })
}
