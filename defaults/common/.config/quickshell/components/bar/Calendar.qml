import QtQuick
import QtQuick.Layouts
import "../../config/"
import "../containers/"
import "../buttons/"
import "../../logic/"

OverlayRectangle {
    id: calendarRoot

    property alias defaultFocusItem: prevButton

    function grabFocus() {
        prevButton.forceActiveFocus();
    }

    CalendarLogic {
        id: logic
    }

    implicitWidth: (Style.btnSize + Style.spacingSm) * 7 + Style.spacingMd * 2 // 7 cols in total
    implicitHeight: (Style.btnSize + Style.spacingSm) * 8 + Style.spacingMd * 2 // 8 rows in total

    ColumnLayout {
        id: mainLayout
        anchors.centerIn: parent
        spacing: Style.spacingMd

        // Header
        RowLayout {
            spacing: Style.spacingSm

            Rectangle {
                implicitWidth: title.implicitWidth + Style.spacingMd
                implicitHeight: title.implicitHeight + Style.spacingMd
                color: Style.surface
                radius: Style.overlayRadius

                Text {
                    id: title
                    anchors.centerIn: parent
                    text: Qt.formatDate(logic.viewDate, "MMMM yyyy")
                    color: Style.fg
                    font: Style.textSmNormal
                }
            }

            Item {
                Layout.fillWidth: true
            }

            BaseButton {
                id: prevButton
                onClicked: logic.prevMonth()
                focus: true
                text: ""
                KeyNavigation.right: nextButton
                KeyNavigation.left: todayButton
            }

            BaseButton {
                id: nextButton
                onClicked: logic.nextMonth()
                text: ""
                KeyNavigation.right: todayButton
                KeyNavigation.left: prevButton
            }

            BaseButton {
                id: todayButton
                onClicked: logic.thisMonth()
                text: "󰃶"
                KeyNavigation.right: prevButton
                KeyNavigation.left: nextButton
            }
        }

        // Calendar Grid
        GridLayout {
            id: calendarLayout
            columns: 7
            columnSpacing: Style.spacingSm
            rowSpacing: Style.spacingSm
            Layout.fillWidth: true

            // Day Names (Mon, Tue...)
            Repeater {
                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                Text {
                    required property var modelData
                    text: modelData
                    color: Style.fgDim
                    font: Style.textSmBold
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            // Days of the month
            Repeater {
                model: logic.currentDays

                Rectangle {
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    width: Style.btnSize
                    height: Style.btnSize
                    radius: Style.btnRadius
                    // Highlight "Today"
                    color: modelData.isToday ? Style.accent : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: parent.modelData.day
                        color: parent.modelData.isToday ? Style.bg : parent.modelData.neighborhoodDay ? Style.fgDimmest : Style.fg
                        font: Style.textSmNormal
                        opacity: parent.modelData.day === "" ? 0 : 1
                    }
                }
            }
        }
    }
}
