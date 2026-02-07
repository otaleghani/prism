pragma Singleton
import QtQuick

QtObject {
    // Default: Catppuccin Mocha (Will be overwritten by prism-theme later)
    property color background: "#1e1e2e"
    property color foreground: "#cdd6f4"
    property color surface: "#313244"
    property color overlay: "#45475a"
    property color accent: "#cba6f7"
    property color urgent: "#f38ba8"
    property color success: "#a6e3a1"
    
    property font fontFace: Qt.font({family: "JetBrainsMono Nerd Font", pixelSize: 12})
}
