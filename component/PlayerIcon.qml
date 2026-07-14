import QtQuick
import QtQuick.Shapes

/**
 * Reusable vector icon component using QtQuick.Shapes.
 * Supports common media player icons with customizable color and size.
 * No external dependencies — SVG path data is hand-crafted inline in a 24×24 grid.
 *
 * Uses dual ShapePath approach: fillPath for solid shapes (play, pause, bars),
 * strokePath for line-based shapes (shuffle, chevrons, curves) with round caps/joins.
 *
 * Icon names:
 *   play, pause, skipPrevious, skipNext,
 *   shuffle, repeat,
 *   volumeHigh, volumeMedium, volumeLow, volumeMuted,
 *   chevronLeft, chevronDown, chevronUp,
 *   musicNote, queue, home, search, library
 */
Item {
    id: root

    property string iconName: "play"
    property color color: "#FFFFFF"
    property real iconSize: 24

    implicitWidth: iconSize
    implicitHeight: iconSize

    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }

    // Container scales the 24×24 design grid to iconSize
    Item {
        width: 24
        height: 24
        anchors.centerIn: parent
        scale: root.iconSize / 24

        Shape {
            anchors.fill: parent
            asynchronous: false
            smooth: true

            // Fill-based paths (solid shapes)
            ShapePath {
                id: fillPath
                fillColor: root.color
                strokeColor: "transparent"
                strokeWidth: 0
                joinStyle: ShapePath.RoundJoin

                PathSvg { path: fillSvgPath() }
            }

            // Stroke-based paths (line art, arrows, curves)
            ShapePath {
                id: strokePath
                fillColor: "transparent"
                strokeColor: root.color
                strokeWidth: Math.max(1.5, root.iconSize / 12)
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin

                PathSvg { path: strokeSvgPath() }
            }
        }
    }

    // --- Fill paths (solid shapes with fillColor) ---
    function fillSvgPath() {
        switch (root.iconName) {
            case "play":
                return "M6,3 L18,12 L6,21 Z";
            case "pause":
                return "M6,3 H10 V21 H6 Z M14,3 H18 V21 H14 Z";
            case "skipPrevious":
                return "M4,3 H7 V21 H4 Z M18,3 L8,12 L18,21 Z";
            case "skipNext":
                return "M4,3 L14,12 L4,21 Z M17,3 H20 V21 H17 Z";
            case "volumeHigh":
            case "volumeMedium":
            case "volumeLow":
            case "volumeMuted":
                // Speaker body (shared by all volume icons)
                return "M3,9 H7 L12,4 V20 L7,15 H3 Z";
            case "queue":
                // Play indicator triangle for queue
                return "M17,16 L22,18 L17,20 Z";
            default:
                return "";
        }
    }

    // --- Stroke paths (line art with strokeColor) ---
    function strokeSvgPath() {
        switch (root.iconName) {
            case "shuffle":
                return "M16,3 H21 V8 M21,3 L15,9 M16,21 H21 V16 M21,21 L4,7 M8,17 L4,21";
            case "repeat":
                return "M17,3 C20,5 22,8 22,12 C22,17 18,21 12,21 H8 M4,17 L8,21 L12,17 M7,21 C4,19 2,16 2,12 C2,7 6,3 12,3 H16";
            case "volumeHigh":
                return "M15,7 C17,9 17,15 15,17 M18,4 C21,7 21,17 18,20";
            case "volumeMedium":
                return "M15,7 C17,9 17,15 15,17";
            case "volumeLow":
                return "M15,8 C16,10 16,14 15,16";
            case "volumeMuted":
                return "M17,9 L22,14 M22,9 L17,14";
            case "chevronLeft":
                return "M15,6 L8,12 L15,18";
            case "chevronDown":
                return "M6,9 L12,15 L18,9";
            case "chevronUp":
                return "M6,15 L12,9 L18,15";
            case "musicNote":
                return "M15,4 V15 C15,13.34 13.66,12 12,12 C10.34,12 9,13.34 9,15 C9,16.66 10.34,18 12,18 C12.62,18 13.2,17.8 13.67,17.47 M15,4 L8,5.5 V15 M8,13.5 V15";
            case "queue":
                return "M3,7 H21 M3,13 H18 M3,19 H15";
            case "home":
                return "M12,4 L4,10 V20 H10 V14 H14 V20 H20 V10 Z";
            case "search":
                return "M10,3 C14.42,3 18,6.58 18,11 C18,12.85 17.37,14.55 16.31,15.9 L20,19.59 L18.59,21 L14.9,17.31 C13.55,18.37 11.85,19 10,19 C5.58,19 2,15.42 2,11 C2,6.58 5.58,3 10,3 Z M10,5 C7.24,5 5,7.24 5,11 C5,13.76 7.24,16 10,16 C12.76,16 15,13.76 15,11 C15,8.24 12.76,5 10,5 Z";
            case "library":
                return "M4,4 H10 V20 H4 Z M14,4 H20 V20 H14 Z M4,7 L4,17 L10,17 L10,7 Z M14,4 H20 V20 H14 Z";
            default:
                return "";
        }
    }
}
