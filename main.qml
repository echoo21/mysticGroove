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

    // ============================================================
    // PLAYER STATE
    // ============================================================
    property int currentTrackIndex: 0
    property bool isPlaying: false
    property bool shuffleActive: false
    property bool repeatActive: false
    property real position: 0.0         // 0.0–1.0
    property real currentTime: 0.0      // seconds
    property color currentAccent: "#A855F7"
    property bool showingPlaylist: false
    property bool trackEnded: false

    // ============================================================
    // MOCK TRACK DATA
    // TODO: Replace with actual backend model and metadata.
    // ============================================================
    property var trackData: [
        { title: "Neon Dreams",         artist: "Mystic Groove",         duration: 272, art: "", accent: "#A855F7" },
        { title: "Aurora Borealis",     artist: "Synthwave Collective", duration: 238, art: "", accent: "#06B6D4" },
        { title: "Midnight Circuit",    artist: "Digital Horizon",      duration: 312, art: "", accent: "#F43F5E" },
        { title: "Glass Cathedral",     artist: "Ambient Souls",        duration: 405, art: "", accent: "#10B981" },
        { title: "Pixel Rain",          artist: "Retro Future",         duration: 200, art: "", accent: "#F59E0B" },
        { title: "Cosmic Drift",        artist: "Stellar Ensemble",     duration: 424, art: "", accent: "#8B5CF6" },
        { title: "Chrome Waves",        artist: "Neon Tide",            duration: 258, art: "", accent: "#EC4899" },
        { title: "Violet Echo",         artist: "Mystic Groove",        duration: 330, art: "", accent: "#14B8A6" },
        { title: "Quantum Lullaby",     artist: "Deep Frequencies",     duration: 225, art: "", accent: "#6366F1" },
        { title: "Starlight Protocol",  artist: "Digital Horizon",      duration: 382, art: "", accent: "#D946EF" }
    ]

    // Computed helpers
    function currentTrack()       { return trackData[currentTrackIndex] || trackData[0] }
    function currentTitle()       { return currentTrack().title }
    function currentArtist()      { return currentTrack().artist }
    function currentDuration()    { return currentTrack().duration }
    function currentArt()         { return currentTrack().art }

    function formatTime(sec) {
        if (sec <= 0 || isNaN(sec)) return "0:00"
        var m = Math.floor(sec / 60)
        var s = Math.floor(sec % 60)
        return m + ":" + (s < 10 ? "0" : "") + s
    }

    // ============================================================
    // PLAYBACK SIMULATION TIMER  (placeholder — backend nanti)
    // TODO: Remove this timer and connect to actual audio playback.
    // ============================================================
    Timer {
        id: playbackTimer
        interval: 250
        repeat: true
        running: window.isPlaying && Qt.application.active
        onTriggered: {
            var dur = currentDuration()
            if (dur <= 0) return

            currentTime += 0.25
            position = Math.min(currentTime / dur, 1.0)

            // Track ended
            if (position >= 1.0) {
                if (repeatActive) {
                    // Repeat one track
                    currentTime = 0
                    position = 0
                } else {
                    nextTrack()
                }
            }
        }
    }

    // ============================================================
    // TRACK NAVIGATION
    // ============================================================
    function playTrack(index) {
        if (index < 0 || index >= trackData.length) return
        currentTrackIndex = index
        currentTime = 0
        position = 0
        currentAccent = trackData[index].accent
        isPlaying = true
        trackEnded = false
    }

    function nextTrack() {
        if (shuffleActive) {
            var next
            do {
                next = Math.floor(Math.random() * trackData.length)
            } while (next === currentTrackIndex && trackData.length > 1)
            playTrack(next)
        } else {
            var idx = (currentTrackIndex + 1) % trackData.length
            playTrack(idx)
        }
    }

    function previousTrack() {
        if (currentTime > 3) {
            // Restart current track
            currentTime = 0
            position = 0
            return
        }
        var idx = (currentTrackIndex - 1 + trackData.length) % trackData.length
        playTrack(idx)
    }

    function togglePlayPause() {
        isPlaying = !isPlaying
    }

    // ============================================================
    // AURORA BACKGROUND
    // ============================================================
    MyComponents.AuroraShader {
        anchors.fill: parent
        animated: Qt.application.animationEnabled !== undefined ? Qt.application.animationEnabled : true
        // TODO: Optionally vary shader colors based on currentAccent.
    }

    MyComponents.AuroraParticles {
        anchors.fill: parent
        z: 1
        animated: Qt.application.animationEnabled !== undefined ? Qt.application.animationEnabled : true
    }

    // ============================================================
    // MAIN CONTENT
    // ============================================================
    Item {
        id: contentArea
        anchors.fill: parent
        anchors.bottomMargin: showingPlaylist ? miniPlayer.height : 0
        clip: true

        // -- NOW PLAYING VIEW --
        MyComponents.NowPlayingView {
            id: nowPlayingView
            x: 0
            y: 0
            width: contentArea.width
            height: contentArea.height

            accentColor: window.currentAccent
            trackTitle: window.currentTitle()
            trackArtist: window.currentArtist()
            albumArt: window.currentArt()
            isPlaying: window.isPlaying
            position: window.position
            currentTime: window.currentTime
            duration: window.currentDuration()
            shuffleActive: window.shuffleActive
            repeatActive: window.repeatActive

            onPlayPauseClicked:  window.togglePlayPause()
            onNextClicked:       window.nextTrack()
            onPreviousClicked:   window.previousTrack()
            onShuffleClicked:    window.shuffleActive = !window.shuffleActive
            onRepeatClicked:     window.repeatActive = !window.repeatActive
            onSeeked: (value) => {
                // TODO: Connect seek to actual audio backend
                window.position = value
                window.currentTime = value * currentDuration()
            }
            onNavigateToQueue:   window.showingPlaylist = true
        }

        // -- PLAYLIST VIEW --
        MyComponents.PlaylistView {
            id: playlistView
            x: contentArea.width   // starts off-screen; state system manages transitions
            y: 0
            width: contentArea.width
            height: contentArea.height

            accentColor: window.currentAccent
            isPlaying: window.isPlaying
            currentTrackIndex: window.currentTrackIndex
            playlistData: window.trackData  // share same data

            onBackToPlayer: window.showingPlaylist = false
            onTrackSelected: (idx) => {
                window.playTrack(idx)
                window.showingPlaylist = false
            }
        }

        // Navigation states & transitions (Item supports these; Window does not)
        states: [
            State {
                name: "playlistView"
                when: window.showingPlaylist
                PropertyChanges { target: nowPlayingView; x: -contentArea.width * 0.15; opacity: 0.0; scale: 0.92 }
                PropertyChanges { target: playlistView; x: 0 }
            },
            State {
                name: "playerView"
                when: !window.showingPlaylist
                PropertyChanges { target: nowPlayingView; x: 0; opacity: 1.0; scale: 1.0 }
                PropertyChanges { target: playlistView; x: contentArea.width }
            }
        ]

        transitions: [
            Transition {
                from: "playerView"; to: "playlistView"
                NumberAnimation { target: nowPlayingView; property: "x"; duration: 400; easing.type: Easing.OutCubic }
                NumberAnimation { target: nowPlayingView; property: "opacity"; duration: 350; easing.type: Easing.OutCubic }
                NumberAnimation { target: nowPlayingView; property: "scale"; duration: 350; easing.type: Easing.OutCubic }
                NumberAnimation { target: playlistView; property: "x"; duration: 400; easing.type: Easing.OutCubic }
            },
            Transition {
                from: "playlistView"; to: "playerView"
                NumberAnimation { target: nowPlayingView; property: "x"; duration: 400; easing.type: Easing.OutCubic }
                NumberAnimation { target: nowPlayingView; property: "opacity"; duration: 350; easing.type: Easing.OutCubic }
                NumberAnimation { target: nowPlayingView; property: "scale"; duration: 350; easing.type: Easing.OutCubic }
                NumberAnimation { target: playlistView; property: "x"; duration: 400; easing.type: Easing.OutCubic }
            }
        ]
    }

    // ============================================================
    // MINI PLAYER
    // ============================================================
    MyComponents.MiniPlayer {
        id: miniPlayer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: window.showingPlaylist
        height: 64

        accentColor: window.currentAccent
        songTitle: window.currentTitle()
        artist: window.currentArtist()
        artSource: window.currentArt()
        isPlaying: window.isPlaying
        position: window.position
        duration: window.currentDuration()

        onExpandClicked: window.showingPlaylist = false
        onPlayPauseClicked: window.togglePlayPause()
        onNextClicked: window.nextTrack()
    }

    // ============================================================
    // LIFECYCLE
    // ============================================================
    Component.onCompleted: {
        // Initialize first track
        currentAccent = trackData[0].accent
        currentTime = 0
        position = 0
    }

    // Pause when window loses focus
    onActiveChanged: {
        if (!active && isPlaying) {
            // Optionally pause, or keep playing — let user decide later
        }
    }
}
