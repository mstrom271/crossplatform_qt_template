#!/usr/bin/bash
set -euox pipefail

# root dir of the project
PROJECT_DIR=$(realpath "$(dirname "$0")/..")

# Read variables from src/config.h
source $PROJECT_DIR/scripts/config.h.sh $PROJECT_DIR/src/config.h

choice=$(echo -e \
"Linux_Release\n"\
"Linux_Debug_Config\n"\
"Android_Release\n"\
"Android_Debug_Config\n"\
"Android_GooglePlay\n"\
| fzf)

Qt6_MAIN=/opt/Qt/6.10.2
export QT_HOST_PATH=$Qt6_MAIN/gcc_64
export ANDROID_SDK_ROOT=/opt/android-sdk
export ANDROID_NDK=$ANDROID_SDK_ROOT/ndk/29.0.14206865
export API_LEVEL=35
export ANDROID_DEVICE=192.168.1.39:43491 # P7CIRKUWBMW45XFA

export ANDROID_KEYSTORE_FILE=~/.android/debug.keystore
export ANDROID_KEYSTORE_PASS="android"
export ANDROID_KEYALIAS=androiddebugkey
export ANDROID_KEYALIAS_PASS="android"

case $choice in
    "Linux_Release")
        export OS=Linux
        export ABI=x86_64
        export BUILD_TYPE=Release
        export STAGE=All
        export CMAKE_PREFIX_PATH=$Qt6_MAIN/gcc_64
        $PROJECT_DIR/scripts/build.sh
        ;;
    "Linux_Debug_Config")
        export OS=Linux
        export ABI=x86_64
        export BUILD_TYPE=Debug
        export STAGE=Config
        export CMAKE_PREFIX_PATH=$Qt6_MAIN/gcc_64
        $PROJECT_DIR/scripts/build.sh
        ;;
    "Android_Release")
        export OS=Android
        export ABI=armv8
        export BUILD_TYPE=Release
        export STAGE=All
        export CMAKE_PREFIX_PATH=$Qt6_MAIN/android_arm64_v8a
        $PROJECT_DIR/scripts/build.sh
        ;;
    "Android_Debug_Config")
        export OS=Android
        export ABI=armv8
        export BUILD_TYPE=Debug
        export STAGE=Config
        export CMAKE_PREFIX_PATH=$Qt6_MAIN/android_arm64_v8a
        $PROJECT_DIR/scripts/build.sh
        ;;
    "Android_GooglePlay")
        unset ANDROID_DEVICE
        export OS=Android
        export ABI=armv8
        export BUILD_TYPE=Release
        export STAGE=All
        export CMAKE_PREFIX_PATH=$Qt6_MAIN/android_arm64_v8a
        $PROJECT_DIR/scripts/build.sh
        export OS=Android
        export ABI=x86_64
        export BUILD_TYPE=Release
        export STAGE=All
        export CMAKE_PREFIX_PATH=$Qt6_MAIN/android_x86_64
        $PROJECT_DIR/scripts/build.sh
        ;;
esac
