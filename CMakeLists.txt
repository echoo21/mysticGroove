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
        component/background/AuroraBackground.qml
        component/background/AuroraShader.qml
        component/background/AuroraParticles.qml
        component/glass/GlassCard.qml
        component/glass/GlassButton.qml
        component/player/PlayerIconButton.qml
        component/player/PlayerIcon.qml
        component/player/SeekBar.qml
        component/player/AlbumArtDisplay.qml
        component/player/PlayerControls.qml
        component/player/MiniPlayer.qml
        component/items/QueueItem.qml
        component/nav/TabBar.qml
        component/views/NowPlayingView.qml
        component/views/PlaylistView.qml
        component/views/HomeView.qml
        component/views/SearchView.qml
        component/views/LibraryView.qml
    RESOURCES
        component/aurora.frag.qsb
)

target_link_libraries(mysticGrooveApp PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
)
