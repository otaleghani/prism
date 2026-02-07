pragma Singleton
import QtQuick

QtObject {
    property color background: "#191724"
    property color foreground: "#e0def4"
    property color surface: "#1f1d2e"
    property color overlay: "#26233a"
    property color accent: "#c4a7e7"
    property color urgent: "#eb6f92"
    property color success: "#31748f"

    property font fontFace: Qt.font({
        family: "JetBrainsMono Nerd Font",
        pixelSize: 12
    })
}
