import QtQuick
import "."

/**
 * Mini-player / bottom bar — compact now-playing bar sticky at bottom.
 * Tapping expands to full now-playing view.
 *
 * TODO: Connect playPauseClicked() to playback engine.
 * TODO: Connect progress to backend position updates.
 */
Item {
    id: root

    property color accentColor: "#A855F7"
    property string songTitle: "Untitled"
    property string artist: "Unknown Artist"
    property string artSource: ""
    property bool isPlaying: false
    property real position: 0.0
    property real duration: 0.0

    signal expandClicked()
    signal playPauseClicked()
    signal nextClicked()

    implicitWidth: parent ? parent.width : 360
    implicitHeight: 64

    // Glass background
    Rectangle {
        id: barBg
        anchors.fill: parent
        color: Qt.rgba(12/255, 12/255, 30/255, 0.88)

        // Top border line
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 1
            color: Qt.rgba(1, 1, 1, 0.06)
        }

        // Section divider at artist/controls boundary
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 1
            height: 0.5
            color: Qt.rgba(1, 1, 1, 0.04)
        }

        // Progress bar at top edge
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width * root.position
            height: 2
            color: root.accentColor
            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.Linear } }
        }
    }

    // Thumbnail
    Rectangle {
        id: miniThumb
        anchors.left: parent.left; anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 44; height: 44
        radius: 10
        color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.20)

        Image {
            anchors.fill: parent
            source: root.artSource
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
            visible: status === Image.Ready
            smooth: true
        }
        Text {
            anchors.centerIn: parent
            text: root.songTitle.charAt(0).toUpperCase()
            font.pixelSize: 16
            color: Qt.rgba(1, 1, 1, 0.40)
            visible: root.artSource === ""
        }
    }

    // Title + artist
    Column {
        id: miniInfo
        anchors.left: miniThumb.right; anchors.leftMargin: 12
        anchors.right: miniControls.left; anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            width: parent.width
            text: root.songTitle
            font.pixelSize: 14
            font.weight: Font.DemiBold
            color: "#F0F0FF"
            elide: Text.ElideRight
            lineHeight: 1.2
        }
        Text {
            width: parent.width
            text: root.artist
            font.pixelSize: 12
            color: Qt.rgba(1, 1, 1, 0.48)
            elide: Text.ElideRight
        }
    }

    // Controls
    Row {
        id: miniControls
        anchors.right: parent.right; anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        PlayerIconButton {
            iconName: root.isPlaying ? "pause" : "play"
            size: 38
            accentColor: root.accentColor
            iconScale: 0.38
            onClicked: root.playPauseClicked()
        }
        PlayerIconButton {
            iconName: "skipNext"
            size: 32
            accentColor: root.accentColor
            iconScale: 0.38
            onClicked: root.nextClicked()
        }
    }

    // Expand tap target (covers thumb + title area)
    MouseArea {
        id: expandArea
        anchors.left: parent.left
        anchors.right: miniControls.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expandClicked()
    }
}
