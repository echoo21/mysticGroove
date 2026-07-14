import QtQuick

/**
 * Playlist/queue list item with thumbnail, title, artist, duration, and playing highlight.
 * Reuses glass aesthetic concept in a compact form.
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
        radius: 14
        color: root.isCurrentTrack
            ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.12)
            : "transparent"
        border.color: root.isCurrentTrack
            ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.20)
            : "transparent"
        border.width: 1
    }

    // Now playing indicator bar (left edge accent)
    Rectangle {
        anchors.left: bg.left
        anchors.leftMargin: -2
        anchors.verticalCenter: bg.verticalCenter
        width: 3; height: root.isCurrentTrack ? 32 : 0
        radius: 2
        color: root.accentColor
        visible: root.isCurrentTrack

        Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
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
            visible: !(artSource !== "" && parent.children[0].status === Image.Ready)
        }
    }

    // Song title
    Text {
        id: titleText
        anchors.left: thumb.right; anchors.leftMargin: 10
        anchors.right: durationText.left; anchors.rightMargin: 8
        anchors.top: bg.top; anchors.topMargin: 10
        text: root.songTitle
        font.pixelSize: 14
        font.weight: root.isCurrentTrack ? Font.DemiBold : Font.Normal
        color: root.isCurrentTrack ? "#F0F0FF" : "#C8C8E0"
        elide: Text.ElideRight
        lineHeight: 1.2
    }

    // Artist
    Text {
        id: artistText
        anchors.left: titleText.left
        anchors.right: durationText.left; anchors.rightMargin: 8
        anchors.top: titleText.bottom; anchors.topMargin: 2
        text: root.artist
        font.pixelSize: 12
        color: root.isCurrentTrack
            ? Qt.rgba(1, 1, 1, 0.60)
            : Qt.rgba(1, 1, 1, 0.45)
        elide: Text.ElideRight
    }

    // Duration
    Text {
        id: durationText
        anchors.right: bg.right; anchors.rightMargin: 10
        anchors.verticalCenter: bg.verticalCenter
        text: root.duration
        font.pixelSize: 11
        color: Qt.rgba(1, 1, 1, 0.35)
        font.letterSpacing: 0.3
    }

    // Playing indicator (pulsing dot)
    Rectangle {
        anchors.right: durationText.left; anchors.rightMargin: 6
        anchors.verticalCenter: bg.verticalCenter
        width: root.isCurrentTrack ? 6 : 0
        height: root.isCurrentTrack ? 6 : 0
        radius: 3
        color: root.accentColor
        visible: root.isCurrentTrack && root.isPlaying

        SequentialAnimation on opacity {
            running: root.isCurrentTrack && root.isPlaying
            loops: Animation.Infinite
            NumberAnimation { from: 1.0; to: 0.3; duration: 800; easing.type: Easing.InOutQuad }
            NumberAnimation { from: 0.3; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
        }
    }

    // Hover effect
    Rectangle {
        id: hoverOverlay
        anchors.fill: bg
        radius: bg.radius
        color: Qt.rgba(1, 1, 1, 0.04)
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
