import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "../../components/containers/"
import "../../components/sliders/"
import "../../components/buttons/"
import "../../config/"

Drawer {
    id: root
    edge: Qt.BottomEdge
    triggerPath: "/tmp/prism-drawer-volume"
    initialFocus: masterSlider

    drawerWidth: mainLayout.implicitWidth + (Style.containerPadding * 4)
    drawerHeight: mainLayout.implicitHeight + (Style.containerPadding * 4)

    // Track default sink for Master Volume
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    // --- HELPER FUNCTIONS ---

    function getAppIcon(props) {
        if (!props)
            return "";
        const name = (props["application.name"] || "").toLowerCase();

        if (name.includes("spotify"))
            return "";
        if (name.includes("firefox") || name.includes("chrome") || name.includes("brave"))
            return "";
        if (name.includes("discord") || name.includes("vesktop"))
            return "";
        if (name.includes("steam"))
            return "";
        if (name.includes("vlc") || name.includes("mpv"))
            return "";
        return "";
    }

    function getAppName(props) {
        if (!props)
            return "Unknown";
        // Application name is preferred, fall back to node description
        return props["application.name"] || props["node.description"] || "Audio Stream";
    }

    ColumnLayout {
        id: mainLayout
        anchors.centerIn: parent
        spacing: 15

        // ==========================================================
        //  MASTER VOLUME
        // ==========================================================
        OverlayRectangle {
            implicitWidth: masterVolume.implicitWidth + Style.spacingLg * 2
            implicitHeight: masterVolume.implicitHeight + Style.spacingLg * 2

            property var sink: Pipewire.defaultAudioSink
            property var audio: sink?.audio
            property int vol: audio ? Math.round(audio.volume * 100) : 0
            property bool muted: audio ? audio.muted : true

            Column {
                id: masterVolume
                spacing: 5
                anchors.centerIn: parent

                SliderHeader {
                    label: "Master Volume"
                    quantity: parent.parent.muted ? "󰝟" : parent.parent.vol + "%"
                }

                SliderBase {
                    id: masterSlider
                    from: 0
                    to: 100
                    value: pressed ? value : parent.parent.vol
                    onMoved: if (parent.parent.audio)
                        parent.parent.audio.volume = value / 100
                }
            }
        }

        // ==========================================================
        //  OUTPUT DEVICES (SINKS)
        // ==========================================================
        OverlayRectangle {
            // Hide entire section if no output devices found (unlikely)
            visible: outputRepeater.count > 0

            implicitWidth: outputDevices.implicitWidth + Style.spacingLg * 2
            implicitHeight: outputDevices.implicitHeight + Style.spacingLg * 2

            Column {
                id: outputDevices
                anchors.centerIn: parent
                spacing: 5

                SliderHeader {
                    label: "Output Devices"
                    quantity: ""
                }

                Repeater {
                    id: outputRepeater
                    model: Pipewire.nodes

                    delegate: BaseButton {
                        // FIX: Explicitly get modelData
                        required property var modelData
                        property var node: modelData
                        property var props: node.properties

                        // Filter: Must be 'Audio/Sink'
                        // We use "visible" instead of Loader to ensure scope is simple.
                        // If visible is false, height is 0, effectively hiding it.
                        readonly property bool isSink: props && props["media.class"] === "Audio/Sink"

                        visible: isSink
                        implicitHeight: isSink ? 30 : 0
                        implicitWidth: isSink ? Style.sliderBarWidth : 0
                        opacity: (Pipewire.defaultAudioSink === node) ? 1.0 : 0.5

                        text: props ? (props["node.description"] || "Output") : "Unknown"

                        onClicked: {
                            if (node)
                                Pipewire.defaultAudioSink = node;
                        }
                    }
                }
            }
        }

        // ==========================================================
        //  APPLICATIONS (STREAMS)
        // ==========================================================
        OverlayRectangle {
            // Hide section if no apps are playing audio
            // Note: We can't easily count visible items in Repeater, so we leave it visible
            // or we could bind this to a counter if needed.

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
                    model: Pipewire.nodes

                    delegate: Column {
                        id: appDelegate
                        // Component.onCompleted: {
                        //     if (isApp) {
                        //         console.debug("APP FOUND:", props["application.name"]);
                        //         console.debug(" - Description:", props["node.description"]);
                        //         console.debug(" - Media Name:", props["media.name"]);
                        //         console.debug(" - Binary:", props["application.process.binary"]);
                        //         console.debug("", props);
                        //     }
                        // }
                        required property var modelData
                        property var node: modelData
                        property var props: node.properties

                        // Filter: Must be 'Stream/Output/Audio'
                        readonly property bool isApp: props && props["media.class"] === "Stream/Output/Audio"

                        visible: isApp
                        // Collapse layout if not an app
                        width: isApp ? Style.sliderBarWidth : 0
                        height: isApp ? implicitHeight : 0
                        spacing: 5

                        // IMPORTANT: Track this specific app node so volume updates live
                        PwObjectTracker {
                            objects: [node]
                        }

                        property var audio: node.audio
                        property int vol: audio ? Math.round(audio.volume * 100) : 0

                        // Only render children if visible to save resources
                        SliderHeader {
                            visible: parent.visible
                            label: root.getAppIcon(parent.props) + "  " + root.getAppName(parent.props)
                            quantity: parent.vol + "%"
                        }

                        SliderBase {
                            visible: parent.visible
                            from: 0
                            to: 100
                            value: pressed ? value : parent.vol
                            onMoved: if (parent.audio)
                                parent.audio.volume = value / 100
                        }
                    }
                }
            }
        }
    }
}
