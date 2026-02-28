#!/usr/bin/bash
set -euox pipefail

# root dir of the project
PROJECT_DIR=$(realpath "$(dirname "$0")/..")

# Read variables from src/config.h
source ./scripts/config.h.sh ./src/config.h

# CI or manual mode
choices=(
    "Debug_Linux(Configure)"
    "Debug_Windows(Configure)"
    "Debug_Android(Configure)"
    "Debug_Android(Configure,Build,Package,Deploy)"
    "Release_Linux(Configure,Build,Package)"
    "Release_Windows(Configure,Build,Package)"
    "Release_Android_armv8(Configure,Build,Package)"
    "Release_Android_x86_64(Configure,Build,Package)"
)

if [[ $# -gt 0 ]]; then
    # CI
    choice="$1"
else
    # manual
    choice=$(printf '%s\n' "${choices[@]}" | fzf)
fi

# Environment variables
Qt6_MAIN="${Qt6_MAIN:-/opt/Qt/6.10.2}"
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-/opt/android-sdk}"
export ANDROID_NDK="${ANDROID_NDK:-$ANDROID_SDK_ROOT/ndk/29.0.14206865}"
export API_LEVEL=35
export QT_HOST_PATH=$Qt6_MAIN/gcc_64
export ANDROID_DEVICE=P7CIRKUWBMW45XFA      # or ip:port

case $choice in
    "Debug_Linux(Configure)")
        export OS=Linux
        export ABI=x86_64
        export BUILD_TYPE=Debug
        export STAGES=Configure
        export CMAKE_PREFIX_PATH=$Qt6_MAIN/gcc_64
        ;;
    "Debug_Windows(Configure)")
        export OS=Windows
        export ABI=x86_64
        export BUILD_TYPE=Debug
        export STAGES=Configure
        export CMAKE_PREFIX_PATH=$Qt6_MAIN/mingw_64
        ;;
    "Debug_Android(Configure)")
        export OS=Android
        export ABI=armv8
        export BUILD_TYPE=Debug
        export STAGES=Configure
        export CMAKE_PREFIX_PATH=$Qt6_MAIN/android_arm64_v8a
        ;;
    "Debug_Android(Configure,Build,Package,Deploy)")
        export OS=Android
        export ABI=armv8
        export BUILD_TYPE=Debug
        export STAGES=Configure,Build,Package,Deploy
        export CMAKE_PREFIX_PATH=$Qt6_MAIN/android_arm64_v8a
        ;;
    "Release_Linux(Configure,Build,Package)")
        export OS=Linux
        export ABI=x86_64
        export BUILD_TYPE=Release
        export STAGES=Configure,Build,Package
        export CMAKE_PREFIX_PATH=$Qt6_MAIN/gcc_64
        ;;
    "Release_Windows(Configure,Build,Package)")
        export OS=Windows
        export ABI=x86_64
        export BUILD_TYPE=Release
        export STAGES=Configure,Build,Package
        export CMAKE_PREFIX_PATH=$Qt6_MAIN/mingw_64
        ;;
    "Release_Android_armv8(Configure,Build,Package)")
        if [[ -z "${ANDROID_KEYSTORE_FILE:-}" ]]; then
            ANDROID_KEYSTORE_DIR=$ANDROID_KEYSTORE_BASE/$ANDROID_PROJECT_NAME
            export ANDROID_KEYSTORE_FILE="$ANDROID_KEYSTORE_DIR/keystore_file.keystore"
            export ANDROID_KEYSTORE_PASS="$(<"$ANDROID_KEYSTORE_DIR/keystore_pass.txt")"
            export ANDROID_KEYALIAS="$(<"$ANDROID_KEYSTORE_DIR/keyalias.txt")"
            export ANDROID_KEYALIAS_PASS="$(<"$ANDROID_KEYSTORE_DIR/keyalias_pass.txt")"
        fi
        export OS=Android
        export ABI=armv8
        export BUILD_TYPE=Release
        export STAGES=Configure,Build,Package
        export CMAKE_PREFIX_PATH=$Qt6_MAIN/android_arm64_v8a
        ;;
    "Release_Android_x86_64(Configure,Build,Package)")
        if [[ -z "${ANDROID_KEYSTORE_FILE:-}" ]]; then
            ANDROID_KEYSTORE_DIR=$ANDROID_KEYSTORE_BASE/$ANDROID_PROJECT_NAME
            export ANDROID_KEYSTORE_FILE="$ANDROID_KEYSTORE_DIR/keystore_file.keystore"
            export ANDROID_KEYSTORE_PASS="$(<"$ANDROID_KEYSTORE_DIR/keystore_pass.txt")"
            export ANDROID_KEYALIAS="$(<"$ANDROID_KEYSTORE_DIR/keyalias.txt")"
            export ANDROID_KEYALIAS_PASS="$(<"$ANDROID_KEYSTORE_DIR/keyalias_pass.txt")"
        fi
        export OS=Android
        export ABI=x86_64
        export BUILD_TYPE=Release
        export STAGES=Configure,Build,Package
        export CMAKE_PREFIX_PATH=$Qt6_MAIN/android_x86_64
        ;;
    *)
        echo "Invalid choice: ${choice}"
        echo "Available choices:"
        printf '  %s\n' "${choices[@]}"
        exit 1
        ;;
esac

./scripts/build.sh
