pragma Singleton
import QtQuick

QtObject {
    property color background: "#222436"
    property color foreground: "#c8d3f5"
    property color surface: "#2d3f76"
    property color overlay: "#444a73"
    property color accent: "#82aaff"
    property color urgent: "#ff757f"
    property color success: "#c3e88d"

    property font fontFace: Qt.font({
        family: "JetBrainsMono Nerd Font",
        pixelSize: 12
    })
}
