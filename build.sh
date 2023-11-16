#!/usr/bin/bash
set -e
set -x

##### script invoke examples: #####
# ./build.sh \
#     OS=Linux \
#     BUILD_TYPE=Debug \
#     Qt6_DIR=~/Qt/6.5.1/gcc_64

# ./build.sh \
#     OS=Android \
#     BUILD_TYPE=Debug \
#     Qt6_DIR=~/Qt/6.5.1/android_arm64_v8a \
#     ANDROID_NDK=/opt/android-sdk/ndk/25.1.8937393/ \
#     API_LEVEL=31 \
#     ABI=armv8 \
#     ANDROID_DEVICE_ID=28ff7904


##### required environment or commandline variables: ######
# OS=Android          # Android, Linux
# BUILD_TYPE=Debug    # Debug, Release
# export Qt6_DIR=~/Qt/6.5.1/gcc_64                  # Qt for target platform

# # android specific variables:
# export ANDROID_NDK=/opt/android-sdk/ndk/25.1.8937393/
# API_LEVEL=31
# ABI=x86_64       # armv8, armv7, x86_64, x86
# ANDROID_DEVICE_ID=$(adb devices | sed -n 2p | awk '{print $1}')


# Create commandline-based local variables
for param in "$@"
do
    IFS='=' read -r -a param_parts <<< "$param"
    if [[ ${#param_parts[@]} -eq 2 ]]; then
        param_name=${param_parts[0]}
        param_value=${param_parts[1]}
        declare -x "$param_name=$(eval "echo $param_value")"
    fi
done

check_variable_existence() {
    if [[ -z ${!1} ]]; then
        echo "Please define $1 variable"
        exit
    fi
}

check_variable_existence OS
check_variable_existence Qt6_DIR
check_variable_existence BUILD_TYPE

rm -rf build CMakeUserPresets.json CMakePresets.json

declare -A CONAN_PRESET
CONAN_PRESET["Debug"]="conan-debug"
CONAN_PRESET["Release"]="conan-release"


# Translations
if [ "$OS" == "Android" ]; then
    export QT_HOST_PATH=${Qt6_DIR}/../gcc_64
else
    export QT_HOST_PATH=$Qt6_DIR
fi

while IFS= read -r lang
do
    lang=$(echo "$lang" | tr -d '\r')
    ${QT_HOST_PATH}/bin/lupdate ./src/ -ts ./translations/translation_${lang}.ts
    ${QT_HOST_PATH}/bin/lrelease ./translations/*.ts
done < "./translations/list.txt"
mkdir -p ./rcc/rcc
mv ./translations/*.qm ./rcc/rcc


# Resources
./rcc/rcc.sh

conan profile detect -f
case $OS in
    "Linux")
        DESTINATION_DIR=./build/$BUILD_TYPE
        mkdir -p $DESTINATION_DIR

        conan install . \
            -s build_type=$BUILD_TYPE \
            -c tools.cmake.cmaketoolchain:generator=Ninja \
            --build=missing
        source $DESTINATION_DIR/generators/conanbuild.sh
        cmake -S . \
            -B $DESTINATION_DIR \
            --preset ${CONAN_PRESET[$BUILD_TYPE]}
        cmake --build $DESTINATION_DIR
        source $DESTINATION_DIR/generators/deactivate_conanbuild.sh

        mv CMakeUserPresets.json CMakePresets.json
        ;;
    "Windows")
        DESTINATION_DIR=./build/$BUILD_TYPE
        mkdir -p $DESTINATION_DIR

        conan install . \
            -s build_type=$BUILD_TYPE \
            -c tools.cmake.cmaketoolchain:generator=Ninja \
            -c tools.microsoft.bash:subsystem=msys2 \
            -c tools.microsoft.bash:active=True \
            --build=missing
        source $DESTINATION_DIR/generators/conanbuild.sh
        cmake -S . \
            -B $DESTINATION_DIR \
            --preset ${CONAN_PRESET[$BUILD_TYPE]}
        cmake --build $DESTINATION_DIR
        source $DESTINATION_DIR/generators/deactivate_conanbuild.sh

        mv CMakeUserPresets.json CMakePresets.json
        ;;
    "Android")
        check_variable_existence ANDROID_NDK
        check_variable_existence API_LEVEL
        check_variable_existence ABI

        mkdir -p build/android
        cp -r android/ build/android

        # declare -A TOOL_NAME
        # TOOL_NAME["armv8"]=aarch64-linux-android31-clang
        # TOOL_NAME["armv7"]=armv7a-linux-androideabi31-clang
        # TOOL_NAME["x86_64"]=x86_64-linux-android31-clang
        # TOOL_NAME["x86"]=i686-linux-android31-clang

        DESTINATION_DIR=./build/android/$BUILD_TYPE/$ABI
        mkdir -p $DESTINATION_DIR

        # export CC=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/${TOOL_NAME[$ABI]}
        # export CXX=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/${TOOL_NAME[$ABI]}++
        # export LD=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/ld
        conan install . \
            -s os=$OS \
            -s arch=$ABI \
            -s compiler=clang \
            -s compiler.version=14 \
            -c tools.cmake.cmaketoolchain:generator=Ninja \
            -s os.api_level=$API_LEVEL \
            -s build_type=$BUILD_TYPE \
            -c tools.android:ndk_path=$ANDROID_NDK \
            --build=missing

        source build/$BUILD_TYPE/generators/conanbuild.sh
        cmake -S . -B $DESTINATION_DIR --preset ${CONAN_PRESET[$BUILD_TYPE]}
        cmake --build $DESTINATION_DIR
        source build/$BUILD_TYPE/generators/deactivate_conanbuild.sh

        rm CMakeUserPresets.json

        if [ -n "$ANDROID_DEVICE_ID" ]; then
            adb devices -l
            adb -s $ANDROID_DEVICE_ID install $DESTINATION_DIR/android-build/*.apk
        fi
        ;;
esac
