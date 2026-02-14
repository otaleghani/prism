import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import "../../components/containers/"
import "../../components/sliders/"
import "../../components/buttons/"
import "../../config/"

Drawer {
    id: root
    edge: Qt.BottomEdge
    triggerPath: "/tmp/prism-drawer-volume"
    initialFocus: masterSlider

    // Dynamic Height: Grows to fit the number of apps open
    // We add some padding to ensure it doesn't look cramped
    // drawerWidth: Style.sliderBarWidth + Style.spacingLg + (Style.containerPadding * 4)
    drawerWidth: mainLayout.implicitWidth + (Style.containerPadding * 4)
    drawerHeight: mainLayout.implicitHeight + (Style.containerPadding * 4)

    // Data Models (Persistent State)
    // We use ListModel so we can update specific rows without destroying the whole list
    ListModel {
        id: appModel
    }
    ListModel {
        id: sinkModel
    }

    // Master state is simple enough to be a property
    property var masterState: ({
            vol: 0,
            muted: false
        })

    Process {
        id: audioListener
        command: ["prism-audio-mixer", "listen"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                var clean = data.trim();
                if (clean === "")
                    return;
                try {
                    var json = JSON.parse(clean);

                    // Update Master
                    root.masterState = json.master;

                    // Update Sinks (Outputs)
                    root.syncModel(sinkModel, json.sinks);

                    // Update Apps (Inputs)
                    root.syncModel(appModel, json.apps);
                } catch (e) {
                    console.error("Audio Parse Error: " + e);
                }
            }
        }
    }

    Process {
        id: audioSetter
        command: ["prism-audio-mixer", "set-master", "50"]
    }

    // Helper Functions
    function setAudio(cmd, arg1, arg2) {
        var args = ["prism-audio-mixer", cmd, arg1];
        if (arg2 !== undefined)
            args.push(arg2);

        audioSetter.command = args;
        audioSetter.running = false;
        audioSetter.running = true;
    }

    function syncModel(model, newData) {
        // Update existing items & Add new ones
        for (var i = 0; i < newData.length; i++) {
            var item = newData[i];
            var found = false;

            for (var j = 0; j < model.count; j++) {
                if (model.get(j).id === item.id) {
                    // Update only changed properties to keep UI alive
                    model.set(j, item);
                    found = true;
                    break;
                }
            }
            if (!found)
                model.append(item);
        }

        // Remove items that no longer exist
        for (var k = model.count - 1; k >= 0; k--) {
            var currentId = model.get(k).id;
            var exists = false;
            for (var m = 0; m < newData.length; m++) {
                if (newData[m].id === currentId) {
                    exists = true;
                    break;
                }
            }
            if (!exists)
                model.remove(k);
        }
    }

    ColumnLayout {
        id: mainLayout
        anchors.centerIn: parent
        spacing: 15

        // Master volume
        OverlayRectangle {
            implicitWidth: masterVolume.implicitWidth + Style.spacingLg * 2
            implicitHeight: masterVolume.implicitHeight + Style.spacingLg * 2

            Column {
                id: masterVolume
                spacing: 5
                anchors.centerIn: parent

                SliderHeader {
                    label: "Master Volume"
                    quantity: root.masterState.muted ? "󰝟" : root.masterState.vol + "%"
                }

                SliderBase {
                    id: masterSlider
                    from: 0
                    to: 100
                    // Use a check to allow dragging without fighting updates
                    value: pressed ? value : root.masterState.vol

                    onMoved: root.setAudio("set-master", Math.round(value).toString())
                }
            }
        }

        // Output device picker
        OverlayRectangle {
            implicitWidth: outputDevices.implicitWidth + Style.spacingLg * 2
            implicitHeight: outputDevices.implicitHeight + Style.spacingLg * 2
            Column {
                id: outputDevices
                anchors.centerIn: parent
                spacing: 5

                SliderHeader {
                    label: "Output devices"
                    quantity: ""
                }

                Repeater {
                    model: sinkModel
                    delegate: BaseButton {
                        id: delegateRoot

                        required property bool is_default
                        required property string name
                        required property string desc

                        onClicked: setAudio("set-default", delegateRoot.name)
                        text: desc
                        implicitWidth: Style.sliderBarWidth
                    }
                }
            }
        }

        // Application List
        OverlayRectangle {
            // Only show if we actually have apps playing audio
            visible: appModel.count > 0
            implicitWidth: applications.implicitWidth + Style.spacingLg * 2
            implicitHeight: applications.implicitHeight + Style.spacingLg * 2
            Column {
                id: applications

                spacing: Style.spacingSm
                anchors.centerIn: parent

                SliderHeader {
                    label: "Applications"
                    quantity: ""
                }

                Repeater {
                    model: appModel
                    delegate: Column {
                        id: delegateApp
                        width: parent.width
                        spacing: 5

                        required property string icon
                        required property string name
                        required property string vol
                        required property string id

                        SliderHeader {
                            // Access ListModel roles directly
                            label: (delegateApp.icon || "") + "  " + delegateApp.name
                            quantity: delegateApp.vol + "%"
                        }

                        SliderBase {
                            from: 0
                            to: 100
                            // Key Fix: If user is dragging (pressed), ignore updates
                            value: pressed ? value : delegateApp.vol

                            onMoved: setAudio("set-volume", delegateApp.id, Math.round(value).toString())
                        }
                    }
                }
            }
        }
    }
}
