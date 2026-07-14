import QtQuick
import QtQuick.Controls
import "."

/**
 * Playlist/Queue screen — scrollable list of QueueItem delegates with header and back button.
 *
 * TODO-Connect Backend:
 *   - Set playlistModel from backend (currently using ListModel dummy data).
 *   - Set currentTrackIndex from backend.
 *   - Connect QueueItem.clicked() to actual track selection.
 *   - Highlight the currently playing track.
 */
Item {
    id: root

    property color accentColor: "#A855F7"
    property bool isPlaying: false
    property int currentTrackIndex: -1

    signal backToPlayer()
    signal trackSelected(int index)

    // Mock playlist data
    /* TODO: Replace with actual backend model */
    property var playlistData: [
        { title: "Neon Dreams", artist: "Mystic Groove", duration: 272, art: "" },
        { title: "Aurora Borealis", artist: "Synthwave Collective", duration: 238, art: "" },
        { title: "Midnight Circuit", artist: "Digital Horizon", duration: 312, art: "" },
        { title: "Glass Cathedral", artist: "Ambient Souls", duration: 405, art: "" },
        { title: "Pixel Rain", artist: "Retro Future", duration: 200, art: "" },
        { title: "Cosmic Drift", artist: "Stellar Ensemble", duration: 424, art: "" },
        { title: "Chrome Waves", artist: "Neon Tide", duration: 258, art: "" },
        { title: "Violet Echo", artist: "Mystic Groove", duration: 330, art: "" },
        { title: "Quantum Lullaby", artist: "Deep Frequencies", duration: 225, art: "" },
        { title: "Starlight Protocol", artist: "Digital Horizon", duration: 382, art: "" }
    ]

    function formatTime(sec) {
        if (typeof sec === "string") return sec
        if (sec <= 0 || isNaN(sec)) return "0:00"
        var m = Math.floor(sec / 60)
        var s = Math.floor(sec % 60)
        return m + ":" + (s < 10 ? "0" : "") + s
    }

    implicitWidth: parent ? parent.width : 360
    implicitHeight: parent ? parent.height : 600

    Flickable {
        id: playlistFlick
        anchors.fill: parent
        contentHeight: playlistColumn.height + 100
        clip: true
        topMargin: 20
        bottomMargin: 20

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded; width: 4
            background: Rectangle { color: "transparent" }
            contentItem: Rectangle { radius: 2; color: Qt.rgba(1, 1, 1, 0.12) }
        }

        Column {
            id: playlistColumn
            width: parent.width - (parent.parent ? (parent.parent.width < 400 ? 16 : 32) : 32)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4

            // Header
            Item {
                width: parent.width
                height: 54

                // Back button
                PlayerIconButton {
                    id: backBtn
                    iconText: "〈"
                    size: 36
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    accentColor: root.accentColor
                    iconScale: 0.45
                    onClicked: root.backToPlayer()
                }

                // Title
                Text {
                    anchors.centerIn: parent
                    text: "Now Playing"
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    color: "#F0F0FF"
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(1, 1, 1, 0.06)
            }

            // Spacing
            Item { width: 1; height: 8 }

            // Queue list
            Repeater {
                id: queueRepeater
                model: root.playlistData

                delegate: QueueItem {
                    width: parent.width
                    songTitle: modelData.title
                    artist: modelData.artist
                    duration: root.formatTime(modelData.duration)
                    artSource: modelData.art
                    accentColor: root.accentColor
                    isPlaying: root.isPlaying
                    isCurrentTrack: index === root.currentTrackIndex
                    listIndex: index

                    onClicked: root.trackSelected(index)
                }
            }

            // Bottom spacer for mini-player clearance
            Item { width: 1; height: 10 }
            Text {
                width: parent.width
                text: "♫  " + root.playlistData.length + " tracks"
                font.pixelSize: 11
                color: Qt.rgba(1, 1, 1, 0.25)
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
