pragma Singleton

import Quickshell.Io
import QtQuick
import "../config"

Item {
    id: root

    property string triggerPath: "/tmp/prism-sidebar"
    readonly property int size: internal.isOpen ? Bar.openSize : Bar.closeSize
    readonly property bool isOpen: internal.isOpen

    FileView {
        path: root.triggerPath !== "" ? root.triggerPath : ""
        watchChanges: true
        onFileChanged: {
            if (root.triggerPath !== "") {
                internal.toggle();
                reload(); // Reset file watch
            }
        }
    }

    QtObject {
        id: internal
        property bool isOpen: true

        function open() {
            internal.isOpen = true;
            closeTimer.stop();
        }

        function close() {
            internal.isOpen = false;
            closeTimer.restart();
        }

        function toggle() {
            if (internal.isOpen)
                close();
            else
                open();
        }
    }

    Timer {
        id: closeTimer
        interval: 300
        onTriggered: internal.isOpen = false
    }
}
