cmake_minimum_required(VERSION 3.24.2)

# add variables to cache
set(PROJECT_NAME "$ENV{PROJECT_NAME}" CACHE STRING "Application name")
set(PROJECT_VERSION "$ENV{PROJECT_VERSION}" CACHE STRING "Application version")
set(BUILD_NUMBER "$ENV{BUILD_NUMBER}" CACHE STRING "BUILD_NUMBER")
set(ANDROID_SDK_ROOT "$ENV{ANDROID_SDK_ROOT}" CACHE STRING "ANDROID_SDK_ROOT")
set(ANDROID_NDK "$ENV{ANDROID_NDK}" CACHE STRING "ANDROID_NDK")
set(ANDROID_PROJECT_NAME "$ENV{ANDROID_PROJECT_NAME}" CACHE STRING "ANDROID_PROJECT_NAME")

project("${PROJECT_NAME}" VERSION "${PROJECT_VERSION}" LANGUAGES CXX)

set(CMAKE_INSTALL_RPATH "$ORIGIN/../${CMAKE_INSTALL_LIBDIR}")

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

# ---------------- INSTALL ----------------
install(TARGETS "${PROJECT_NAME}"
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

qt_generate_deploy_app_script(
    TARGET "${PROJECT_NAME}"
    OUTPUT_SCRIPT deploy_script
    NO_TRANSLATIONS     # ?
)
install(SCRIPT ${deploy_script})

# ---------------- CPACK ----------------
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
# set(CPACK_PACKAGE_VENDOR "")
# set(CPACK_PACKAGE_CONTACT "")
# CPACK_PACKAGE_DESCRIPTION_SUMMARY
# CPACK_DEBIAN_PACKAGE_SECTION
# CPACK_DEBIAN_PACKAGE_DEPENDS
# CPACK_RESOURCE_FILE_LICENSE

# package name: <project>-<os>-<arch>
string(TOLOWER "${CMAKE_SYSTEM_NAME}" CPACK_TARGET_OS)
string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" CPACK_TARGET_ARCH)
set(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}-${CPACK_TARGET_OS}-${CPACK_TARGET_ARCH}")

# Общая структура пакета
set(CPACK_PACKAGE_INSTALL_DIRECTORY "${PROJECT_NAME}")

# ---------- Platform dependend generators ----------

if(WIN32)
    set(CPACK_GENERATOR "NSIS")         # Windows .exe installer (NSIS)
    set(CPACK_NSIS_DISPLAY_NAME "${PROJECT_NAME}")
    set(CPACK_NSIS_PACKAGE_NAME "${PROJECT_NAME}")
endif()

if(APPLE)
    set(CPACK_GENERATOR "DragNDrop")    # macOS .dmg
endif()

if(UNIX AND NOT APPLE)
    set(CPACK_GENERATOR "DEB;TGZ")
    set(CPACK_PACKAGING_INSTALL_PREFIX "/opt/${PROJECT_NAME}")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Your Name")
    set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS OFF)
endif()


include(CPack)
