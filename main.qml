import QtQuick
import QtQuick.Controls
import QtQuick.Window

// Import komponen buatan sendiri
import "component" as MyComponents

Window {
    id: window
    width: 480; height: 860
    visible: true
    title: "Mystic Groove"

    // Aurora background
    MyComponents.AuroraBackground {
        anchors.fill: parent
    }

    // Header
    Text {
        id: header
        text: "✨ Mystic Groove"
        font.pixelSize: 28
        font.bold: true
        color: "#FFFFFF"
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 40
        }
    }

    Text {
        text: "Modern UI dengan Qt Quick"
        font.pixelSize: 14
        color: "#A0A0C0"
        anchors {
            top: header.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: 6
        }
    }

    // Glass Card 1
    MyComponents.GlassCard {
        id: card1
        title: "Qt Quick"
        subtitle: "Framework UI deklaratif"
        description: "Bikin antarmuka modern dengan QML — mirip JSON + JavaScript, render native."
        accentColor: "#A855F7"
        anchors {
            top: header.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: 60
        }

        onClicked: card1Desc.visible = !card1Desc.visible
    }

    Text {
        id: card1Desc
        text: "► Komponen reusable dipisah di file sendiri, tinggal import dan pake."
        color: "#A0A0C0"
        font.pixelSize: 12
        wrapMode: Text.WordWrap
        width: card1.width
        visible: false
        anchors {
            top: card1.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: 8
        }
    }

    MyComponents.GlassCard {
        id: card2
        title: "C++ Backend"
        subtitle: "Logika native"
        description: "Kinerja tinggi untuk kalkulasi, akses file, hardware, database."
        accentColor: "#06B6D4"
        anchors {
            top: card1Desc.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: 24
        }

        onClicked: card2Desc.visible = !card2Desc.visible
    }

    Text {
        id: card2Desc
        text: "► C++ di backend, panggil dari QML via Q_INVOKABLE."
        color: "#A0A0C0"
        font.pixelSize: 12
        wrapMode: Text.WordWrap
        width: card2.width
        visible: false
        anchors {
            top: card2.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: 8
        }
    }

    MyComponents.GlassCard {
        id: card3
        title: "Qt Quick Controls"
        subtitle: "Komponen siap pakai"
        description: "Button, Slider, Dialog, Drawer — pustaka lengkap untuk antarmuka native."
        accentColor: "#F43F5E"
        anchors {
            top: card2Desc.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: 24
        }

        onClicked: card3Desc.visible = !card3Desc.visible
    }

    Text {
        id: card3Desc
        text: "► Tinggal panggil Controls.Button {} — tampilannya sudah native."
        color: "#A0A0C0"
        font.pixelSize: 12
        wrapMode: Text.WordWrap
        width: card3.width
        visible: false
        anchors {
            top: card3.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: 8
        }
    }
}