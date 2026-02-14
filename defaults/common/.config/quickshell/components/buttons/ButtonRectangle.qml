import QtQuick
import "../../config/"

Rectangle {
    property bool statusActive: false
    property bool statusHovered: false
    property bool disableBg: false

    color: {
        if (statusActive) {
            return Style.btnBgActive;
        }
        if (statusHovered) {
            return Style.btnBgHovered;
        }
        if (disableBg) {
            return "transparent";
        }
        return Style.btnBg; // Default fallback
    }

    radius: Style.btnRadius
    implicitWidth: Style.btnSize
    implicitHeight: Style.btnSize

    Behavior on color {
        ColorAnimation {
            duration: 50
            easing.type: Easing.InOutQuad
        }
    }
}
