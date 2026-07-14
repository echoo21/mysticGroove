import QtQuick
import QtQuick.Controls

/**
 * Custom seek slider with time labels, accent-colored progress, draggable/groovable.
 * Uses QQC2 Slider internally for accessibility, but fully styled with glass aesthetic.
 *
 * TODO: Connect position updates from backend - set position externally via value property.
 * TODO: Connect seek requests - listen to moved() signal for user-seeking.
 */
Item {
    id: root

    property color accentColor: "#A855F7"
    property real position: 0.0        // 0.0 – 1.0, set externally
    property real duration: 0.0        // seconds, set externally
    property real currentTime: 0.0     // seconds, derived from position×duration unless set directly
    property string labelCurrent: "0:00"
    property string labelTotal: "0:00"
    property bool userInteracting: slider.pressed

    signal moved(real value)        // User dragged seekbar — value 0.0–1.0
    signal wasDragged()

    implicitHeight: 44
    implicitWidth: 300

    // Update labels when position/duration changes (if not being dragged by user)
    onPositionChanged: { if (!slider.pressed) slider.value = position; updateLabels() }
    onDurationChanged: updateLabels()
    function updateLabels() {
        var cur = currentTime || (position * duration)
        var tot = duration
        labelCurrent = formatTime(cur)
        labelTotal = formatTime(tot)
    }

    function formatTime(sec) {
        if (sec <= 0 || isNaN(sec)) return "0:00"
        var m = Math.floor(sec / 60)
        var s = Math.floor(sec % 60)
        return m + ":" + (s < 10 ? "0" : "") + s
    }

    // Current time label
    Text {
        id: timeLeft
        anchors.left: parent.left
        anchors.bottom: sliderRow.top
        anchors.bottomMargin: 4
        text: root.labelCurrent
        color: Qt.rgba(1, 1, 1, 0.60)
        font.pixelSize: 11
        font.letterSpacing: 0.4
    }

    // Total time label
    Text {
        id: timeTotal
        anchors.right: parent.right
        anchors.bottom: sliderRow.top
        anchors.bottomMargin: 4
        text: root.labelTotal
        color: Qt.rgba(1, 1, 1, 0.40)
        font.pixelSize: 11
        font.letterSpacing: 0.4
    }

    // The slider row
    Item {
        id: sliderRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 6
        height: 18
        clip: true

        Slider {
            id: slider
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 0
            from: 0.0
            to: 1.0
            value: root.position
            stepSize: 0.001

            background: Item {
                anchors.fill: parent

                // Track background
                Rectangle {
                    id: trackBg
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 4
                    radius: 2
                    color: Qt.rgba(1, 1, 1, 0.10)

                    // Progress fill
                    Rectangle {
                        id: trackFill
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: slider.visualPosition * parent.width
                        height: 4
                        radius: 2

                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: root.accentColor }
                            GradientStop { position: 1.0; color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.70) }
                        }
                    }
                }
            }

            handle: Item {
                x: slider.visualPosition * (slider.availableWidth) - width / 2
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: slider.pressed ? 16 : 12
                height: slider.pressed ? 16 : 12

                Behavior on width { NumberAnimation { duration: 150 } }
                Behavior on height { NumberAnimation { duration: 150 } }

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: slider.pressed
                        ? Qt.rgba(1, 1, 1, 1)
                        : Qt.rgba(1, 1, 1, 0.85)
                    border.color: root.accentColor
                    border.width: slider.pressed ? 3 : 2

                    // Outer glow ring
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width + 8; height: parent.height + 8
                        radius: width / 2
                        color: "transparent"
                        border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.30)
                        border.width: 1
                        visible: slider.pressed
                    }
                }
            }

            onMoved: {
                root.position = value
                root.moved(value)
            }
        }
    }

    // Tick marks (optional, subtle)
    Repeater {
        model: 10
        delegate: Rectangle {
            anchors.bottom: sliderRow.verticalCenter
            anchors.bottomMargin: 2
            x: sliderRow.x + (index / 9) * sliderRow.width - 1
            width: 2; height: 3; radius: 1
            color: Qt.rgba(1, 1, 1, 0.08)
        }
    }
}
