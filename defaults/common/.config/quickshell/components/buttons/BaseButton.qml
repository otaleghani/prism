import QtQuick
import QtQuick.Controls
import "../../config/"

Button {
    id: control

    implicitHeight: Style.btnSize
    implicitWidth: Style.btnSize

    // Standard Keyboard Interaction
    Keys.onReturnPressed: clicked()
    Keys.onEnterPressed: clicked()
    Keys.onSpacePressed: clicked()

    contentItem: ButtonText {
        text: control.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        statusActive: (control.activeFocus || control.hovered) ? true : false
        elide: Text.ElideRight
    }

    background: ButtonRectangle {
        statusActive: control.activeFocus
        statusHovered: control.hovered
    }
}
