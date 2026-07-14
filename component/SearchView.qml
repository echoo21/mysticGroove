import QtQuick
import QtQuick.Controls
import "."

/**
 * Search screen — styled search field, genre grid (idle), filtered results (typing).
 * Responsive layout with max-width cap.
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

    Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

    // Mock genre data
    property var genres: [
        { name: "Electronic",   color: "#A855F7", icon: "♫" },
        { name: "Ambient",      color: "#06B6D4", icon: "♩" },
        { name: "Synthwave",    color: "#F43F5E", icon: "♬" },
        { name: "Lo-Fi",        color: "#10B981", icon: "♪" },
        { name: "Jazz",         color: "#F59E0B", icon: "♫" },
        { name: "Classical",    color: "#8B5CF6", icon: "♩" }
    ]

    Flickable {
        id: searchFlick
        anchors.fill: parent
        contentHeight: searchColumn.height + 80
        clip: true
        topMargin: 16
        bottomMargin: 16

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded; width: 4
            background: Rectangle { color: "transparent" }
            contentItem: Rectangle { radius: 2; color: Qt.rgba(1, 1, 1, 0.12) }
        }

        Column {
            id: searchColumn
            width: parent.width
            spacing: 20

            // === Max-width wrapper ===
            Item {
                width: 1
                height: 1
                visible: false
            }

            // === SEARCH FIELD ===
            Rectangle {
                id: searchFieldBg
                width: {
                    var maxW = Math.min(parent.width, 800)
                    return Math.max(parent.width - sideMargins * 2, maxW - sideMargins * 2)
                }
                property real sideMargins: Math.max(16, (parent.width - Math.min(parent.width, 800)) * 0.3)
                x: sideMargins

                height: 44
                radius: 12
                color: Qt.rgba(1, 1, 1, 0.08)
                border.color: searchInput.activeFocus
                    ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.30)
                    : Qt.rgba(1, 1, 1, 0.06)
                border.width: 1

                Behavior on border.color { ColorAnimation { duration: 200 } }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 10

                    PlayerIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        iconName: "search"
                        iconSize: 18
                        color: searchInput.activeFocus
                            ? root.accentColor
                            : Qt.rgba(1, 1, 1, 0.35)

                        Behavior on color { ColorAnimation { duration: 200 } }
                    }

                    TextField {
                        id: searchInput
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 42
                        placeholderText: "What do you want to listen to?"
                        placeholderTextColor: Qt.rgba(1, 1, 1, 0.30)
                        color: "#F0F0FF"
                        font.pixelSize: 14
                        background: Item {}
                        selectByMouse: true
                        verticalAlignment: TextInput.AlignVCenter
                    }
                }

                // Clear button (≥44px tap target)
                PlayerIcon {
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    iconName: "chevronDown"
                    iconSize: 16
                    color: Qt.rgba(1, 1, 1, 0.25)
                    rotation: searchInput.text.length > 0 ? 180 : 0
                    visible: searchInput.text.length > 0

                    Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    // Expanded tap target
                    Rectangle {
                        anchors.centerIn: parent
                        width: Math.max(44, parent.width + 16)
                        height: Math.max(44, parent.height + 16)
                        radius: 22
                        color: "transparent"

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                searchInput.text = ""
                                searchInput.focus = true
                            }
                        }
                    }
                }
            }

            // === RESULTS or GENRES ===
            Item {
                width: 1
                height: 1
                visible: false  // spacer elimination
            }

            // Search results (filtered trackData)
            Column {
                width: searchFieldBg.width
                x: searchFieldBg.x
                spacing: 4
                visible: searchInput.text.trim().length > 0

                Text {
                    text: "Results"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: "#E0E0F0"
                    leftPadding: 4
                    bottomPadding: 4
                }

                Repeater {
                    model: {
                        var q = searchInput.text.trim().toLowerCase()
                        if (q.length === 0) return []
                        var results = []
                        for (var i = 0; i < root.trackData.length; i++) {
                            var t = root.trackData[i]
                            if (t.title.toLowerCase().indexOf(q) >= 0
                                || t.artist.toLowerCase().indexOf(q) >= 0) {
                                results.push(i)
                            }
                        }
                        return results
                    }

                    delegate: QueueItem {
                        width: parent.width
                        songTitle: root.trackData[modelData].title
                        artist: root.trackData[modelData].artist
                        duration: formatDuration(root.trackData[modelData].duration)
                        artSource: root.trackData[modelData].art || ""
                        accentColor: root.accentColor
                        isPlaying: root.isPlaying
                        isCurrentTrack: modelData === root.currentTrackIndex
                        listIndex: modelData

                        onClicked: root.trackClicked(modelData)
                    }
                }

                // Empty results
                Text {
                    width: parent.width
                    text: "No results found"
                    font.pixelSize: 13
                    color: Qt.rgba(1, 1, 1, 0.30)
                    horizontalAlignment: Text.AlignHCenter
                    topPadding: 32
                    visible: searchInput.text.trim().length > 0
                        && (function() {
                            var q = searchInput.text.trim().toLowerCase()
                            var count = 0
                            for (var i = 0; i < root.trackData.length; i++) {
                                var t = root.trackData[i]
                                if (t.title.toLowerCase().indexOf(q) >= 0
                                    || t.artist.toLowerCase().indexOf(q) >= 0) count++
                            }
                            return count === 0
                        })()
                }
            }

            // Genre grid (visible when not searching)
            Column {
                width: searchFieldBg.width
                x: searchFieldBg.x
                spacing: 12
                visible: searchInput.text.trim().length === 0

                Text {
                    text: "Browse Genres"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: "#E0E0F0"
                    leftPadding: 4
                }

                Flow {
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: root.genres

                        delegate: Rectangle {
                            width: (parent.width - 10) / 2
                            height: 80
                            radius: 12
                            color: Qt.rgba(modelData.color.r, modelData.color.g, modelData.color.b, 0.12)
                            border.color: Qt.rgba(modelData.color.r, modelData.color.g, modelData.color.b, 0.15)
                            border.width: 1

                            Rectangle {
                                anchors.fill: parent
                                radius: 12
                                color: Qt.rgba(1, 1, 1, 0.04)
                                opacity: genreHover.containsMouse ? 1.0 : 0.0
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                            }

                            Column {
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.icon
                                    font.pixelSize: 28
                                    color: modelData.color
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.name
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    color: "#F0F0FF"
                                }
                            }

                            MouseArea {
                                id: genreHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    // Fill search with genre name as a starting point
                                    searchInput.text = modelData.name.toLowerCase()
                                    searchInput.focus = true
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

    function formatDuration(sec) {
        if (typeof sec === "string") return sec
        if (sec <= 0 || isNaN(sec)) return "0:00"
        var m = Math.floor(sec / 60)
        var s = Math.floor(sec % 60)
        return m + ":" + (s < 10 ? "0" : "") + s
    }
}
