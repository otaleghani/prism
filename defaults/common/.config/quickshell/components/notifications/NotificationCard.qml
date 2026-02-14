import QtQuick
import QtQuick.Layouts
import "../../config"

Rectangle {
    id: card

    // 1. SIGNAL: Let the parent know we want to close this
    signal closed

    implicitWidth: container.implicitWidth + Style.spacingMd
    implicitHeight: container.implicitHeight + Style.spacingMd
    color: "transparent"

    // Inputs
    property string summary: "Notification"
    property string body: ""
    property var icon: ""
    property string appName: "System"

    // Animation: Slide In
    Component.onCompleted: {
        x = 50;
        opacity = 0;
        animIn.start();
    }

    ParallelAnimation {
        id: animIn
        NumberAnimation {
            target: card
            property: "opacity"
            to: 1.0
            duration: 150
        }
        NumberAnimation {
            target: card
            property: "x"
            to: 0
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        id: container

        anchors.centerIn: parent
        // Dynamic height based on text content
        implicitHeight: Math.max(Style.notifContainerHeight, content.implicitHeight + Style.spacingMd * 2)
        implicitWidth: Style.notifContainerWidth

        color: Style.containerBackground
        radius: Style.containerRadius
        border.color: Style.containerBorderColor
        border.width: Style.containerBorderWidth

        RowLayout {
            id: content
            anchors.fill: parent
            anchors.margins: Style.spacingMd
            spacing: Style.spacingMd

            // Image
            Item {
                Layout.preferredWidth: Style.notifImageSize
                Layout.preferredHeight: Style.notifImageSize
                Layout.alignment: Qt.AlignTop

                // Logic: Is the image actually valid and loaded?
                readonly property bool imageValid: imgIcon.status === Image.Ready && card.icon !== ""

                // Fallback
                Text {
                    anchors.centerIn: parent
                    visible: !parent.imageValid // Show only if image failed/empty

                    text: "" //  (Bell) or  (Question) or  (Info)
                    font.family: "JetBrainsMono Nerd Font" // Ensure Nerd Font
                    font.pixelSize: Style.notifImageSize * 0.8 // Scale nicely
                    color: Style.fgDimmer
                }

                // Image
                Image {
                    id: imgIcon
                    anchors.fill: parent
                    visible: parent.imageValid // Hide if it fails

                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: true

                    source: {
                        var iconStr = card.icon ? card.icon.toString() : "";

                        // If empty, return empty (so status stays Null/Error and Text shows)
                        if (iconStr === "")
                            return "";

                        // Handle Paths vs System Names
                        if (iconStr.indexOf("/") === 0)
                            return "file://" + iconStr;
                        return "image://icon/" + iconStr;
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 2

                // Header (App Name)
                Text {
                    text: card.appName
                    font: Style.textSmBold
                    color: Style.fgDimmer // Slightly dimmer than title
                    // font.pixelSize: 11
                    Layout.fillWidth: true
                }

                // Summary (Title)
                Text {
                    text: card.summary
                    color: Style.fg
                    font: Style.textSmBold
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                // Body
                Text {
                    id: bodyText
                    text: card.body
                    font: Style.textSmNormal
                    color: Style.fgDimmer
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    visible: card.body.length > 0
                }
            }

            // CLOSE BUTTON
            Rectangle {
                Layout.alignment: Qt.AlignTop | Qt.AlignRight
                width: 24
                height: 24
                radius: 12
                // Visual feedback on hover
                color: closeMs.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "" // Font Awesome / Nerd Font X
                    color: Style.fg
                    font: Style.textSmNormal
                }

                MouseArea {
                    id: closeMs
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    // Emit the signal when clicked
                    onClicked: card.closed()
                }
            }
        }
    }
}
