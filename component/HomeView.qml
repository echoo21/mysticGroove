import QtQuick
import QtQuick.Controls
import "."

/**
 * Home screen — greeting, recently played horizontal scroll, quick picks grid.
 * Responsive layout with max-width cap for large screens.
 *
 * TODO: Replace mock trackData with real backend model.
 */
Item {
    id: root

    property color accentColor: "#A855F7"
    property var trackData: []
    property int currentTrackIndex: -1
    property bool isPlaying: false

    signal trackClicked(int index)
    signal trackPlayPauseClicked(int index)

    Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

    Flickable {
        id: homeFlick
        anchors.fill: parent
        contentHeight: homeColumn.height + 80
        clip: true
        topMargin: 16
        bottomMargin: 16

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded; width: 4
            background: Rectangle { color: "transparent" }
            contentItem: Rectangle { radius: 2; color: Qt.rgba(1, 1, 1, 0.12) }
        }

        Column {
            id: homeColumn
            width: cappedWidth
            property real sideMargins: Math.max(16, (parent.width - Math.min(parent.width, 800)) * 0.3)
            property real cappedWidth: Math.min(parent.width, 800) - sideMargins * 2
            x: sideMargins
            spacing: 24

            // === GREETING ===
            Text {
                text: {
                    var h = new Date().getHours()
                    if (h < 12) return "Good Morning"
                    if (h < 18) return "Good Afternoon"
                    return "Good Evening"
                }
                font.pixelSize: 28
                font.weight: Font.Bold
                color: "#F0F0FF"
                lineHeight: 1.1
            }

            // === RECENTLY PLAYED ===
            Column {
                width: parent.width
                spacing: 12

                Text {
                    text: "Recently Played"
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    color: "#E0E0F0"
                }

                // Horizontal scrollable ListView (Bug 1 fix)
                ListView {
                    id: recentList
                    width: parent.width
                    height: 140
                    orientation: ListView.Horizontal
                    spacing: 12
                    clip: true
                    interactive: true
                    boundsBehavior: Flickable.StopAtBounds

                    model: root.trackData

                    delegate: Rectangle {
                        width: 120
                        height: 136
                        radius: 12
                        color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.08)

                        Rectangle {
                            anchors.fill: parent
                            radius: 12
                            color: Qt.rgba(1, 1, 1, 0.04)
                            opacity: recentHover.containsMouse ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }

                        Column {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8

                            // Art thumbnail
                            Rectangle {
                                width: parent.width
                                height: parent.width
                                radius: 8
                                color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.20)

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.title.charAt(0).toUpperCase()
                                    font.pixelSize: 24
                                    font.weight: Font.DemiBold
                                    color: Qt.rgba(1, 1, 1, 0.30)
                                }
                            }

                            // Title
                            Text {
                                width: parent.width
                                text: modelData.title
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                color: "#F0F0FF"
                                elide: Text.ElideRight
                                lineHeight: 1.2
                                maximumLineCount: 1
                            }

                            // Artist
                            Text {
                                width: parent.width
                                text: modelData.artist
                                font.pixelSize: 10
                                color: Qt.rgba(1, 1, 1, 0.45)
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: recentHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.trackClicked(index)
                        }
                    }

                    ScrollBar.horizontal: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        height: 3
                        background: Rectangle { color: "transparent" }
                        contentItem: Rectangle { radius: 1.5; color: Qt.rgba(1, 1, 1, 0.12) }
                    }
                }
            }

            // === HAIRLINE DIVIDER ===
            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(1, 1, 1, 0.05)
            }

            // === QUICK PICKS ===
            Column {
                width: parent.width
                spacing: 12

                Text {
                    text: "Quick Picks"
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    color: "#E0E0F0"
                }

                // Reflowing grid: Flow fills then wraps
                Flow {
                    id: quickPicksFlow
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: root.trackData

                        delegate: Rectangle {
                            width: (quickPicksFlow.width - 10) / 2
                            height: 56
                            radius: 10
                            color: "transparent"
                            border.color: Qt.rgba(1, 1, 1, 0.06)
                            border.width: 1

                            Rectangle {
                                anchors.fill: parent
                                radius: 10
                                color: Qt.rgba(1, 1, 1, 0.03)
                                opacity: pickHover.containsMouse ? 1.0 : 0.0
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                            }

                            Row {
                                anchors.fill: parent
                                anchors.margins: 1
                                spacing: 8

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 44; height: 44
                                    radius: 8
                                    color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.20)

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.title.charAt(0).toUpperCase()
                                        font.pixelSize: 18
                                        color: Qt.rgba(1, 1, 1, 0.35)
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 60
                                    spacing: 2

                                    Text {
                                        width: parent.width
                                        text: modelData.title
                                        font.pixelSize: 12
                                        font.weight: Font.DemiBold
                                        color: "#F0F0FF"
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        width: parent.width
                                        text: modelData.artist
                                        font.pixelSize: 10
                                        color: Qt.rgba(1, 1, 1, 0.45)
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            MouseArea {
                                id: pickHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.trackClicked(index)
                            }
                        }
                    }
                }
            }

            // Bottom spacer
            Item { width: 1; height: 16 }
        }
    }
}
