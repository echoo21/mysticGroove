import QtQuick
import "."

/**
 * Main transport controls: Shuffle | Prev | Play/Pause | Next | Repeat
 * Play/pause is larger and more prominent. Uses PlayerIconButton.
 * Toggle state (shuffle, repeat) is managed externally by the parent.
 *
 * TODO: Connect shuffleClicked to shuffle mode.
 * TODO: Connect repeatClicked to repeat mode.
 * TODO: Connect previousClicked() to previous track logic.
 * TODO: Connect nextClicked() to next track logic.
 * TODO: Connect playPauseClicked() and isPlaying to playback engine.
 */
Item {
    id: root

    property color accentColor: "#A855F7"
    property bool isPlaying: false
    property bool shuffleActive: false
    property bool repeatActive: false
    property bool controlsEnabled: true

    signal playPauseClicked()
    signal nextClicked()
    signal previousClicked()
    signal shuffleClicked()
    signal repeatClicked()

    implicitWidth: 300
    implicitHeight: 64

    Row {
        anchors.centerIn: parent
        spacing: Math.max(6, (root.width - 240) / 5)

        // Shuffle
        PlayerIconButton {
            iconText: "🔀"
            size: 38
            anchors.verticalCenter: parent.verticalCenter
            accentColor: root.accentColor
            btnEnabled: root.controlsEnabled
            active: root.shuffleActive
            onClicked: root.shuffleClicked()
        }

        // Previous
        PlayerIconButton {
            iconText: "⏮"
            size: 38
            anchors.verticalCenter: parent.verticalCenter
            accentColor: root.accentColor
            btnEnabled: root.controlsEnabled
            onClicked: root.previousClicked()
        }

        // Play/Pause (larger)
        PlayerIconButton {
            iconText: root.isPlaying ? "⏸" : "▶"
            size: 56
            anchors.verticalCenter: parent.verticalCenter
            accentColor: root.accentColor
            btnEnabled: root.controlsEnabled
            active: root.isPlaying
            iconScale: 0.42
            onClicked: root.playPauseClicked()
        }

        // Next
        PlayerIconButton {
            iconText: "⏭"
            size: 38
            anchors.verticalCenter: parent.verticalCenter
            accentColor: root.accentColor
            btnEnabled: root.controlsEnabled
            onClicked: root.nextClicked()
        }

        // Repeat
        PlayerIconButton {
            iconText: "🔁"
            size: 38
            anchors.verticalCenter: parent.verticalCenter
            accentColor: root.accentColor
            btnEnabled: root.controlsEnabled
            active: root.repeatActive
            onClicked: root.repeatClicked()
        }
    }
}
