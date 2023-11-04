#!/usr/bin/bash
set -e

##### script invoke examples: #####
# ./build_and_deploy.sh \
#     OS=linux \
#     BUILD_TYPE=Debug \
#     QT_ROOT=~/Qt/6.5.1

# ./build_and_deploy.sh \
#     OS=android \
#     BUILD_TYPE=Debug \
#     QT_ROOT=~/Qt/6.5.1 \
#     ANDROID_NDK_ROOT=/opt/android-sdk/ndk/25.1.8937393/ \
#     API_LEVEL=31 \
#     ABI=armv8 \
#     ANDROID_DEVICE_ID=28ff7904


##### required environment or commandline variables: ######
# OS=android          # android, linux
# BUILD_TYPE=Debug    # Debug, Release
# QT_ROOT=~/Qt/6.5.1

# android specific variables:
# ANDROID_NDK_ROOT=/opt/android-sdk/ndk/25.1.8937393/
# API_LEVEL=31
# ABI=armv8       # armv8, armv7, x86_64, x86
# ANDROID_DEVICE_ID=$(adb devices | sed -n 2p | awk '{print $1}')


# Create commandline-based local variables
for param in "$@"
do
    IFS='=' read -r -a param_parts <<< "$param"
    if [[ ${#param_parts[@]} -eq 2 ]]; then
        param_name=${param_parts[0]}
        param_value=${param_parts[1]}
        declare "$param_name=$param_value"
    fi
done

check_variable_existence() {
    if [[ -z ${!1} ]]; then
        echo "Please define $1 variable"
        exit
    fi
}

check_variable_existence OS
check_variable_existence QT_ROOT
check_variable_existence BUILD_TYPE

rm -rf build CMakeUserPresets.json CMakePresets.json
./rcc/rcc.sh

declare -A CONAN_PRESET
CONAN_PRESET["Debug"]="conan-debug"
CONAN_PRESET["Release"]="conan-release"

case $OS in
    "linux")
        mkdir -p ./build/$BUILD_TYPE
        conan install . -s build_type=$BUILD_TYPE --build=missing
        source build/$BUILD_TYPE/generators/conanbuild.sh
        cmake -S . -B ./build/$BUILD_TYPE --preset ${CONAN_PRESET[$BUILD_TYPE]} \
            -DQT_PATH=${QT_ROOT}/gcc_64/
        source build/$BUILD_TYPE/generators/deactivate_conanbuild.sh

        mv CMakeUserPresets.json CMakePresets.json
        ;;
    "android")
        check_variable_existence ANDROID_NDK_ROOT
        check_variable_existence API_LEVEL
        check_variable_existence ABI

        mkdir -p build/android
        cp -r android/ build/android

        declare -A QT_PATH
        QT_PATH["armv8"]=${QT_ROOT}/android_arm64_v8a
        QT_PATH["armv7"]=${QT_ROOT}/android_armv7
        QT_PATH["x86_64"]=${QT_ROOT}/android_x86_64
        QT_PATH["x86"]=${QT_ROOT}/android_x86

        declare -A TOOL_NAME
        TOOL_NAME["armv8"]=aarch64-linux-android31-clang
        TOOL_NAME["armv7"]=armv7a-linux-androideabi31-clang
        TOOL_NAME["x86_64"]=x86_64-linux-android31-clang
        TOOL_NAME["x86"]=i686-linux-android31-clang

        DESTINATION_DIR=./build/android/$BUILD_TYPE/$ABI
        mkdir -p $DESTINATION_DIR

        export CC=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin/${TOOL_NAME[$ABI]}
        export CXX=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin/${TOOL_NAME[$ABI]}++
        export LD=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin/ld
        conan install . --profile android -s arch=$ABI -s os.api_level=$API_LEVEL -s build_type=$BUILD_TYPE --build=missing

        source build/$BUILD_TYPE/generators/conanbuild.sh
        cmake -S . -B $DESTINATION_DIR --preset ${CONAN_PRESET[$BUILD_TYPE]} -DQT_PATH=${QT_PATH[$ABI]}
        cmake --build $DESTINATION_DIR
        source build/$BUILD_TYPE/generators/deactivate_conanbuild.sh

        rm CMakeUserPresets.json

        adb devices -l
        check_variable_existence ANDROID_DEVICE_ID
        adb -s $ANDROID_DEVICE_ID install $DESTINATION_DIR/android-build/*.apk
        ;;
esac
