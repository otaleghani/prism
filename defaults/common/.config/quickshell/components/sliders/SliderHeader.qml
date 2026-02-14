import QtQuick
import QtQuick.Layouts
import "../../config/"

Rectangle {
    id: root
    property string label: "label"
    property string quantity: "9%"

    implicitWidth: Style.sliderBarWidth
    implicitHeight: Style.sliderHeaderHeight
    color: "transparent"

    RowLayout {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        Text {
            text: root.label
            color: Style.fg
            font: Style.textSmBold
        }
        Item {
            Layout.fillWidth: true
        }
        Text {
            text: root.quantity
            color: Style.fg
            font: Style.textSmBold
        }
    }
}
