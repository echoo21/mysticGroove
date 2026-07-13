import QtQuick

Item {
    id: root
    property string text: "Button"
    property color accentColor: "#A855F7"
    property bool btnEnabled: true
    signal clicked()
    implicitWidth: 120; implicitHeight: 38

    Rectangle {
        id: bg; anchors.fill: parent; radius: 12
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, root.btnEnabled ? 0.25 : 0.10) }
            GradientStop { position: 1.0; color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, root.btnEnabled ? 0.10 : 0.05) }
        }
        border.color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, root.btnEnabled ? 0.20 : 0.08)
        border.width: 1
    }
    Rectangle {
        id: hoverGlow; anchors.fill: parent; radius: 12
        color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.08)
        opacity: 0; visible: root.btnEnabled
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }
    Text {
        anchors.centerIn: parent; text: root.text
        font.pixelSize: 13; font.weight: Font.DemiBold
        color: root.btnEnabled ? Qt.rgba(Math.min(1.0, accentColor.r * 1.3), Math.min(1.0, accentColor.g * 1.3), Math.min(1.0, accentColor.b * 1.3), 1.0) : "#666680"
    }
    MouseArea {
        anchors.fill: parent; hoverEnabled: true; enabled: root.btnEnabled; cursorShape: Qt.PointingHandCursor
        onEntered: hoverGlow.opacity = 1.0
        onExited: hoverGlow.opacity = 0.0
        onPressed: root.scale = 0.97
        onReleased: { root.scale = 1.0; if (containsMouse) root.clicked() }
        Behavior on scale { SpringAnimation { spring: 4; damping: 0.3; mass: 0.8 } }
    }
}
