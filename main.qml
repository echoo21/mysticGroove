import QtQuick
import QtQuick.Controls
import QtQuick.Window
import "component/background" as Background
import "component/views" as Views
import "component/player" as Player
import "component/nav" as Nav

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
    property real position: 0.0
    property real currentTime: 0.0
    property color currentAccent: "#A855F7"
    property bool trackEnded: false

    // ============================================================
    // NAVIGATION STATE
    // ============================================================
    property string currentPage: "home"      // home | search | library | nowPlaying | queue
    property int tabIndex: 0

    function navigateTo(page) {
        if (page === "home")  { tabIndex = 0; currentPage = "home" }
        if (page === "search") { tabIndex = 1; currentPage = "search" }
        if (page === "library") { tabIndex = 2; currentPage = "library" }
        if (page === "nowPlaying") { currentPage = "nowPlaying" }
        if (page === "queue") { currentPage = "queue" }
    }

    function navigateBack() {
        if (currentPage === "queue") {
            currentPage = "nowPlaying"
        } else if (currentPage === "nowPlaying") {
            navigateTo(tabIndex === 0 ? "home" : tabIndex === 1 ? "search" : "library")
        }
    }

    // ============================================================
    // MOCK TRACK DATA
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
    // PLAYBACK SIMULATION TIMER
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
            if (position >= 1.0) {
                if (repeatActive) {
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
            var n
            do { n = Math.floor(Math.random() * trackData.length) }
            while (n === currentTrackIndex && trackData.length > 1)
            playTrack(n)
        } else {
            playTrack((currentTrackIndex + 1) % trackData.length)
        }
    }

    function previousTrack() {
        if (currentTime > 3) {
            currentTime = 0; position = 0; return
        }
        playTrack((currentTrackIndex - 1 + trackData.length) % trackData.length)
    }

    function togglePlayPause() { isPlaying = !isPlaying }

    // ============================================================
    // AURORA BACKGROUND
    // ============================================================
    Background.AuroraShader {
        anchors.fill: parent
        animated: Qt.application.animationEnabled !== undefined ? Qt.application.animationEnabled : true
    }

    Background.AuroraParticles {
        anchors.fill: parent
        z: 1
        animated: Qt.application.animationEnabled !== undefined ? Qt.application.animationEnabled : true
    }

    // ============================================================
    // MAIN CONTENT AREA (Tab pages — home / search / library)
    // ============================================================
    Item {
        id: contentArea
        anchors.top: parent.top
        anchors.bottom: chromeArea.top
        anchors.left: parent.left
        anchors.right: parent.right
        visible: currentPage === "home" || currentPage === "search" || currentPage === "library"
        z: 2
        clip: true

        // Home
        Views.HomeView {
            id: homeView
            anchors.fill: parent
            opacity: tabIndex === 0 ? 1.0 : 0.0
            visible: opacity > 0
            accentColor: window.currentAccent
            trackData: window.trackData
            currentTrackIndex: window.currentTrackIndex
            isPlaying: window.isPlaying
            onTrackClicked: (idx) => { playTrack(idx); navigateTo("nowPlaying") }
        }

        // Search
        Views.SearchView {
            id: searchView
            anchors.fill: parent
            opacity: tabIndex === 1 ? 1.0 : 0.0
            visible: opacity > 0
            accentColor: window.currentAccent
            trackData: window.trackData
            currentTrackIndex: window.currentTrackIndex
            isPlaying: window.isPlaying
            onTrackClicked: (idx) => { playTrack(idx); navigateTo("nowPlaying") }
        }

        // Library
        Views.LibraryView {
            id: libraryView
            anchors.fill: parent
            opacity: tabIndex === 2 ? 1.0 : 0.0
            visible: opacity > 0
            accentColor: window.currentAccent
            trackData: window.trackData
            currentTrackIndex: window.currentTrackIndex
            isPlaying: window.isPlaying
            onTrackClicked: (idx) => { playTrack(idx); navigateTo("nowPlaying") }
            onPlaylistClicked: (name, items) => {
                playlistView.playlistTitle = name
                navigateTo("queue")
            }
        }

        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    // Sembunyikan contentArea + chromeArea (TabBar + MiniPlayer) saat sheet aktif
    // agar tidak numpuk di belakang NowPlayingView/PlaylistView.
    // Binding dilakukan deklaratif di masing-masing Item.

    // ============================================================
    // CHROME AREA (TabBar + MiniPlayer)
    // ============================================================
    Item {
        id: chromeArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: currentPage === "home" || currentPage === "search" || currentPage === "library"
        z: 4
        height: tabBar.height + (miniPlayer.visible ? miniPlayer.height : 0)

        // Mini Player
        Player.MiniPlayer {
            id: miniPlayer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: tabBar.top
            height: 64
            visible: currentTrackIndex >= 0
                && currentPage !== "nowPlaying"
                && currentPage !== "queue"

            accentColor: window.currentAccent
            songTitle: window.currentTitle()
            artist: window.currentArtist()
            artSource: window.currentArt()
            isPlaying: window.isPlaying
            position: window.position
            duration: window.currentDuration()

            onExpandClicked: navigateTo("nowPlaying")
            onPlayPauseClicked: window.togglePlayPause()
            onNextClicked: window.nextTrack()
        }

        // Tab Bar
        Nav.TabBar {
            id: tabBar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 52
            accentColor: window.currentAccent
            currentIndex: tabIndex
            onTabClicked: (idx) => {
                tabIndex = idx
                var pages = ["home", "search", "library"]
                currentPage = pages[idx]
            }
        }
    }

    // ============================================================
    // NOW PLAYING VIEW (sheet — covers everything)
    // ============================================================
    Views.NowPlayingView {
        id: nowPlayingView
        // anchors.left/right aman dipakai karena y yang dianimasi (tidak konflik horizontal)
        anchors.left: parent.left
        anchors.right: parent.right
        y: currentPage === "nowPlaying" ? 0 : parent.height
        height: parent.height
        visible: currentPage === "nowPlaying"
        z: 10

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
            window.position = value
            window.currentTime = value * currentDuration()
        }
        onNavigateToQueue:   navigateTo("queue")
        onNavigateBack:      navigateBack()
        onVolumeAdjusted: (v) => { /* TODO: connect to audio backend volume */ }

        Behavior on y {
            NumberAnimation { duration: 450; easing.type: Easing.OutCubic }
        }
    }

    // ============================================================
    // PLAYLIST / QUEUE VIEW (covers nowPlaying)
    // ============================================================
    Views.PlaylistView {
        id: playlistView
        // NOTE: anchors.left/right TIDAK dipakai karena akan konflik dengan x yang dianimasi
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
        x: currentPage === "queue" ? 0 : parent.width
        visible: currentPage === "queue"
        z: 20

        accentColor: window.currentAccent
        isPlaying: window.isPlaying
        currentTrackIndex: window.currentTrackIndex
        playlistData: window.trackData

        onBackToPlayer: navigateBack()
        onTrackSelected: (idx) => {
            playTrack(idx)
            currentPage = "nowPlaying"
        }

        Behavior on x {
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
        }
    }

    // ============================================================
    // LIFECYCLE
    // ============================================================
    Component.onCompleted: {
        currentAccent = trackData[0].accent
        currentTime = 0
        position = 0
    }

    onActiveChanged: {
        if (!active && isPlaying) { /* optionally pause */ }
    }
}
