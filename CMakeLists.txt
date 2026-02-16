cmake_minimum_required(VERSION 3.24.2)

# add variables to cache
set(PROJECT_NAME "$ENV{PROJECT_NAME}" CACHE STRING "Application name")
set(PROJECT_VERSION "$ENV{PROJECT_VERSION}" CACHE STRING "Application version")
set(BUILD_NUMBER "$ENV{BUILD_NUMBER}" CACHE STRING "BUILD_NUMBER")
set(ANDROID_SDK_ROOT "$ENV{ANDROID_SDK_ROOT}" CACHE STRING "ANDROID_SDK_ROOT")
set(ANDROID_NDK "$ENV{ANDROID_NDK}" CACHE STRING "ANDROID_NDK")
set(ANDROID_PROJECT_NAME "$ENV{ANDROID_PROJECT_NAME}" CACHE STRING "ANDROID_PROJECT_NAME")

project("${PROJECT_NAME}" VERSION "${PROJECT_VERSION}" LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Widgets)

file(GLOB PROJECT_SOURCES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/rcc/rcc.qrc"
)

qt_add_executable("${PROJECT_NAME}"
    MANUAL_FINALIZATION
    "${PROJECT_SOURCES}"
)

target_compile_features("${PROJECT_NAME}" PRIVATE cxx_std_20)
target_link_libraries("${PROJECT_NAME}" PRIVATE Qt6::Widgets)

if(MSVC)
    target_compile_options("${PROJECT_NAME}" PRIVATE /W4)
else()
    target_compile_options("${PROJECT_NAME}" PRIVATE -Wall -Wextra -Wpedantic)
endif()

if (ANDROID)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android)

    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/android/AndroidManifest.xml.in ${CMAKE_CURRENT_SOURCE_DIR}/android/AndroidManifest.xml @ONLY)
endif()

qt_finalize_executable("${PROJECT_NAME}")
