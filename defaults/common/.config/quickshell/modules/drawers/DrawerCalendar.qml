import QtQuick.Layouts
import QtQuick
import "../../components/containers/"
import "../../components/bar/"
import "../../config/"

Drawer {
    edge: Qt.TopEdge
    triggerPath: "/tmp/prism-drawer-calendar"

    // containerPadding * 4 because
    // - margins are containerPadding * 1.5, so * 3 by default
    // - the spacing is containerPadding, so total of * 4
    drawerWidth: Style.calendarWidth + Style.calendarClockWidth + Style.containerPadding * 5 + Style.gaugeContainerSize
    // drawerHeight: Style.calendarHeight + Style.calendarClockHeight + Style.containerPadding * 4
    drawerHeight: Style.calendarClockHeight + Style.containerPadding * 3

    GridLayout {
        columns: 3
        rows: 1
        columnSpacing: Style.containerPadding
        rowSpacing: Style.containerPadding
        ClockExtended {}
        Calendar {}
        SystemWidget {}
    }
}
