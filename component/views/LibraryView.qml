import QtQuick
import QtQuick.Controls
import "../player"

/**
 * Library screen — mock playlists and collections.
 * Items navigate to PlaylistView on tap.
 * Responsive layout with reflowing grid for larger screens.
 *
 * TODO: Replace mock playlistData with real backend model.
 */
Item {
    id: root

    property color accentColor: "#A855F7"
    property var trackData: []
    property int currentTrackIndex: -1
    property bool isPlaying: false

    signal playlistClicked(string name, var items)
    signal trackClicked(int index)

    Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

    // Mock library data
    property var librarySections: [
        {
            name: "Playlists",
            items: [
                { title: "Liked Songs", itemCount: 10, art: "", accent: "#A855F7" },
                { title: "Recently Added", itemCount: 10, art: "", accent: "#06B6D4" },
                { title: "Chill Vibes", itemCount: 4, art: "", accent: "#10B981" },
                { title: "Late Night Drive", itemCount: 3, art: "", accent: "#F43F5E" },
                { title: "Focus Mode", itemCount: 5, art: "", accent: "#F59E0B" }
            ]
        }
    ]

    Flickable {
        id: libraryFlick
        anchors.fill: parent
        contentHeight: libraryColumn.height + 80
        clip: true
        topMargin: 16
        bottomMargin: 16

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded; width: 4
            background: Rectangle { color: "transparent" }
            contentItem: Rectangle { radius: 2; color: Qt.rgba(1, 1, 1, 0.12) }
        }

        Column {
            id: libraryColumn
            width: parent.width
            spacing: 24

            // === HEADER ===
            Text {
                text: "Your Library"
                font.pixelSize: 28
                font.weight: Font.Bold
                color: "#F0F0FF"
                leftPadding: sideMargins
                rightPadding: sideMargins
                property real sideMargins: Math.max(16, (parent.width - Math.min(parent.width, 800)) * 0.3)
            }

            // Library sections
            Repeater {
                model: root.librarySections

                Column {
                    width: libraryColumn.width
                    spacing: 12

                    property real sideMargins: Math.max(16, (parent.width - Math.min(parent.width, 800)) * 0.3)

                    // Section header
                    Text {
                        text: modelData.name
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        color: "#E0E0F0"
                        leftPadding: sideMargins
                        rightPadding: sideMargins
                    }

                    // Section items (responsive grid)
                    Flow {
                        width: parent.width
                        leftPadding: sideMargins
                        rightPadding: sideMargins
                        spacing: 10

                        Repeater {
                            model: modelData.items

                            delegate: Rectangle {
                                width: {
                                    var parentW = parent.width - parent.leftPadding - parent.rightPadding
                                    if (parentW < 400) return parentW
                                    return (parentW - 10) / 2
                                }
                                height: width + 40
                                radius: 12
                                color: Qt.rgba(modelData.accent.r, modelData.accent.g, modelData.accent.b, 0.10)
                                border.color: Qt.rgba(modelData.accent.r, modelData.accent.g, modelData.accent.b, 0.12)
                                border.width: 1

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 12
                                    color: Qt.rgba(1, 1, 1, 0.03)
                                    opacity: libHover.containsMouse ? 1.0 : 0.0
                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                }

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 8

                                    // Art placeholder
                                    Rectangle {
                                        width: parent.width
                                        height: parent.width
                                        radius: 10
                                        color: Qt.rgba(modelData.accent.r, modelData.accent.g, modelData.accent.b, 0.20)

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.title.charAt(0).toUpperCase()
                                            font.pixelSize: Math.min(parent.width, 80) * 0.4
                                            font.weight: Font.DemiBold
                                            color: Qt.rgba(modelData.accent.r, modelData.accent.g, modelData.accent.b, 0.40)
                                        }
                                    }

                                    Text {
                                        width: parent.width
                                        text: modelData.title
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                        color: "#F0F0FF"
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        width: parent.width
                                        text: modelData.itemCount + " songs"
                                        font.pixelSize: 11
                                        color: Qt.rgba(1, 1, 1, 0.40)
                                        elide: Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    id: libHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.playlistClicked(modelData.title, root.trackData)
                                    }
                                }
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
