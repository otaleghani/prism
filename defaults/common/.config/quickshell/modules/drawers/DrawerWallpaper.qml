pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import "../../config"
import "../../logic"
import "../../components/containers"

Drawer {
    id: root
    edge: Qt.TopEdge
    triggerPath: "/tmp/prism-drawer-wallpapers"
    initialFocus: stripView

    drawerHeight: Style.wallHeight + (Style.spacingLg * 4) + Style.spacingMd
    drawerWidth: Screen.width / 2

    // Simple flat array of objects
    // property var wallpaperList: []

    property var wallpaperList: WallpaperLogic.wallpapers

    Process {
        id: wallSetter
        command: ["prism-wall", "set", ""]
    }

    OverlayRectangle {
        id: container
        anchors.fill: parent

        ColumnLayout {
            id: layout
            anchors.fill: parent
            anchors.margins: Style.spacingMd
            spacing: Style.spacingMd

            Text {
                text: "Wallpapers"
                color: Style.fg
                font: Style.textSmBold
            }

            // The horizontal
            ListView {
                id: stripView
                Layout.fillWidth: true
                Layout.fillHeight: true

                focus: true
                keyNavigationWraps: true
                highlightFollowsCurrentItem: true
                Keys.onReturnPressed: activateCurrent()
                Keys.onEnterPressed: activateCurrent()
                Keys.onSpacePressed: activateCurrent()

                function activateCurrent() {
                    // Check if we have a valid index
                    if (currentIndex < 0 || currentIndex >= model.length) {
                        console.warn("Invalid Index selected: " + currentIndex);
                        return;
                    }

                    var currentData = model[currentIndex];

                    // 2. Validate the data
                    if (!currentData || !currentData.path) {
                        console.error("ERROR: No path found for index " + currentIndex);
                        return;
                    }

                    // 3. Debug Log (Check your terminal!)
                    console.log("Setting Wallpaper: " + currentData.path);

                    // 4. Force Reset the process
                    if (wallSetter.running) {
                        wallSetter.running = false; // Stop it if it's stuck
                    }

                    wallSetter.command = ["prism-wall", "set", currentData.path];
                    wallSetter.running = true;
                }

                // function activateCurrent() {
                //     // Get the data object of the currently selected item
                //     var currentData = stripView.model[stripView.currentIndex];
                //     if (currentData) {
                //         wallSetter.command = ["prism-wall", "set", currentData.path];
                //         // wallSetter.running = false;
                //         wallSetter.running = true;
                //     }
                // }

                orientation: ListView.Horizontal
                spacing: Style.spacingSm
                clip: true

                model: root.wallpaperList

                // Delegate is now just the Card directly
                delegate: Rectangle {
                    id: imgCard

                    // Fixed Aspect Ratio (16:9)
                    width: Style.wallWidth
                    height: Style.wallHeight

                    radius: Style.btnRadius
                    color: "black"
                    clip: true // Rounds the image corners

                    // Visual Selection State
                    border.width: hoverHandler.hovered ? 2 : 0
                    border.color: Style.accent

                    property bool isSelected: ListView.isCurrentItem
                    onIsSelectedChanged: {
                        if (isSelected)
                            stripView.positionViewAtIndex(index, ListView.Contain);
                    }

                    // Explicitly define data to avoid "undefined" errors
                    required property var modelData
                    required property int index

                    Image {
                        anchors.fill: parent
                        source: "file://" + imgCard.modelData.path
                        sourceSize.width: Style.wallWidth
                        sourceSize.height: Style.wallHeight
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        asynchronous: true
                    }

                    HoverHandler {
                        id: hoverHandler
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            wallSetter.command = ["prism-wall", "set", imgCard.modelData.path];
                            wallSetter.running = false;
                            wallSetter.running = true;
                            stripView.currentIndex = index;
                            stripView.activateCurrent();
                        }
                    }

                    // Label Overlay
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: Style.spacingLg * 2
                        color: Style.accent
                        visible: hoverHandler.hovered || imgCard.isSelected

                        Text {
                            anchors.centerIn: parent
                            text: imgCard.modelData.name
                            color: Style.bg
                            font: Style.textSmNormal
                            elide: Text.ElideMiddle
                            width: parent.width - Style.spacingSm
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }
    }
}
