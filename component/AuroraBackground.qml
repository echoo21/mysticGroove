import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

Rectangle {
    id: root

    // Deep-space gradient base
    gradient: Gradient {
        orientation: Gradient.Vertical
        GradientStop { position: 0.0; color: "#0B0B14" }
        GradientStop { position: 1.0; color: "#16162A" }
    }

    // Fallback when animations disabled — the glow layer stays hidden
    // but the gradient is always visible

    // Item to hold the 3 glow layers
    Item {
        id: glowsLayer
        anchors.fill: parent
        visible: Qt.application.animationEnabled !== undefined ? Qt.application.animationEnabled : true

        // Violet glow — top-left
        Rectangle {
            id: violetGlow
            x: parent.width * 0.15; y: parent.height * 0.1
            width: parent.width * 0.6; height: parent.height * 0.5
            radius: width / 2
            color: "#00000000"

            LinearGradient {
                anchors.fill: parent
                start: Qt.point(0, 0); end: Qt.point(parent.width, parent.height)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0.66, 0.33, 0.97, 0.04) }
                    GradientStop { position: 1.0; color: Qt.rgba(0.66, 0.33, 0.97, 0.0) }
                }
            }
        }

        // Cyan glow — middle-right
        Rectangle {
            id: cyanGlow
            x: parent.width * 0.5; y: parent.height * 0.3
            width: parent.width * 0.5; height: parent.height * 0.5
            radius: width / 2
            color: "#00000000"

            LinearGradient {
                anchors.fill: parent
                start: Qt.point(0, 0); end: Qt.point(parent.width, parent.height)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0.02, 0.71, 0.83, 0.04) }
                    GradientStop { position: 1.0; color: Qt.rgba(0.02, 0.71, 0.83, 0.0) }
                }
            }
        }

        // Rose glow — bottom-left
        Rectangle {
            id: roseGlow
            x: parent.width * 0.2; y: parent.height * 0.6
            width: parent.width * 0.55; height: parent.height * 0.45
            radius: width / 2
            color: "#00000000"

            LinearGradient {
                anchors.fill: parent
                start: Qt.point(0, 0); end: Qt.point(parent.width, parent.height)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0.96, 0.25, 0.37, 0.04) }
                    GradientStop { position: 1.0; color: Qt.rgba(0.96, 0.25, 0.37, 0.0) }
                }
            }
        }
    }

    // Soft blur on the glow layer
    MultiEffect {
        id: glowBlur
        anchors.fill: glowsLayer
        source: glowsLayer
        blurEnabled: true
        blurMax: 64
        blur: 1.0
        /* transparentBorder: not needed on MultiEffect */
        visible: Qt.application.animationEnabled !== undefined ? Qt.application.animationEnabled : true
    }

    // Slow drift animation
    property real animTime: 0

    NumberAnimation on animTime {
        from: 0; to: 3600
        duration: 60000  // 1-minute cycle
        loops: Animation.Infinite
        running: Qt.application.animationEnabled !== undefined ? Qt.application.animationEnabled : true
    }

    onAnimTimeChanged: {
        if (!glowsLayer.visible) return
        violetGlow.x = parent.width * 0.15 + Math.sin(animTime * 0.001) * 40
        violetGlow.y = parent.height * 0.1 + Math.cos(animTime * 0.0007) * 30
        cyanGlow.x = parent.width * 0.5 + Math.sin(animTime * 0.0008 + 2.0) * 35
        cyanGlow.y = parent.height * 0.3 + Math.cos(animTime * 0.0012 + 1.0) * 25
        roseGlow.x = parent.width * 0.2 + Math.sin(animTime * 0.0006 + 4.0) * 30
        roseGlow.y = parent.height * 0.6 + Math.cos(animTime * 0.0009 + 3.0) * 35
    }
}
