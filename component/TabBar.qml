import QtQuick
import "."

/**
 * Bottom tab navigation bar (Spotify/Apple Music style).
 * 3 tabs: Home, Search, Library.
 * Active tab highlighted with accentColor + indicator line.
 * Glassmorphism style consistent with the rest of the app.
 */
Item {
    id: root

    property color accentColor: "#A855F7"
    property int currentIndex: 0
    property var tabNames: ["Home", "Search", "Library"]
    property var tabIcons: ["home", "search", "library"]

    signal tabClicked(int index)

    implicitWidth: parent ? parent.width : 360
    implicitHeight: 52

    // Glass background
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(12/255, 12/255, 30/255, 0.92)

        // Thin top border
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 1
            color: Qt.rgba(1, 1, 1, 0.06)
        }
    }

    // Tab items
    Row {
        anchors.fill: parent
        anchors.topMargin: 4

        Repeater {
            model: root.tabNames.length

            Item {
                width: parent.width / root.tabNames.length
                height: parent.height

                // Active indicator line
                Rectangle {
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: root.currentIndex === index ? 20 : 0
                    height: 2
                    radius: 1
                    color: root.accentColor
                    opacity: root.currentIndex === index ? 1.0 : 0.0

                    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 2

                    PlayerIcon {
                        iconName: root.tabIcons[index]
                        iconSize: 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: root.currentIndex === index
                            ? root.accentColor
                            : Qt.rgba(1, 1, 1, 0.45)

                        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.tabNames[index]
                        font.pixelSize: 10
                        font.weight: root.currentIndex === index ? Font.DemiBold : Font.Normal
                        color: root.currentIndex === index
                            ? root.accentColor
                            : Qt.rgba(1, 1, 1, 0.40)

                        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    }
                }

                // Hit area (≥44px touch target)
                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.currentIndex !== index) {
                            root.tabClicked(index)
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: 4
                        color: Qt.rgba(1, 1, 1, 0.04)
                        opacity: hoverArea.containsMouse ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }
                }
            }
        }
    }
}
