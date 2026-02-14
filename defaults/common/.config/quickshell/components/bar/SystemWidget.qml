import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell.Io
import "../../config"
import "../containers/"

OverlayRectangle {
    id: root

    implicitWidth: Style.gaugeContainerSize
    implicitHeight: Style.calendarHeight

    // DATA PROCESS (Same as before)
    Process {
        id: sysProc
        command: ["prism-system-monitor"]
        running: true

        property var stats: ({
                cpu: {
                    usage: 0,
                    temp: 0
                },
                gpu: {
                    usage: 0,
                    temp: 0
                },
                ram: 0,
                disk: 0
            })

        stdout: SplitParser {
            onRead: data => {
                var clean = data.trim();
                if (!clean)
                    return;
                try {
                    sysProc.stats = JSON.parse(clean);
                } catch (e) {}
            }
        }
    }

    // MAIN LAYOUT
    ColumnLayout {
        anchors.centerIn: parent
        spacing: Style.spacingMd

        // Title
        Text {
            text: "System Status"
            color: Style.fgDimmer
            font: Style.textSmBold
            Layout.alignment: Qt.AlignHCenter
        }

        // 2x2 Grid for Gauges
        GridLayout {
            columns: 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            columnSpacing: Style.spacingMd
            rowSpacing: Style.spacingMd

            ResourceGauge {
                icon: ""
                label: "CPU"
                value: sysProc.stats.cpu.usage
                temp: sysProc.stats.cpu.temp
            }

            ResourceGauge {
                icon: "󰢮"
                label: "GPU"
                value: sysProc.stats.gpu.usage
                temp: sysProc.stats.gpu.temp
            }

            ResourceGauge {
                icon: ""
                label: "RAM"
                value: sysProc.stats.ram
            }

            ResourceGauge {
                icon: ""
                label: "Disk"
                value: sysProc.stats.disk
            }
        }
    }

    // REUSABLE GAUGE COMPONENT
    component ResourceGauge: Item {
        id: gaugeRoot

        // Inputs
        property string icon: ""
        property string label: ""
        property int value: 0
        property int temp: 0
        property color accentColor: Style.accent

        // Layout sizing for grid
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: Style.gaugeSize
        Layout.preferredWidth: Style.gaugeSize

        // Internal variables for circle math
        // 270 degree sweep (3/4 circle), starting from bottom-left (135 deg)
        readonly property int startAngle: 135
        readonly property int maxSweep: 270
        readonly property int strokeWidth: Style.gaugeStroke

        // Animate value changes smoothly
        Behavior on value {
            NumberAnimation {
                duration: 600
                easing.type: Easing.OutCubic
            }
        }

        // BACKGROUND TRACK (Gray Arc)
        Shape {
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 4 // Anti-aliasing

            ShapePath {
                fillColor: "transparent"
                strokeColor: Style.fgDimmest
                strokeWidth: gaugeRoot.strokeWidth
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: gaugeRoot.width / 2
                    centerY: gaugeRoot.height / 2
                    // Radius adjusted for stroke width so it doesn't clip
                    radiusX: (gaugeRoot.width / 2) - (gaugeRoot.strokeWidth / 2)
                    radiusY: (gaugeRoot.height / 2) - (gaugeRoot.strokeWidth / 2)
                    startAngle: gaugeRoot.startAngle
                    sweepAngle: gaugeRoot.maxSweep
                }
            }
        }

        // FOREGROUND PROGRESS (Colored arc)
        Shape {
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 4 // Anti-aliasing

            ShapePath {
                fillColor: "transparent"
                strokeColor: Style.accent
                strokeWidth: gaugeRoot.strokeWidth
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: gaugeRoot.width / 2
                    centerY: gaugeRoot.height / 2
                    radiusX: (gaugeRoot.width / 2) - (gaugeRoot.strokeWidth / 2)
                    radiusY: (gaugeRoot.height / 2) - (gaugeRoot.strokeWidth / 2)
                    startAngle: gaugeRoot.startAngle

                    // Math: Calculate sweep based on percentage value
                    // Ensure it doesn't go below 0 or exceed 100 visually
                    sweepAngle: gaugeRoot.maxSweep * (Math.max(0, Math.min(gaugeRoot.value, 100)) / 100)
                }
            }
        }

        // CENTER CONTENT
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 2

            // Icon
            Text {
                text: gaugeRoot.icon
                color: Style.accent
                font: Style.textMdNormal
                Layout.alignment: Qt.AlignHCenter
            }

            // Percentage value
            Text {
                text: gaugeRoot.value + "%"
                color: Style.fg
                font: Style.textSmNormal
                Layout.alignment: Qt.AlignHCenter
            }

            // Label + Temp (Small text at bottom)
            Text {
                // Show temp if > 0, otherwise just label
                text: (gaugeRoot.temp > 0 ? gaugeRoot.temp + "°C" : gaugeRoot.label)
                color: Style.fgDimmer
                font: Style.textXsNormal
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 2
            }
        }
    }
}
