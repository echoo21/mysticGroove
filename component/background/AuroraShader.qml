import QtQuick
import QtQuick.Effects

ShaderEffect {
    id: root
    property real time: 0
    property vector2d resolution: Qt.size(root.width * Screen.devicePixelRatio, root.height * Screen.devicePixelRatio)
    property bool animated: Qt.application.animationEnabled !== undefined ? Qt.application.animationEnabled : true
    fragmentShader: "component/aurora.frag.qsb"
    NumberAnimation on time {
        from: 0; to: 100
        duration: 60000
        loops: Animation.Infinite
        running: root.animated
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#0B0B14" }
            GradientStop { position: 1.0; color: "#16162A" }
        }
        visible: !root.animated
    }
}
