cmake_minimum_required(VERSION 3.23)
project(mysticGroove LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2)

# Suppress upstream policy warnings
qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

# Create the executable (can't be same as QML URI on case-insensitive macOS)
qt_add_executable(mysticGrooveApp
    main.cpp
)

set_target_properties(mysticGrooveApp PROPERTIES
    MACOSX_BUNDLE TRUE
    OUTPUT_NAME "mysticGroove"
)

# Register QML module
qt_add_qml_module(mysticGrooveApp
    URI MysticGroove
    VERSION 1.0
    QML_FILES
        main.qml
        component/AuroraBackground.qml
        component/AuroraShader.qml
        component/AuroraParticles.qml
        component/GlassCard.qml
        component/GlassButton.qml
        component/PlayerIconButton.qml
        component/SeekBar.qml
        component/AlbumArtDisplay.qml
        component/PlayerControls.qml
        component/QueueItem.qml
        component/MiniPlayer.qml
        component/NowPlayingView.qml
        component/PlaylistView.qml
        component/aurora.frag.qsb
    RESOURCES
)

target_link_libraries(mysticGrooveApp PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
)
