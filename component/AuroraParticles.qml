import QtQuick

Item {
    id: root
    property bool animated: Qt.application.animationEnabled !== undefined ? Qt.application.animationEnabled : true
    readonly property var colors: ["#A855F7", "#06B6D4", "#F43F5E", "#8B5CF6", "#22D3EE"]
    property real mouseX: -9999
    property real mouseY: -9999

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        onPositionChanged: (mouse) => { root.mouseX = mouse.x; root.mouseY = mouse.y; }
        onExited: { root.mouseX = -9999; root.mouseY = -9999; }
    }

    Repeater {
        id: repeater
        model: 40
        Item {
            id: p
            property real px: Math.random() * root.width
            property real py: Math.random() * root.height
            property real vx: (Math.random() - 0.5) * 0.3
            property real vy: -(0.2 + Math.random() * 0.4)
            property real sz: 1.5 + Math.random() * 2.5
            property color col: root.colors[Math.floor(Math.random() * root.colors.length)]
            property real repelDist: 80 + Math.random() * 120

            x: px; y: py; opacity: 0

            Rectangle {
                width: parent.sz; height: parent.sz
                radius: width / 2; color: parent.col
                opacity: 0.4 + Math.random() * 0.3
            }
            Rectangle {
                width: parent.sz * 4; height: parent.sz * 4
                radius: width / 2; color: "transparent"
                border.color: parent.col; border.width: 0.5
                opacity: 0.1
                x: -width/2 + parent.sz/2; y: -height/2 + parent.sz/2
            }

            Timer {
                interval: 50; running: root.animated; repeat: true
                onTriggered: {
                    var dx = root.mouseX - (p.px + p.sz/2);
                    var dy = root.mouseY - (p.py + p.sz/2);
                    var dist = Math.sqrt(dx*dx + dy*dy);
                    if (dist < p.repelDist && dist > 1) {
                        var force = (p.repelDist - dist) / p.repelDist * 0.15;
                        p.vx -= (dx / dist) * force;
                        p.vy -= (dy / dist) * force;
                    }
                    p.px += p.vx; p.py += p.vy;
                    p.vx *= 0.985; p.vy = Math.max(p.vy, -0.6);
                    var fadeIn = Math.min(1, (root.height - p.py) / root.height * 2.5);
                    var fadeOut = Math.min(1, p.py / root.height * 2);
                    var mouseGlow = dist < p.repelDist ? 1.2 : 1.0;
                    p.opacity = fadeIn * fadeOut * 0.5 * mouseGlow;
                    if (p.py < -20) { p.py = root.height + 5; p.px = Math.random() * root.width; p.vx = (Math.random() - 0.5) * 0.3; }
                    if (p.px < -30) p.px = root.width + 20;
                    if (p.px > root.width + 30) p.px = -20;
                }
            }
            Timer {
                interval: 3000 + Math.random() * 5000
                running: root.animated; repeat: true
                onTriggered: { p.px = Math.random() * root.width; p.py = root.height + 5; }
            }
        }
    }
    onWidthChanged: {
        for (var i = 0; i < repeater.count; i++) {
            var item = repeater.itemAt(i);
            if (item && item.px > root.width) item.px = Math.random() * root.width;
        }
    }
}
