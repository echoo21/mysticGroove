# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build System

```bash
# Configure & build
cmake -B build
cmake --build build

# Quick QML-only preview (no C++ build needed)
qml main.qml

# Run with Basic QQC2 style (required for Slider customization)
QT_QUICK_CONTROLS_STYLE=Basic qml main.qml

# Full build with style hardcoded (via QQuickStyle::setStyle("Basic") in main.cpp)
./build/mysticGroove.app/Contents/MacOS/mysticGroove

# Regenerate compile_commands.json for clangd
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

### Dependencies
- **Qt6** (via Homebrew): `Qt6::Quick`, `Qt6::QuickControls2`, `Qt6::Qml`
- **Qt5Compat.GraphicalEffects** (used by GlassCard for blur/linear gradients)
- macOS only: `MACOSX_BUNDLE TRUE`, `OUTPUT_NAME "mysticGroove"` (target tetap `mysticGrooveApp` untuk hindari bentrok case-insensitive dengan URI `MysticGroove`)

## Architecture

### QML Module Structure
```
MysticGroove/                  # QML module URI (case-sensitive)
├── main.qml                   # App shell: window, player state, navigation, shaders
├── component/
│   ├── AuroraShader.qml       # GPU shader-based aurora background (fragment shader)
│   ├── AuroraParticles.qml    # Floating particle overlay on aurora
│   ├── AuroraBackground.qml   # Fallback gradient background (no GPU)
│   ├── GlassCard.qml          # Reusable frosted glass card with shimmer, tilt-on-hover
│   ├── GlassButton.qml        # Reusable glass button with gradient fill
│   ├── PlayerIconButton.qml   # Circular glass icon button (play/prev/next/shuffle/repeat)
│   ├── AlbumArtDisplay.qml    # Album art with rotation animation + gradient fallback
│   ├── SeekBar.qml            # Custom seek slider with time labels, drag interaction
│   ├── PlayerControls.qml     # Transport row: shuffle-prev-play-next-repeat
│   ├── MiniPlayer.qml         # Sticky compact player bar (shown during playlist view)
│   ├── NowPlayingView.qml     # Full player screen: art, info, seek, controls, volume, queue btn
│   ├── PlaylistView.qml       # Playlist screen with scrollable queue items + back nav
│   ├── QueueItem.qml          # Single playlist row: thumbnail, title, artist, duration, highlight
│   └── aurora.frag.qsb        # Pre-compiled GLSL shader (in RESOURCES, not QML_FILES)
├── CMakeLists.txt
├── main.cpp                   # QGuiApplication + QQmlApplicationEngine + QQuickStyle::setStyle
└── CLAUDE.md
```

### Key Architecture Decisions

1. **C++ is backend-only**: `main.cpp` creates the app and engine. All UI lives in QML. C++ classes (future) expose `QObject`-derived types via `qmlRegisterType` or `contextProperty` for audio playback, file scanning, DSP, etc.

2. **No audio backend yet**: All `TODO: Connect to backend` signals are defined and ready. `main.qml` has a fake `Timer` simulating playback position at 250ms intervals — replace with a real `MusicEngine` C++ class.

3. **Shaders untouched by convention**: `AuroraShader.qml`, `AuroraParticles.qml`, `AuroraBackground.qml` contain GPU/GL logic marked "JANGAN diubah/dihapus logic shader-nya".

4. **Enter animation pattern**: Components use `entranceDelay` + `Component.onCompleted` timer + `Behavior on opacity`/`Behavior on scale` for staggered entrance sequences.

5. **Accent color system**: Every component accepts `accentColor: color`. Track data includes per-song accent colors that propagate through the UI. Future themes can be done by swapping accent palettes.

6. **Navigation**: `main.qml` uses QML `states`/`transitions` on the contentArea `Item` (not Window — Window doesn't support these). NowPlaying ↔ Playlist transitions use slide/fade/scale with cubic easing.

7. **Volume state**: `NowPlayingView.volume` is local state. Collapse/expand animation with Behavior on height.

### Navigation Flow
```
NowPlayingView  ──navigateToQueue──>  PlaylistView
    ↑                                     │
    └──(tap mini player)──── backToPlayer ┘
    └──(open from mini player)────────────┘
```

## Important Patterns

- **QQC2 Style**: Uses `Basic` style (set in `main.cpp`) to allow Slider background/handle customization. Default macOS style doesn't support custom Slider parts.
- **Mock data**: `trackData` in `main.qml` (10 songs) is the single source of truth. `PlaylistView.playlistData` mirrors it.
- **MultiEffect**: Used for shadows and blur instead of deprecated `Qt5Compat.GraphicalEffects` where possible.
- **No `states`/`transitions` on Window**: Put them on a child Item instead.

## Connection Points (TODO - Backend)

All signals that need backend connection:
- `main.qml`: `playbackTimer` (replace with audio position update), `onSeeked` (actual seek), volume handler
- `NowPlayingView.qml`: `playPauseClicked`, `nextClicked`, `previousClicked`, `shuffleClicked`, `repeatClicked`, `seeked`, `volumeAdjusted`
- `PlayerControls.qml`: all signals same as NowPlayingView
- `SeekBar.qml`: `moved(value)` — connect to audio seek, external position updates via `position` property
- `AlbumArtDisplay.qml`: `artSource` — set from backend metadata
- `PlaylistView.qml`: `playlistData` — replace mock with backend model, `trackSelected(index)`
- `MiniPlayer.qml`: `playPauseClicked`, `nextClicked`
- `QueueItem.qml`: `clicked()` — queue selection

## Platform Notes

- **macOS**: Target name clash between executable and QML URI solved by using `OUTPUT_NAME`.
- **LSP/clangd**: Run `cmake -B build` to generate `compile_commands.json`. Symlink it to project root.
- **Homebrew Qt6**: Installed at `/opt/homebrew/opt/qt@6/`.
