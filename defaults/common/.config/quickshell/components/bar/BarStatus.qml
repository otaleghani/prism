import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../config"

ColumnLayout {
    spacing: Style.spacingSm

    // DATA SOURCE
    Process {
        id: sysProcess
        command: ["prism-system-status"]
        running: true

        property var state: ({
                wifi: {
                    connected: false,
                    ssid: ""
                },
                bluetooth: {
                    on: false,
                    connected: false
                },
                profile: "balanced"
            })

        stdout: SplitParser {
            onRead: data => {
                var clean = data.trim();
                if (!clean)
                    return;
                try {
                    sysProcess.state = JSON.parse(clean);
                } catch (e) {}
            }
        }
    }

    BarWifiIcon {
        connected: sysProcess.state.wifi.connected
    }
    BarBluetoothIcon {
        connected: sysProcess.state.bluetooth.connected
    }
    BarPowerProfiles {
        profile: sysProcess.state.profile
    }
    BarUpdates {}
    BarNotifications {}
    BarVolume {}
}
