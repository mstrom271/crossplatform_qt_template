#!/usr/bin/bash
set -euox pipefail

# root dir of the project
PROJECT_DIR=$(realpath "$(dirname "$0")/..")

# Create variables from commandline params
for param in "$@"
do
    IFS='=' read -r -a param_parts <<< "$param"
    if [[ $#param_parts[@] -eq 2 ]]; then
        param_name=$param_parts[0]
        param_value=$param_parts[1]
        declare -x "$param_name=$(eval "echo $param_value")"
    fi
done

# Read variables from src/config.h
$PROJECT_DIR/scripts/build_number.sh
source $PROJECT_DIR/scripts/config.h.sh $PROJECT_DIR/src/config.h

# create build dir
BUILD_DIR=$PROJECT_DIR/build/$OS/$ABI/$BUILD_TYPE
mkdir -p $BUILD_DIR

# cmake preset name: e.g. android-armv8-debug
CMAKE_PRESET="${OS,,}-${ABI,,}-${BUILD_TYPE,,}"

# Translations
$PROJECT_DIR/scripts/translations.sh
# # Translations
# while IFS= read -r lang
# do
#     lang=$(echo "$lang" | tr -d '\r')
#     $QT_HOST_PATH/bin/lupdate $PROJECT_DIR/src/ -ts $PROJECT_DIR/translations/translation_$lang.ts #-no-obsolete
#     $QT_HOST_PATH/bin/lrelease $PROJECT_DIR/translations/*.ts
# done < "$PROJECT_DIR/translations/list.txt"
# mkdir -p $PROJECT_DIR/rcc/rcc
# mv $PROJECT_DIR/translations/*.qm $PROJECT_DIR/rcc/rcc

# Resources
$PROJECT_DIR/rcc/rcc.sh

# Config
if [[ "$STAGE" == "All" || "$STAGE" == "Config" ]]; then
    rm -rf $BUILD_DIR/* # $PROJECT_DIR/CMakePresets.json $PROJECT_DIR/CMakeUserPresets.json

    conan profile detect -f
    case $OS in
        "Linux")
            conan install $PROJECT_DIR \
                -s os=$OS \
                -s arch=$ABI \
                -s build_type=$BUILD_TYPE \
                -s compiler.cppstd=20 \
                -c tools.cmake.cmaketoolchain:generator=Ninja \
                --build=missing \
                --output-folder=$BUILD_DIR
            cmake -S $PROJECT_DIR \
                -B $BUILD_DIR \
                --preset $CMAKE_PRESET
            ;;
        "Windows")
            # conan install $PROJECT_DIR \
            #     -s build_type=$BUILD_TYPE \
            #     -s compiler.cppstd=20 \
            #     -c tools.cmake.cmaketoolchain:generator=Ninja \
            #     -c tools.microsoft.bash:subsystem=msys2 \
            #     -c tools.microsoft.bash:active=True \
            #     --build=missing \
            #     --output-folder=$BUILD_DIR
            # source $BUILD_DIR/generators/conanbuild.sh
            # cmake -S $PROJECT_DIR \
            #     -B $BUILD_DIR \
            #     --preset ${CONAN_PRESET[$BUILD_TYPE]}
            # source $BUILD_DIR/generators/deactivate_conanbuild.sh
            ;;
        "Android")
            conan install $PROJECT_DIR \
                -s os=$OS \
                -s arch=$ABI \
                -s build_type=$BUILD_TYPE \
                -s os.api_level=$API_LEVEL \
                -s compiler=clang \
                -s compiler.version=14 \
                -s compiler.cppstd=20 \
                -c tools.cmake.cmaketoolchain:generator=Ninja \
                -c tools.android:ndk_path=$ANDROID_NDK \
                --build=missing \
                --output-folder=$BUILD_DIR
            cmake -S $PROJECT_DIR \
                -B $BUILD_DIR \
                --preset $CMAKE_PRESET
            ;;
    esac
fi

# Build
if [[ "$STAGE" == "All" || "$STAGE" == "Build" ]]; then
    cmake --build --preset $CMAKE_PRESET
fi

# Deploy
# if [[ "$STAGE" == "All" || "$STAGE" == "Deploy" ]]; then
#     case $OS in
#         "Linux")
#             cp $PROJECT_DIR/android/res/drawable/icon.png $BUILD_DIR/$PROJECT_NAME.png
#             cd $BUILD_DIR
#             export QMAKE=$Qt6_DIR/bin/qmake
#             linuxdeploy-x86_64.AppImage \
#                 --appdir ./$PROJECT_NAME.dir \
#                 --executable ./$PROJECT_NAME \
#                 --icon-file ./$PROJECT_NAME.png \
#                 --create-desktop-file \
#                 --output appimage \
#                 --plugin qt
#             ;;
#         "Windows")
#             mkdir $BUILD_DIR/$PROJECT_NAME/
#             cp $BUILD_DIR/$PROJECT_NAME.exe $BUILD_DIR/$PROJECT_NAME/
#             windeployqt $BUILD_DIR/$PROJECT_NAME/$PROJECT_NAME.exe
#             tar -cjvf $BUILD_DIR/$PROJECT_NAME.tar.bz2 $BUILD_DIR/$PROJECT_NAME
#             ls -al $BUILD_DIR/
#             ;;
#         "Android")
#             set +x
#                 if [ ! -n "$ANDROID_KEYSTORE_FILE" ]; then
#                     export ANDROID_KEYSTORE_FILE=~/.android/debug.keystore
#                     export ANDROID_KEYSTORE_PASS="android"
#                     export ANDROID_KEYALIAS=androiddebugkey
#                     export ANDROID_KEYALIAS_PASS="android"
#                 fi

#                 # Apk sign
#                 apksigner sign \
#                     --ks $ANDROID_KEYSTORE_FILE \
#                     --ks-pass pass:$ANDROID_KEYSTORE_PASS \
#                     --ks-key-alias $ANDROID_KEYALIAS \
#                     --key-pass pass:$ANDROID_KEYALIAS_PASS \
#                     $BUILD_DIR/android-build/$PROJECT_NAME.apk

#                 # Android App Bundle create and sign
#                 if [[ "$BUILD_TYPE" == "Release" ]]; then
#                     androiddeployqt \
#                         --input $BUILD_DIR/android-$PROJECT_NAME-deployment-settings.json \
#                         --output $BUILD_DIR/android-build/ \
#                         --aab \
#                         --sign $ANDROID_KEYSTORE_FILE $ANDROID_KEYALIAS \
#                         --storepass $ANDROID_KEYSTORE_PASS \
#                         --keypass $ANDROID_KEYALIAS_PASS
#                     jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 \
#                         $BUILD_DIR/android-build/build/outputs/bundle/release/android-build-release.aab \
#                         -keystore $ANDROID_KEYSTORE_FILE \
#                         -storepass $ANDROID_KEYSTORE_PASS $ANDROID_KEYALIAS \
#                         -keypass $ANDROID_KEYALIAS_PASS
#                 fi
#             set -x

#             if [ -n "$ANDROID_DEVICE" ]; then
#                 adb -s $ANDROID_DEVICE install $BUILD_DIR/android-build/$PROJECT_NAME.apk
#             fi
#             ;;
#     esac
# fi
