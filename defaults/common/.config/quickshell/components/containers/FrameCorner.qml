import QtQuick
import Quickshell

// InsetCorner.qml
// qmllint disable uncreatable-type
PanelWindow {
    id: window

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    property int corner: 0 // 0:TL, 1:TR, 2:BL, 3:BR
    property int radius: 12
    property int borderWidth: 2
    property color fillColor: "#1e1e2e"
    property color strokeColor: "#585b70"

    // Padding from each edge — set these to match your frame sizes
    property int padX: 0
    property int padY: 0

    // Offsets from the screen edge
    property int marginX: 0
    property int marginY: 0

    // Window is big enough to include padding + radius
    implicitWidth: radius + padX
    implicitHeight: radius + padY

    anchors {
        top: corner === 0 || corner === 1
        bottom: corner === 2 || corner === 3
        left: corner === 0 || corner === 2
        right: corner === 1 || corner === 3
    }

    // qmllint disable unresolved-type
    // qmllint disable unqualified
    // qmllint disable missing-property
    margins {
        top: (corner === 0 || corner === 1) ? marginY : 0
        bottom: (corner === 2 || corner === 3) ? marginY : 0
        left: (corner === 0 || corner === 2) ? marginX : 0
        right: (corner === 1 || corner === 3) ? marginX : 0
    }

    Canvas {
        id: canvas

        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d");
            var r = window.radius;
            var bw = window.borderWidth;
            var px = window.padX;
            var py = window.padY;
            var w = width;
            var h = height;

            ctx.clearRect(0, 0, w, h);
            ctx.reset();
            // Fill regions: padding area (covers frame borders) + concave shape
            ctx.fillStyle = window.fillColor;

            // Determine the arc center offset by padding
            // The arc sits in the inner portion, padding covers frame borders
            var cx, cy, startAngle, endAngle;

            switch (window.corner) {
            case 0: // TL anchor → arc faces bottom-right, padding on left & top
                // Padding fills left strip and top strip
                ctx.fillRect(0, 0, px, h);  // left strip
                ctx.fillRect(0, 0, w, py);  // top strip

                // Arc in bottom-right portion
                cx = w;
                cy = h;
                startAngle = Math.PI;
                endAngle = 1.5 * Math.PI;
                break;
            case 1: // TR anchor → arc faces bottom-left, padding on right & top
                ctx.fillRect(w - px, 0, px, h);  // right strip
                // ctx.fillRect(w - px, 0, 4, h);  // right strip
                ctx.fillRect(0, 0, w, py + 2);        // top strip
                // ctx.fillRect(w - px, 0, px, (h / 2) - bw - 1);  // TEST right strip
                // ctx.fillRect(w - px, 0, 8, h);  // TEST right strip
                // ctx.fillRect(w - px, 0, px-40, h);  // TEST right strip

                cx = 0;
                cy = h;
                startAngle = 1.5 * Math.PI;
                endAngle = 2 * Math.PI;
                break;
            case 2: // BL anchor → arc faces top-right, padding on left & bottom
                ctx.fillRect(0, 0, px, h);        // left strip
                ctx.fillRect(0, h - py, w, py);   // bottom strip

                cx = w;
                cy = 0;
                startAngle = Math.PI / 2;
                endAngle = Math.PI;
                break;
            case 3: // BR anchor → arc faces top-left, padding on right & bottom
                // ctx.fillRect(w - px, 0, 4, h);   // right strip
                ctx.fillRect(w - px, 0, px, h);   // right strip
                ctx.fillRect(0, h - py, w, py);   // bottom strip
                // ctx.fillRect(w - px, 20, px, h);   // TEST right strip
                // ctx.fillRect(w - px, 0, 8, h);  // TEST right strip

                cx = 0;
                cy = 0;
                startAngle = 0;
                endAngle = Math.PI / 2;
                break;
            }

            // Fill the concave square (adjacent to padding)
            // This is the radius x radius area where the arc lives
            var rx = (window.corner === 0 || window.corner === 2) ? px : 0;
            var ry = (window.corner === 0 || window.corner === 1) ? py : 0;
            ctx.fillRect(rx, ry, r, r);

            // Punch out the quarter circle
            ctx.globalCompositeOperation = "destination-out";
            ctx.beginPath();
            ctx.moveTo(cx, cy);
            ctx.arc(cx, cy, r, startAngle, endAngle, false);
            ctx.closePath();
            ctx.fill();

            // Draw the concave arc border
            ctx.globalCompositeOperation = "source-over";
            ctx.strokeStyle = window.strokeColor;
            ctx.lineWidth = bw;
            ctx.beginPath();
            ctx.arc(cx, cy, r - bw / 2, startAngle, endAngle, false);
            ctx.stroke();
        }
    }
}
