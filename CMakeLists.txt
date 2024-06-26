cmake_minimum_required(VERSION 3.24.2)

project($ENV{PROJECT_NAME} VERSION $ENV{PROJECT_VERSION} LANGUAGES CXX)

include("$ENV{Qt6_DIR}/lib/cmake/Qt6/qt.toolchain.cmake")

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

file (GLOB PROJECT_SOURCES
    src/*.h
    src/*.cpp
    rcc/rcc.qrc
)

find_package(QT NAMES Qt6 Qt5 REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Widgets)

qt_add_executable(${PROJECT_NAME} MANUAL_FINALIZATION ${PROJECT_SOURCES})

target_link_libraries(${PROJECT_NAME} PRIVATE Qt${QT_VERSION_MAJOR}::Widgets)

if (ANDROID)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android)

    set(BUILD_NUMBER $ENV{BUILD_NUMBER})
    set(ANDROID_PROJECT_NAME $ENV{ANDROID_PROJECT_NAME})
    set(PROJECT_LABEL $ENV{PROJECT_LABEL})
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/android/AndroidManifest.xml.in ${CMAKE_CURRENT_SOURCE_DIR}/android/AndroidManifest.xml @ONLY)
endif()

qt_finalize_executable(${PROJECT_NAME})
