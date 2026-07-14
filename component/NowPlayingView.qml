import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import "."

/**
 * Full now-playing screen — album art, song info, seek bar, transport controls, queue button.
 * Designed with clear typography hierarchy and micro-interactions.
 * Ambient accent glow behind album art animates smoothly on track change.
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
        anchors.topMargin: 24
        anchors.bottomMargin: 24
        contentHeight: contentColumn.height + 48
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

            // === AMBIENT GLOW + ALBUM ART ===
            Item {
                width: parent.width
                height: Math.min(parent.width * 0.75, 360)

                // Ambient glow behind album art (Apple Music style)
                Rectangle {
                    id: ambientGlow
                    width: Math.min(parent.width * 0.85, 320)
                    height: width
                    anchors.centerIn: parent
                    radius: width / 2
                    color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.18)
                    opacity: 0.85

                    Behavior on color {
                        ColorAnimation { duration: 800; easing.type: Easing.OutCubic }
                    }

                    // Blurred halo
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blurMax: 64
                        blur: 1.0
                    }
                }

                // Secondary outer glow (wider, more diffuse)
                Rectangle {
                    id: outerGlow
                    width: Math.min(parent.width * 1.1, 400)
                    height: width
                    anchors.centerIn: parent
                    radius: width / 2
                    color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.08)
                    opacity: 0.6

                    Behavior on color {
                        ColorAnimation { duration: 1000; easing.type: Easing.OutCubic }
                    }

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blurMax: 64
                        blur: 1.0
                    }
                }

                AlbumArtDisplay {
                    id: albumArtDisplay
                    artSize: Math.min(parent.width * 0.68, 280)
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

                Column {
                    id: songInfo
                    anchors.centerIn: parent
                    width: parent.width
                    spacing: 8

                    Text {
                        id: titleText
                        width: parent.width
                        text: root.trackTitle
                        font.pixelSize: 28
                        font.weight: Font.Bold
                        color: "#F0F0FF"
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        lineHeight: 1.1
                    }

                    // Hairline divider between title and artist
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 24
                        height: 1
                        color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.15)
                        visible: root.trackArtist !== ""
                    }

                    Text {
                        id: artistText
                        width: parent.width
                        text: root.trackArtist
                        font.pixelSize: 14
                        font.weight: Font.Normal
                        color: Qt.rgba(1, 1, 1, 0.48)
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
                width: parent.width - 24
                anchors.horizontalCenter: parent.horizontalCenter
                height: 80

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
                height: root.volumeExpanded ? 48 : 32
                clip: true

                Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

                Row {
                    anchors.centerIn: parent
                    spacing: 12
                    height: 28

                    // Speaker icon (toggle expand)
                    PlayerIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        iconName: root.volume <= 0.0 ? "volumeMuted"
                                : (root.volume > 0.5 ? "volumeHigh" : "volumeLow")
                        iconSize: 20
                        color: Qt.rgba(1, 1, 1, 0.55)
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -8
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

                        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                        opacity: root.volumeExpanded ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

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
                            color: Qt.rgba(1, 1, 1, 0.90)
                            border.color: root.accentColor; border.width: 2
                        }
                        onMoved: {
                            root.volume = value
                            root.volumeAdjusted(value)
                        }
                    }

                    // Volume percentage label (compact when collapsed)
                    Text {
                        id: volumePct
                        anchors.verticalCenter: parent.verticalCenter
                        text: Math.round(root.volume * 100) + "%"
                        font.pixelSize: 11
                        color: Qt.rgba(1, 1, 1, 0.35)
                        visible: !root.volumeExpanded
                    }
                }
            }

            // === HAIRLINE DIVIDER ===
            Rectangle {
                width: parent.width - 80
                anchors.horizontalCenter: parent.horizontalCenter
                height: 1
                color: Qt.rgba(1, 1, 1, 0.06)
            }

            // === QUEUE BUTTON ===
            Item {
                width: parent.width - 48
                anchors.horizontalCenter: parent.horizontalCenter
                height: 48

                Rectangle {
                    id: queueBtn
                    anchors.centerIn: parent
                    width: parent.width * 0.48
                    height: 40
                    radius: 12
                    color: Qt.rgba(1, 1, 1, 0.04)
                    border.color: Qt.rgba(1, 1, 1, 0.08)
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        PlayerIcon {
                            iconName: "queue"
                            iconSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                            color: Qt.rgba(1, 1, 1, 0.55)
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Playlist"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            color: Qt.rgba(1, 1, 1, 0.55)
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: parent.color = Qt.rgba(1, 1, 1, 0.08)
                        onExited: parent.color = Qt.rgba(1, 1, 1, 0.04)
                        onClicked: root.navigateToQueue()
                    }

                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }
            }
        }
    }
}
