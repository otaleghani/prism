import QtQuick
import QtQuick.Layouts
import "../../logic"
import "../../config/"
import "../../components/containers/"

OverlayRectangle {
    id: root

    implicitWidth: Style.calendarClockWidth
    implicitHeight: Style.calendarClockHeight

    ColumnLayout {
        id: clockLayout
        spacing: 2
        anchors.centerIn: parent

        Text {
            text: Qt.formatTime(ClockLogic.currentTime, "hh:mm")
            color: Style.accent
            font: Style.textXlBold
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: Qt.formatDate(new Date(), "dddd, MMMM d")
            color: Style.fgDim
            font: Style.textMdBold
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
