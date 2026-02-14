pragma Singleton

import QtQuick

Item {
    id: root

    // Timer logic
    property var currentTime: new Date()
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.currentTime = new Date()
    }
}
