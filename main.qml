import QtQuick
import QtQuick.Controls
import QtQuick.Window
import "component" as MyComponents

Window {
    id: window
    minimumWidth: 360; minimumHeight: 500
    width: 480; height: 860
    visible: true
    title: "Mystic Groove"

    // Aurora background (GPU shader)
    MyComponents.AuroraShader {
        anchors.fill: parent
        animated: Qt.application.animationEnabled !== undefined ? Qt.application.animationEnabled : true
    }

    MyComponents.AuroraParticles {
        anchors.fill: parent
        z: 1
        animated: Qt.application.animationEnabled !== undefined ? Qt.application.animationEnabled : true
    }

    Flickable {
        id: flick
        anchors.fill: parent
        contentHeight: column.height + 60
        clip: true; topMargin: 20; bottomMargin: 20
        leftMargin: Math.max(16, (parent.width - Math.min(parent.width, 800)) * 0.3)
        rightMargin: Math.max(16, (parent.width - Math.min(parent.width, 800)) * 0.3)

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded; width: 4
            background: Rectangle { color: "transparent" }
            contentItem: Rectangle { radius: 2; color: Qt.rgba(1, 1, 1, 0.15) }
        }

        Column {
            id: column
            width: flick.width - flick.leftMargin - flick.rightMargin
            spacing: 12

            Text { id: header; text: "✨ Mystic Groove"; font.pixelSize: 28; font.bold: true; color: "#FFFFFF"; anchors.horizontalCenter: parent.horizontalCenter }
            Text { text: "Modern UI dengan Qt Quick"; font.pixelSize: 14; color: "#A0A0C0"; anchors.horizontalCenter: parent.horizontalCenter; anchors.bottomMargin: 8 }

            Flow {
                id: cardFlow; width: parent.width; spacing: 16

                MyComponents.GlassCard {
                    id: card1; title: "Qt Quick"; subtitle: "Framework UI deklaratif"
                    description: "Bikin antarmuka modern dengan QML — mirip JSON + JavaScript, render native."
                    accentColor: "#A855F7"; entranceDelay: 300
                    onClicked: card1Desc.visible = !card1Desc.visible
                }
                Text { id: card1Desc; text: "► Komponen reusable dipisah di file sendiri, tinggal import dan pake."; color: "#A0A0C0"; font.pixelSize: 12; wrapMode: Text.WordWrap; width: card1.width; visible: false }

                MyComponents.GlassCard {
                    id: card2; title: "C++ Backend"; subtitle: "Logika native"
                    description: "Kinerja tinggi untuk kalkulasi, akses file, hardware, database."
                    accentColor: "#06B6D4"; entranceDelay: 500
                    onClicked: card2Desc.visible = !card2Desc.visible
                }
                Text { id: card2Desc; text: "► C++ di backend, panggil dari QML via Q_INVOKABLE."; color: "#A0A0C0"; font.pixelSize: 12; wrapMode: Text.WordWrap; width: card2.width; visible: false }

                MyComponents.GlassCard {
                    id: card3; title: "Qt Quick Controls"; subtitle: "Komponen siap pakai"
                    description: "Button, Slider, Dialog, Drawer — pustaka lengkap untuk antarmuka native."
                    accentColor: "#F43F5E"; entranceDelay: 700
                    onClicked: card3Desc.visible = !card3Desc.visible
                }
                Text { id: card3Desc; text: "► Tinggal panggil Controls.Button {} — tampilannya sudah native."; color: "#A0A0C0"; font.pixelSize: 12; wrapMode: Text.WordWrap; width: card3.width; visible: false }
            }
        }
    }
}
