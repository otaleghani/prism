pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import "../../config"
import "../../components/containers"
import "../../logic/"

Drawer {
    id: root
    edge: Qt.TopEdge
    triggerPath: "/tmp/prism-drawer-themes"
    initialFocus: themeView

    drawerHeight: Style.themeHeight + (Style.spacingLg * 4) + Style.spacingMd
    drawerWidth: Screen.width / 2

    property var themeList: ThemesLogic.themes

    Process {
        id: themeSetter
        command: ["prism-theme", ""]
    }

    OverlayRectangle {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.spacingMd
            spacing: Style.spacingSm

            Text {
                text: "Themes"
                color: Style.fg
                font: Style.textSmBold
            }

            ListView {
                id: themeView
                Layout.fillWidth: true
                Layout.fillHeight: true

                orientation: ListView.Horizontal
                spacing: 20
                clip: true

                focus: true
                keyNavigationWraps: true
                highlightFollowsCurrentItem: true

                model: root.themeList

                function activateCurrent() {
                    // Prevent spamming
                    if (themeSetter.running)
                        return;

                    // Get the object from the JS Array using the current index
                    // We access root.themeList directly to be safe
                    if (currentIndex < 0 || currentIndex >= root.themeList.length)
                        return;

                    var theme = root.themeList[currentIndex];

                    if (theme && theme.name) {
                        console.log("Applying Theme: " + theme.name);
                        themeSetter.command = ["prism-theme", theme.name];
                        themeSetter.running = false;
                        themeSetter.running = true;
                    }
                }

                Keys.onReturnPressed: activateCurrent()
                Keys.onEnterPressed: activateCurrent()
                Keys.onSpacePressed: activateCurrent()

                delegate: Rectangle {
                    id: card
                    width: Style.themeWidth
                    height: Style.themeHeight
                    radius: Style.containerRadius

                    required property var modelData
                    required property int index

                    // SELECTION STATE
                    // It is selected if the Mouse hovers OR if the Keyboard moved to this index
                    property bool isSelected: ListView.isCurrentItem

                    // Style: Base color of the theme
                    color: modelData.colors.base

                    // Border: Shows ACCENT color when Selected/Hovered
                    border.width: (hoverHandler.hovered || isSelected) ? Style.overlayBorderWidth : 0
                    border.color: (hoverHandler.hovered || isSelected) ? modelData.colors.accent : Qt.darker(modelData.colors.surface, 1.2)

                    // Auto-scroll the view to keep the selected item visible
                    onIsSelectedChanged: {
                        if (isSelected)
                            themeView.positionViewAtIndex(index, ListView.Contain);
                    }

                    // VISUAL PREVIEW
                    // "Window" Preview (Surface Color)
                    Rectangle {
                        width: parent.width - 30
                        height: 50
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -10
                        color: card.modelData.colors.surface
                        radius: 6

                        // Tiny "Text" mockups
                        Column {
                            anchors.centerIn: parent
                            spacing: 4
                            Rectangle {
                                width: 80
                                height: 4
                                radius: 2
                                color: card.modelData.colors.text
                                opacity: 0.3
                            }
                            Rectangle {
                                width: 60
                                height: 4
                                radius: 2
                                color: card.modelData.colors.text
                                opacity: 0.3
                            }
                        }
                    }

                    // Theme Name Label
                    Rectangle {
                        color: "transparent"
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: Style.spacingLg + Style.spacingSm

                        Rectangle {
                            anchors.centerIn: parent
                            // anchors.bottom: parent.bottom
                            // anchors.left: parent.left
                            // anchors.right: parent.right
                            width: parent.width - Style.overlayBorderWidth * 4
                            height: Style.spacingLg
                            color: Qt.rgba(0, 0, 0, 0.4)
                            radius: Style.overlayRadius

                            Text {
                                anchors.centerIn: parent
                                text: card.modelData.name
                                color: Style.fg
                                font: Style.textSmBold
                                elide: Text.ElideRight
                            }
                        }
                    }

                    // Hover Handler
                    HoverHandler {
                        id: hoverHandler
                    }

                    // Mouse Click
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // Sync Mouse click to Keyboard selection
                            themeView.currentIndex = index;
                            themeView.activateCurrent();
                        }
                    }
                }
            }
        }
    }
}
