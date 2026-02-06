import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    // 1. Positioning
    anchors {
        top: true
        bottom: true
        right: true
    }

    // 2. Geometry
    // Width includes the bar + the gap
    width: 60 
    height: Screen.height

    // 3. Layer Shell behavior
    // Exclusive: Pushes windows aside
    // Overlay: Floats above windows
    exclusionMode: ExclusionMode.Exclusive
    
    // Transparent window background so the gap is invisible
    color: "transparent"

    // 4. The Visible Bar
    Rectangle {
        id: background
        
        // This creates the "Gap" effect
        // We fill the window but leave 10px margin on all sides
        anchors.fill: parent
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.rightMargin: 10
        anchors.leftMargin: 5 

        // Style (Glassmorphism placeholder)
        color: "#cc1e1e2e" // Semi-transparent base
        radius: 20
        border.width: 1
        border.color: "#30cba6f7" // Subtle border

        // Content Container
        Column {
            anchors.centerIn: parent
            spacing: 15
            
            // Placeholder Icon (Distro Logo)
            Text { 
                text: "" 
                color: "#cba6f7"
                font.pixelSize: 24
                font.family: "JetBrainsMono Nerd Font"
            }
            
            // Spacer to push content
            Item { height: 20; width: 1 }

            // Placeholder Workspaces
            Repeater {
                model: 5
                Rectangle {
                    width: 8; height: 8
                    radius: 4
                    color: "white"
                    opacity: 0.5
                }
            }
        }
    }
}
