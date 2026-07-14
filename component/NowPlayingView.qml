import QtQuick
import QtQuick.Controls
import "."

/**
 * Full now-playing screen — album art, song info, seek bar, transport controls, queue button.
 * Designed with clear typography hierarchy and micro-interactions.
 *
 * TODO-Connect Backend:
 *   - Set trackTitle, trackArtist, albumArt, duration, currentTime from backend.
 *   - Connect SeekBar.moved(value) to actual seek.
 *   - Connect PlayerControls.nextClicked/previousClicked/playPauseClicked/shuffleClicked/repeatClicked.
 *   - Update isPlaying, position from backend timer/playback state.
 *   - Update shuffleActive, repeatActive from backend state.
 *   - Queue/playlist toggle button signal.
 */
Item {
    id: root

    property color accentColor: "#A855F7"
    property string trackTitle: "Untitled"
    property string trackArtist: "Unknown Artist"
    property string albumArt: ""
    property bool isPlaying: false
    property real position: 0.0       // 0.0–1.0
    property real currentTime: 0.0
    property real duration: 0.0
    property bool shuffleActive: false
    property bool repeatActive: false
    property bool playingNextTrack: false   // for crossfade UX
    property bool volumeExpanded: false
    property real volume: 0.80              // 0.0–1.0

    signal playPauseClicked()
    signal nextClicked()
    signal previousClicked()
    signal shuffleClicked()
    signal repeatClicked()
    signal seeked(real value)
    signal navigateToQueue()
    signal navigateBack()
    signal volumeAdjusted(real value)

    // TODO: Connect volumeAdjusted to actual audio backend volume.

    implicitWidth: parent ? parent.width : 360
    implicitHeight: parent ? parent.height : 600

    // Scrollable content
    Flickable {
        id: flick
        anchors.fill: parent
        anchors.topMargin: 20
        anchors.bottomMargin: 20
        contentHeight: contentColumn.height + 40
        clip: true
        interactive: contentHeight > height

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded; width: 4
            background: Rectangle { color: "transparent" }
            contentItem: Rectangle { radius: 2; color: Qt.rgba(1, 1, 1, 0.12) }
        }

        Column {
            id: contentColumn
            width: flick.width
            spacing: 0
            anchors.horizontalCenter: parent.horizontalCenter

            // === ALBUM ART ===
            Item {
                width: parent.width
                height: Math.min(parent.width * 0.75, 340)

                AlbumArtDisplay {
                    id: albumArtDisplay
                    artSize: Math.min(parent.width * 0.70, 300)
                    anchors.centerIn: parent
                    artSource: root.albumArt
                    accentColor: root.accentColor
                    isPlaying: root.isPlaying
                }
            }

            // === SONG INFO ===
            Item {
                width: parent.width - 48
                anchors.horizontalCenter: parent.horizontalCenter
                height: songInfo.height + 32

                // Track title
                Column {
                    id: songInfo
                    anchors.centerIn: parent
                    width: parent.width
                    spacing: 4

                    Text {
                        id: titleText
                        width: parent.width
                        text: root.trackTitle
                        font.pixelSize: 26
                        font.weight: Font.Bold
                        color: "#F0F0FF"
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        lineHeight: 1.1
                    }

                    Text {
                        id: artistText
                        width: parent.width
                        text: root.trackArtist
                        font.pixelSize: 15
                        font.weight: Font.Normal
                        color: Qt.rgba(1, 1, 1, 0.55)
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                }
            }

            // === SEEK BAR ===
            Item {
                width: parent.width - 48
                anchors.horizontalCenter: parent.horizontalCenter
                height: 56

                SeekBar {
                    id: seekBar
                    anchors.fill: parent
                    accentColor: root.accentColor
                    position: root.position
                    duration: root.duration
                    currentTime: root.currentTime
                    onMoved: (value) => root.seeked(value)
                }
            }

            // === CONTROLS ===
            Item {
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                height: 72

                PlayerControls {
                    id: playerControls
                    anchors.fill: parent
                    accentColor: root.accentColor
                    isPlaying: root.isPlaying
                    shuffleActive: root.shuffleActive
                    repeatActive: root.repeatActive

                    onPlayPauseClicked: root.playPauseClicked()
                    onNextClicked: root.nextClicked()
                    onPreviousClicked: root.previousClicked()
                    onShuffleClicked: root.shuffleClicked()
                    onRepeatClicked: root.repeatClicked()
                }
            }

            // === VOLUME CONTROL (collapsible) ===
            Item {
                width: parent.width - 48
                anchors.horizontalCenter: parent.horizontalCenter
                height: root.volumeExpanded ? 48 : 36
                clip: true

                Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

                Row {
                    anchors.centerIn: parent
                    spacing: 10
                    height: 28

                    // Speaker icon (toggle expand)
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.volume > 0.0 ? (root.volume > 0.5 ? "🔊" : "🔉") : "🔇"
                        font.pixelSize: 14
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.volumeExpanded = !root.volumeExpanded
                        }
                    }

                    // Volume slider
                    Slider {
                        id: volumeSlider
                        anchors.verticalCenter: parent.verticalCenter
                        width: root.volumeExpanded ? Math.min(root.width * 0.40, 160) : 0
                        from: 0.0; to: 1.0; value: root.volume
                        stepSize: 0.02

                        Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                        opacity: root.volumeExpanded ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 200 } }

                        background: Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width; height: 3; radius: 1.5
                            color: Qt.rgba(1, 1, 1, 0.10)
                            Rectangle {
                                width: parent.width * volumeSlider.visualPosition; height: 3; radius: 1.5
                                color: root.accentColor
                            }
                        }
                        handle: Rectangle {
                            x: volumeSlider.visualPosition * (volumeSlider.availableWidth) - width / 2
                            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                            width: 12; height: 12; radius: 6
                            color: Qt.rgba(1, 1, 1, 0.85)
                            border.color: root.accentColor; border.width: 2
                        }
                        onMoved: {
                            root.volume = value
                            root.volumeAdjusted(value)
                        }
                    }

                    // Volume percentage label (always visible when collapsed)
                    Text {
                        id: volumePct
                        anchors.verticalCenter: parent.verticalCenter
                        text: Math.round(root.volume * 100) + "%"
                        font.pixelSize: 11
                        color: Qt.rgba(1, 1, 1, 0.40)
                        visible: !root.volumeExpanded
                    }
                }
            }

            // === QUEUE BUTTON ===
            Item {
                width: parent.width - 48
                anchors.horizontalCenter: parent.horizontalCenter
                height: 48

                Rectangle {
                    id: queueBtn
                    anchors.centerIn: parent
                    width: parent.width * 0.5
                    height: 38
                    radius: 12
                    color: Qt.rgba(1, 1, 1, 0.04)
                    border.color: Qt.rgba(1, 1, 1, 0.10)
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "View Playlist  〉"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: Qt.rgba(1, 1, 1, 0.60)
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: parent.color = Qt.rgba(1, 1, 1, 0.08)
                        onExited: parent.color = Qt.rgba(1, 1, 1, 0.04)
                        onClicked: root.navigateToQueue()
                    }

                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }
        }
    }
}
