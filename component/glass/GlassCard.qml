import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

Rectangle {
    id: root

    // === PUBLIC PROPERTIES ===
    property string title: "Title"
    property string subtitle: "Subtitle"
    property string description: "Description..."
    property color accentColor: "#A855F7"
    property string buttonText: "Explore →"
    property int cornerRadius: 20
    property real glowIntensity: 0.12  // default glow opacity
    property int entranceDelay: 0
    property bool entered: false

    implicitWidth: 320
    opacity: entered ? 1.0 : 0
    scale: entered ? 1.0 : 0.95
    Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
    Behavior on scale { SpringAnimation { spring: 3; damping: 0.3; mass: 1.0 } }
    Component.onCompleted: entranceTimer.start()
    Timer { id: entranceTimer; interval: root.entranceDelay; onTriggered: root.entered = true }

    signal clicked()

    // Base frosted glass surface
    color: "#00000000"  // transparent — we layer effects
    radius: cornerRadius
    clip: true          // keep all layers inside rounded corners

    // --- Card surface contents (rendered to a layer, then blurred) ---
    Item {
        id: glassSurface
        anchors.fill: parent
        anchors.margins: 0

        // Translucent fill
        Rectangle {
            id: glassFill
            anchors.fill: parent
            radius: root.cornerRadius
            color: Qt.rgba(22/255, 22/255, 42/255, 0.55)
        }

        // Inner accent glow (bleeds from top-right)
        Rectangle {
            id: innerGlow
            width: parent.width * 0.7
            height: parent.height * 0.8
            x: parent.width * 0.3
            y: -parent.height * 0.1
            radius: width / 2

            LinearGradient {
                anchors.fill: parent
                start: Qt.point(0, 0); end: Qt.point(parent.width, parent.height)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, root.glowIntensity) }
                    GradientStop { position: 0.6; color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, root.glowIntensity * 0.25) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }

        // Second glow from bottom-left (complementary)
        Rectangle {
            id: secondaryGlow
            width: parent.width * 0.5
            height: parent.height * 0.6
            x: -parent.width * 0.1
            y: parent.height * 0.4
            radius: width / 2

            LinearGradient {
                anchors.fill: parent
                start: Qt.point(0, 0); end: Qt.point(parent.width, parent.height)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.05) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }
    }

    // Apply blur to the glass surface
    MultiEffect {
        id: glassBlur
        anchors.fill: glassSurface
        source: glassSurface
        blurEnabled: true
        blurMax: 64
        blur: 0.625
        /* transparentBorder: not needed on MultiEffect */
        /* cached: not supported on MultiEffect */
        visible: Qt.application.animationEnabled !== undefined ? Qt.application.animationEnabled : true
    }

    // When animations disabled, use plain translucent fill instead
    Rectangle {
        id: glassFallback
        anchors.fill: parent
        radius: root.cornerRadius
        color: Qt.rgba(22/255, 22/255, 42/255, 0.55)
        visible: !(Qt.application.animationEnabled !== undefined ? Qt.application.animationEnabled : true)
    }

    // Edge border (thin accent-colored)
    Rectangle {
        id: glassBorder
        anchors.fill: parent
        radius: root.cornerRadius
        color: "#00000000"
        border.color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.15)
        border.width: 1
    }

    // Drop shadow behind the card
    MultiEffect {
        id: cardShadow
        anchors.fill: parent
        source: parent
        shadowEnabled: true
        shadowColor: Qt.rgba(0, 0, 0, 0.4)
        shadowBlur: 0.5
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 8
        /* transparentBorder: not needed on MultiEffect */
        /* cached: not supported on MultiEffect */
        visible: glassBlur.visible
    }

    // --- Shimmer sweep overlay ---
    Rectangle {
        id: shimmerMask
        anchors.fill: parent
        radius: root.cornerRadius
        color: "#00000000"
        clip: true

        Rectangle {
            id: shimmerBand
            width: parent.width * 0.6
            height: parent.height * 1.2
            x: -shimmerBand.width      // start off-screen left
            y: -parent.height * 0.1
            rotation: -20

            LinearGradient {
                anchors.fill: parent
                start: Qt.point(0, 0); end: Qt.point(parent.width, 0)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.3; color: Qt.rgba(1, 1, 1, 0.02) }
                    GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.04) }
                    GradientStop { position: 0.7; color: Qt.rgba(1, 1, 1, 0.02) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            // Sweep animation
            NumberAnimation on x {
                from: -shimmerBand.width
                to: parent.width
                duration: 6000
                loops: Animation.Infinite
                running: Qt.application.animationEnabled !== undefined ? Qt.application.animationEnabled : true
            }
        }
    }

    // --- Content layer (always on top, no blur) ---
    Item {
        id: contentLayer
        anchors.fill: parent
        anchors.margins: 0

        // Icon circle
        Rectangle {
            id: iconCircle
            x: 24; y: 24
            width: 44; height: 44
            radius: 22
            color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.15)
            border.color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.2)

            Text {
                anchors.centerIn: parent
                text: root.title.charAt(0).toUpperCase()
                font.pixelSize: 18
                font.weight: Font.DemiBold
                color: accentColor
            }
        }

        // Title
        Text {
            id: titleText
            anchors.left: iconCircle.left
            anchors.top: iconCircle.bottom
            anchors.topMargin: 14
            text: root.title
            font.pixelSize: 18
            font.weight: Font.DemiBold
            color: "#F0F0FF"
            elide: Text.ElideRight
            width: parent.width - 48
        }

        // Subtitle
        Text {
            id: subtitleText
            anchors.left: titleText.left
            anchors.top: titleText.bottom
            anchors.topMargin: 4
            text: root.subtitle
            font.pixelSize: 13
            color: "#A0A0C0"
            elide: Text.ElideRight
            width: parent.width - 48
        }

        // Description
        Text {
            id: descText
            anchors.left: titleText.left
            anchors.top: subtitleText.bottom
            anchors.topMargin: 8
            text: root.description
            font.pixelSize: 13
            color: "#C8C8E0"
            lineHeight: 1.5
            wrapMode: Text.WordWrap
            width: parent.width - 48
            clip: true
            maximumLineCount: 3
            elide: Text.ElideRight
        }

        // Action button
        GlassButton {
            id: actionButton
            anchors.left: titleText.left
            anchors.right: parent.right
            anchors.rightMargin: 24
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            text: root.buttonText
            accentColor: root.accentColor
            onClicked: root.clicked()
        }
    }

    // --- Card-level MouseArea for hover/press on the whole card ---
    MouseArea {
        id: cardMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        // Propagate click to action button as well
        onClicked: root.clicked()
        onPositionChanged: (mouse) => {
            var nx = (mouse.x / root.width - 0.5) * 2;
            var ny = (mouse.y / root.height - 0.5) * 2;
            tiltY.angle = nx * 8;
            tiltX.angle = -ny * 8;
        }
        onExited: { tiltX.angle = 0; tiltY.angle = 0; }
    }

    transform: [
        Translate { id: liftTransform; y: 0 },
        Rotation { id: tiltX; angle: 0; origin.x: root.width / 2; origin.y: root.height / 2; Behavior on angle { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } } },
        Rotation { id: tiltY; angle: 0; origin.x: root.width / 2; origin.y: root.height / 2; Behavior on angle { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } } }
    ]

    states: [
        State {
            name: "hovered"
            when: cardMouseArea.containsMouse
            PropertyChanges { target: liftTransform; y: -3 }
            PropertyChanges { target: root; glowIntensity: 0.20 }
        },
        State {
            name: "pressed"
            when: cardMouseArea.pressed
            PropertyChanges { target: root; scale: 0.98 }
            PropertyChanges { target: root; glowIntensity: 0.08 }
        }
    ]

    transitions: [
        Transition {
            from: "*"; to: "hovered"
            NumberAnimation { target: liftTransform; property: "y"; duration: 200; easing.type: Easing.OutCubic }
            NumberAnimation { target: innerGlow; property: "opacity"; duration: 300; easing.type: Easing.OutCubic }
        },
        Transition {
            from: "hovered"; to: "*"
            NumberAnimation { target: liftTransform; property: "y"; duration: 200; easing.type: Easing.OutCubic }
            NumberAnimation { target: innerGlow; property: "opacity"; duration: 300; easing.type: Easing.OutCubic }
        },
        Transition {
            from: "*"; to: "pressed"
            NumberAnimation { target: root; property: "scale"; duration: 100; easing.type: Easing.OutCubic }
        },
        Transition {
            from: "pressed"; to: "*"
            NumberAnimation { target: root; property: "scale"; duration: 150; easing.type: Easing.OutBack }
        }
    ]

    // Calculate implicitHeight from content
    implicitHeight: {
        var top = 24  // icon top margin
        top += 44     // icon height
        top += 14     // spacing
        top += 20     // title (approx)
        top += 4      // spacing
        top += 16     // subtitle (approx)
        top += 8      // spacing
        top += 18     // description per line * 3 lines
        top += 16     // spacing to button
        top += 38     // button height
        top += 20     // bottom margin
        return Math.max(240, top)
    }
}
