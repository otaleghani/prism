//@pragma UseQApplication
import Quickshell
import QtQuick
import "./components/notifications"
import "./modules"
import "./modules/drawers"

ShellRoot {
    Bar {}
    WindowFrame {}
    DrawerCalendar {}
    DrawerBrightness {}
    DrawerVolume {}
    DrawerWallpaper {}
    DrawerThemes {}
    NotificationPopup {}
    NotificationCenter {}
    SessionScreen {}
}
