cmake_minimum_required(VERSION 3.24)

project(TEST_PROJECT VERSION 0.1 LANGUAGES CXX)

include("${QT_PATH}/lib/cmake/Qt6/qt.toolchain.cmake")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(PROJECT_SOURCES
        src/main.cpp
        src/myclass.h
        rcc/rcc.qrc
)

find_package(QT NAMES Qt6 Qt5 REQUIRED)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Widgets)

qt_add_executable(${PROJECT_NAME} MANUAL_FINALIZATION ${PROJECT_SOURCES})

target_link_libraries(${PROJECT_NAME} PRIVATE Qt${QT_VERSION_MAJOR}::Widgets)


if (ANDROID)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/build/android/android
    )

    # pass variable to AndroidManifest.xml
    string(REPLACE "." ".a" ANDROID_PROJECT_NAME ${PROJECT_NAME})
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/build/android/android/AndroidManifest.xml.in ${CMAKE_CURRENT_SOURCE_DIR}/build/android/android/AndroidManifest.xml @ONLY)
endif()

install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

qt_finalize_executable(${PROJECT_NAME})