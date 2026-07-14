import QtQuick

/**
 * Playlist/queue list item with thumbnail, title, artist, duration, and equalizer playing indicator.
 * Reuses glass aesthetic concept in a compact form.
 * Current track shows animated equalizer bars instead of pulsing dot.
 *
 * TODO: Connect click/selection handler to queue position change.
 */
Item {
    id: root

    property string songTitle: "Untitled"
    property string artist: "Unknown Artist"
    property string duration: "0:00"
    property string artSource: ""
    property color accentColor: "#A855F7"
    property bool isPlaying: false
    property bool isCurrentTrack: false
    property int listIndex: 0

    signal clicked()

    implicitWidth: parent ? parent.width : 320
    implicitHeight: 64

    Rectangle {
        id: bg
        anchors.fill: parent
        anchors.margins: 2
        radius: 12
        color: root.isCurrentTrack
            ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.10)
            : "transparent"
        border.color: root.isCurrentTrack
            ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.16)
            : "transparent"
        border.width: 1

        Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutCubic } }
    }

    // Now playing indicator bar (left edge accent) — thinner and more refined
    Rectangle {
        anchors.left: bg.left
        anchors.leftMargin: -2
        anchors.verticalCenter: bg.verticalCenter
        width: 3; height: root.isCurrentTrack ? 32 : 0
        radius: 1.5
        color: root.accentColor
        visible: root.isCurrentTrack

        Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
    }

    // Thumbnail
    Rectangle {
        id: thumb
        anchors.left: bg.left; anchors.leftMargin: 8
        anchors.verticalCenter: bg.verticalCenter
        width: 46; height: 46
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
            font.pixelSize: 18
            color: Qt.rgba(1, 1, 1, 0.40)
            visible: root.artSource === ""
        }
    }

    // Song title
    Text {
        id: titleText
        anchors.left: thumb.right; anchors.leftMargin: 12
        anchors.right: durationText.left; anchors.rightMargin: 8
        anchors.top: bg.top; anchors.topMargin: 10
        text: root.songTitle
        font.pixelSize: 14
        font.weight: root.isCurrentTrack ? Font.DemiBold : Font.Normal
        color: root.isCurrentTrack ? "#F0F0FF" : "#C8C8E0"
        elide: Text.ElideRight
        lineHeight: 1.2

        Behavior on color { ColorAnimation { duration: 200 } }
    }

    // Artist
    Text {
        id: artistText
        anchors.left: titleText.left
        anchors.right: durationText.left; anchors.rightMargin: 8
        anchors.top: titleText.bottom; anchors.topMargin: 3
        text: root.artist
        font.pixelSize: 12
        color: root.isCurrentTrack
            ? Qt.rgba(1, 1, 1, 0.55)
            : Qt.rgba(1, 1, 1, 0.40)
        elide: Text.ElideRight

        Behavior on color { ColorAnimation { duration: 200 } }
    }

    // Duration
    Text {
        id: durationText
        anchors.right: bg.right; anchors.rightMargin: 10
        anchors.verticalCenter: bg.verticalCenter
        text: root.duration
        font.pixelSize: 11
        color: Qt.rgba(1, 1, 1, 0.30)
        font.letterSpacing: 0.3
    }

    // Animated equalizer bars (Spotify/Apple Music style "now playing" indicator)
    // Only visible for the current track when it's playing
    Item {
        anchors.right: durationText.left; anchors.rightMargin: 8
        anchors.verticalCenter: bg.verticalCenter
        width: 16; height: 16
        visible: root.isCurrentTrack && root.isPlaying
        clip: true

        // Bar 1
        Rectangle {
            id: bar1
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: -5
            width: 3; height: 6
            radius: 1.5
            color: root.accentColor
            SequentialAnimation on height {
                running: root.isCurrentTrack && root.isPlaying
                loops: Animation.Infinite
                NumberAnimation { from: 16; to: 4; duration: 380; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 4; to: 12; duration: 380; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 12; to: 6; duration: 380; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 6; to: 16; duration: 380; easing.type: Easing.InOutQuad }
            }
            Behavior on height { NumberAnimation { duration: 100 } }
        }

        // Bar 2
        Rectangle {
            id: bar2
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: 0
            width: 3; height: 6
            radius: 1.5
            color: root.accentColor
            opacity: 0.8
            SequentialAnimation on height {
                running: root.isCurrentTrack && root.isPlaying
                loops: Animation.Infinite
                NumberAnimation { from: 4; to: 16; duration: 420; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 16; to: 8; duration: 420; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 8; to: 4; duration: 420; easing.type: Easing.InOutQuad }
            }
        }

        // Bar 3
        Rectangle {
            id: bar3
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: 5
            width: 3; height: 6
            radius: 1.5
            color: root.accentColor
            opacity: 0.6
            SequentialAnimation on height {
                running: root.isCurrentTrack && root.isPlaying
                loops: Animation.Infinite
                NumberAnimation { from: 8; to: 16; duration: 350; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 16; to: 4; duration: 350; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 4; to: 10; duration: 350; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 10; to: 8; duration: 350; easing.type: Easing.InOutQuad }
            }
        }
    }

    // Hover effect
    Rectangle {
        id: hoverOverlay
        anchors.fill: bg
        radius: bg.radius
        color: Qt.rgba(1, 1, 1, 0.03)
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    MouseArea {
        anchors.fill: bg
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: hoverOverlay.opacity = 1.0
        onExited: hoverOverlay.opacity = 0.0
        onClicked: root.clicked()
    }
}
