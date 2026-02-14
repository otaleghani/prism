// qmllint disable uncreatable-type

import Quickshell
import QtQuick
import QtQuick.Layouts
import "../config"
import "../components/bar/"
import "../components/containers/"
import "../logic/"
import "../animations/"

PanelWindow {
    id: root

    property int sizeOpen: BarLogic.size
    color: Style.containerBackground

    implicitWidth: sizeOpen
    Behavior on implicitWidth {
        BarAnimation {}
    }

    exclusionMode: ExclusionMode.Auto
    anchors.top: true
    anchors.bottom: true
    anchors.right: true

    RowLayout {
        height: root.height
        width: root.width
        spacing: 0

        Rectangle {
            implicitWidth: barContainer.width
            implicitHeight: barContainer.height
            color: Style.containerBackground

            // Bar
            ColumnLayout {
                id: barContainer
                // Layout.fillWidth: true
                // visible: BarLogic.isOpen
                visible: true
                width: root.width - Style.containerPadding
                height: root.height

                Item {
                    id: paddingTop
                    implicitHeight: Style.containerPadding
                }
                GridLayout {
                    // anchors.fill: parent
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    columns: 1
                    rows: 5

                    // Layout.alignment: Qt.AlignHCenter
                    Rectangle {
                        color: "transparent"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.preferredHeight: 0
                        ColumnLayout {
                            BarSystemIcon {}
                            BarWorkspaces {}
                            BarSpecialWorkspaces {}
                        }
                    }
                    Rectangle {
                        color: "transparent"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.preferredHeight: 0
                        BarClock {
                            anchors.centerIn: parent
                        }
                    }

                    Rectangle {
                        color: "transparent"
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.preferredHeight: 0

                        OverlayRectangle {
                            implicitHeight: bottomLayout.implicitHeight + Style.spacingMd
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right

                            ColumnLayout {
                                id: bottomLayout
                                anchors.centerIn: parent

                                BarStatus {
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                BarPower {
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }
                    }
                }
                Item {
                    id: paddingBottom
                    implicitHeight: Style.containerPadding
                }
            }
        }
        Rectangle {
            id: paddingLeft
            color: Style.containerBackground
            implicitWidth: Style.containerPadding
            implicitHeight: Screen.height
        }
    }
}
