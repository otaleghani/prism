import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "../buttons"
import "../../config"

ButtonRectangle {
    id: root

    // This tells Quickshell to actively monitor the default sink.
    // Without this, the 'sink' property below stays null or unbound.
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property var sink: Pipewire.defaultAudioSink
    property var audio: root.sink?.audio

    // Calculate volume: If audio exists, multiply by 100. Else 0.
    readonly property int volumeInt: root.audio ? Math.round(root.audio.volume * 100) : 0

    // Check mute: If audio exists, read state. Else true (muted/safe).
    readonly property bool isMuted: root.audio ? root.audio.muted : true

    property bool showText: false

    Timer {
        id: hideTimer
        interval: 1000
        repeat: false
        onTriggered: root.showText = false
    }

    // Dim if muted OR if Pipewire is not ready
    opacity: (root.isMuted || !root.sink) ? 0.6 : 1.0

    Behavior on opacity {
        NumberAnimation {
            duration: 150
        }
    }

    ButtonText {
        text: {
            if (!root.sink)
                return "";

            // B. Show Percentage
            if (root.showText && !root.isMuted)
                return root.volumeInt;

            // C. Show Icon based on volume levels
            if (root.isMuted || root.volumeInt == 0)
                return "";
            if (root.volumeInt >= 60)
                return "";
            if (root.volumeInt >= 30)
                return "";
            return "";
        }

        color: root.showText ? Style.accent : ((root.isMuted === true) ? Style.fgDimmer : Style.fg)
    }

    ButtonMouseArea {
        id: mouseArea

        property int accDelta: 0
        readonly property int threshold: 120

        onClicked: {
            // Guard: Check if audio object is valid
            if (root.audio) {
                root.audio.muted = !root.audio.muted;

                // Show text if unmuting
                if (!root.audio.muted) {
                    root.showText = true;
                    hideTimer.restart();
                }
            }
        }

        onWheel: wheel => {
            if (!root.audio)
                return;

            mouseArea.accDelta += wheel.angleDelta.y;

            if (Math.abs(mouseArea.accDelta) >= mouseArea.threshold) {
                var up = mouseArea.accDelta > 0;
                var step = 0.01; // 5% step

                // Calculate new volume
                var newVol = root.audio.volume + (up ? step : -step);

                // Set volume (Clamp between 0.0 and 1.5 if you want boost, or 1.0 for standard)
                root.audio.volume = Math.min(1.0, Math.max(0.0, newVol));

                // Auto-unmute on volume up
                if (root.isMuted && up)
                    root.audio.muted = false;

                root.showText = true;
                hideTimer.restart();

                mouseArea.accDelta = 0;
            }
        }
    }
}
