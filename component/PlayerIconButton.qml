import QtQuick

/**
 * Circular glass icon button for player controls.
 * Use text icon or emoji as iconText. active is externally controlled by parent.
 *
 * TODO: Replace icon placeholders (▶ ⏸ ⏮ ⏭ 🔀 🔁) with custom SVGs or icon font if desired.
 */
Item {
    id: root

    property string iconText: "▶"
    property color accentColor: "#A855F7"
    property real size: 44
    property real iconScale: 0.48
    property bool active: false       // visual active/toggle state (set externally)
    property bool btnEnabled: true

    signal clicked()

    implicitWidth: size
    implicitHeight: size

    // Glass circle background
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: width / 2
        color: root.active
            ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.30)
            : Qt.rgba(22/255, 22/255, 42/255, 0.50)
        border.color: root.active
            ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.35)
            : Qt.rgba(255/255, 255/255, 255/255, 0.08)
        border.width: 1

        // Active glow sweep
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            visible: root.active
            Rectangle {
                width: parent.width * 0.5; height: parent.height
                x: -width; y: 0
                rotation: -15
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.08) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
                NumberAnimation on x {
                    from: -width; to: parent.width
                    duration: 3000; loops: Animation.Infinite
                    running: root.active && (Qt.application.animationEnabled !== undefined
                        ? Qt.application.animationEnabled : true)
                }
            }
        }
    }

    // Hover glow
    Rectangle {
        id: hoverGlow
        anchors.fill: parent
        radius: width / 2
        color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.12)
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    // Icon text
    Text {
        anchors.centerIn: parent
        text: root.iconText
        font.pixelSize: root.size * root.iconScale
        color: root.btnEnabled
            ? (root.active
                ? Qt.rgba(1, 1, 1, 1)
                : Qt.rgba(1, 1, 1, 0.85))
            : Qt.rgba(1, 1, 1, 0.30)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        lineHeight: 1.0
    }

    // Mouse area
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.btnEnabled
        cursorShape: Qt.PointingHandCursor

        onEntered: hoverGlow.opacity = 1.0
        onExited: hoverGlow.opacity = 0.0
        onPressed: root.scale = 0.88
        onReleased: {
            root.scale = 1.0
            if (containsMouse) root.clicked()
        }
    }

    Behavior on scale { SpringAnimation { spring: 5; damping: 0.3; mass: 0.6 } }
}
