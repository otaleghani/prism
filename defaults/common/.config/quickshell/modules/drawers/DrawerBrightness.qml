import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import "../../components/containers/"
import "../../components/sliders/"
import "../../config/"

Drawer {
    edge: Qt.BottomEdge
    triggerPath: "/tmp/prism-drawer-brightness"
    initialFocus: brightSlider
    drawerWidth: mainLayout.implicitWidth + Style.containerPadding * 3
    drawerHeight: mainLayout.implicitHeight + Style.containerPadding * 3

    Process {
        id: brightnessListener
        command: ["prism-brightness", "listen"]
        running: true

        property int percent: 0
        property string icon: ""

        // Use SplitParser to handle the stream line-by-line
        stdout: SplitParser {
            onRead: data => {
                // 'data' is a single line (String) from the script
                try {
                    var cleanData = data.trim();
                    if (cleanData === "")
                        return;

                    var json = JSON.parse(cleanData);
                    brightnessListener.percent = json.percent;
                    brightnessListener.icon = json.icon;
                } catch (e) {
                    console.error("Brightness Parse Error: " + e);
                }
            }
        }
    }

    Process {
        id: brightnessSetter
        command: ["prism-brightness", "set", "50"]
    }

    ColumnLayout {
        id: mainLayout
        anchors.centerIn: parent
        OverlayRectangle {
            implicitWidth: contentLayout.implicitWidth + Style.spacingLg
            implicitHeight: contentLayout.implicitHeight + Style.spacingLg
            Column {
                id: contentLayout
                anchors.centerIn: parent
                spacing: 10

                SliderHeader {
                    label: "Brightness"
                    quantity: brightnessListener.percent + "%"
                }

                SliderBase {
                    id: brightSlider
                    value: brightnessListener.percent
                    from: 0
                    to: 100
                    onMoved: {
                        brightnessSetter.command = ["prism-brightness", "set", Math.round(value).toString()];
                        brightnessSetter.running = false;
                        brightnessSetter.running = true;
                    }
                }
            }
        }
    }
}
