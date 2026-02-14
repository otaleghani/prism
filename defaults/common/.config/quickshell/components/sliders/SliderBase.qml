import QtQuick
import QtQuick.Controls
import "../../config/"

Slider {
    id: control

    implicitWidth: Style.sliderBarWidth
    implicitHeight: Style.sliderBarHeight + Style.sliderKnobSize

    focus: true
    stepSize: 5
    // snapMode: Slider.SnapAlways

    // Background
    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2

        implicitWidth: Style.sliderBarWidth
        implicitHeight: Style.sliderBarHeight
        width: control.availableWidth
        height: implicitHeight
        radius: Style.sliderBarRadius
        color: Style.surface

        // The "Active" Fill (Progress Bar)
        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: Style.accent
            radius: Style.sliderBarRadius
        }
    }

    // Knob
    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2

        implicitWidth: Style.sliderKnobSize
        implicitHeight: Style.sliderKnobSize
        radius: Style.sliderKnobRadius

        color: control.pressed ? Qt.darker(Style.accent, 1.2) : (control.activeFocus ? Style.accent : Style.fg)

        // Add a small shadow/border for better visibility
        border.color: control.activeFocus ? Style.fg : "transparent"
        border.width: 2

        Behavior on border.width {
            NumberAnimation {
                duration: 100
            }
        }
        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }
    }
}
