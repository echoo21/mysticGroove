import QtQuick
import QtQuick.Effects

/**
 * Large album art display with rotation animation, glass reflection overlay,
 * fallback gradient when image source is empty.
 *
 * TODO: Connect image source to backend - set artSource to file:/// or qrc:/// path.
 */
Item {
    id: root

    property string artSource: ""
    property color accentColor: "#A855F7"
    property real artSize: 280
    property bool isPlaying: false
    property bool showShadow: true

    signal clicked()

    implicitWidth: artSize
    implicitHeight: artSize

    // === ART CONTAINER ===
    Item {
        id: artContainer
        width: artSize
        height: artSize
        anchors.centerIn: parent

        // Rotation animation
        property real rotationAngle: 0
        NumberAnimation on rotationAngle {
            running: root.isPlaying
            from: 0; to: 360
            duration: 16000
            loops: Animation.Infinite
        }

        Behavior on rotationAngle {
            RotationAnimation {
                direction: RotationAnimation.Shortest
                duration: 600
                easing.type: Easing.OutCubic
            }
        }

        // Art image or fallback
        Rectangle {
            id: artBase
            anchors.fill: parent
            radius: 18
            color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.15)

            Image {
                id: artImage
                anchors.fill: parent
                source: root.artSource
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
                visible: status === Image.Ready
                smooth: true
            }

            // Fallback gradient when no image
            Rectangle {
                anchors.fill: parent
                radius: 18
                visible: artImage.status !== Image.Ready || root.artSource === ""

                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.60) }
                    GradientStop { position: 0.5; color: Qt.rgba(accentColor.r * 0.7, accentColor.g * 0.7, accentColor.b * 0.7, 0.35) }
                    GradientStop { position: 1.0; color: Qt.rgba(accentColor.r * 0.5, accentColor.g * 0.5, accentColor.b * 0.5, 0.60) }
                }

                // Music note icon
                Text {
                    anchors.centerIn: parent
                    text: "♫"
                    font.pixelSize: artSize * 0.35
                    color: Qt.rgba(1, 1, 1, 0.50)
                }
            }

            // Edge border
            Rectangle {
                anchors.fill: parent
                radius: 18
                color: "transparent"
                border.color: Qt.rgba(1, 1, 1, 0.08)
                border.width: 1
            }
        }

        // Glass reflection overlay (subtle top-left shine)
        Rectangle {
            anchors.fill: parent
            radius: 18
            color: "transparent"

            Rectangle {
                width: parent.width * 0.6; height: parent.height * 0.5
                x: -width * 0.2; y: -height * 0.1
                rotation: -25

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.0) }
                    GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.06) }
                    GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.0) }
                }
            }
        }

        // Rotate transform — only the visual part (art + overlay), not the hit area
        transform: Rotation {
            origin.x: artSize / 2
            origin.y: artSize / 2
            angle: artContainer.rotationAngle
        }

        // Mouse area
        MouseArea {
            id: artMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }
    }

    // Drop shadow behind art
    MultiEffect {
        anchors.fill: artContainer
        source: artContainer
        shadowEnabled: root.showShadow
        shadowColor: Qt.rgba(0, 0, 0, 0.50)
        shadowBlur: 0.6
        shadowVerticalOffset: 12
        visible: root.showShadow
    }
}
