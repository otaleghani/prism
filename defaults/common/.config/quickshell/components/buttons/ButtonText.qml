import QtQuick
import "../../config/"

Text {
    property bool statusActive: false
    property bool statusHovered: false

    color: {
        if (statusActive) {
            return Style.btnTextActive;
        }
        if (statusHovered) {
            return Style.btnTextHovered;
        }
        return Style.btnText; // Default fallback
    }

    anchors.centerIn: parent

    font: Style.btnTextFont
}
