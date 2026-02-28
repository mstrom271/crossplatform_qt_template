#!/usr/bin/bash
set -euox pipefail

ARTIFACT_DIR=$BUILD_DIR/artifact/
mkdir -p $ARTIFACT_DIR

ARTIFACT_NAME="${PROJECT_NAME,,}-${PROJECT_VERSION,,}-${OS,,}-${ABI,,}"
if [[ "${BUILD_TYPE,,}" == "debug" ]]; then
    ARTIFACT_NAME="${ARTIFACT_NAME}-${BUILD_TYPE,,}"
fi

case $OS in
    "Linux")
        # deb + tar.gz
        cmake --install $BUILD_DIR --prefix "$(realpath "$BUILD_DIR/install_dir")"
        cpack --config "$BUILD_DIR/CPackConfig.cmake" -B "$BUILD_DIR"
        # TODO: signature

        # AppImage
        export QMAKE=$QT_HOST_PATH/bin/qmake
        cp ./android/res/drawable/icon.png $BUILD_DIR/$PROJECT_NAME.png
        cd $BUILD_DIR
            rm -rf ./${PROJECT_NAME}.AppDir ./${PROJECT_NAME}-x86_64.AppImage

            linuxdeploy-x86_64.AppImage \
                --appdir ./$PROJECT_NAME.AppDir \
                --executable ./$PROJECT_NAME \
                --icon-file ./$PROJECT_NAME.png \
                --create-desktop-file

            linuxdeploy-plugin-qt-x86_64.AppImage \
                --appdir ./$PROJECT_NAME.AppDir \
                --exclude-library "libqtiff.so*"

            linuxdeploy-x86_64.AppImage \
                --appdir ./$PROJECT_NAME.AppDir \
                --output appimage
        cd -
        # TODO: signature

        # move to $ARTIFACT_DIR
        mv "${BUILD_DIR}/${PROJECT_NAME}.deb" "${ARTIFACT_DIR}/${ARTIFACT_NAME}.deb"
        mv "${BUILD_DIR}/${PROJECT_NAME}.tar.gz" "${ARTIFACT_DIR}/${ARTIFACT_NAME}.tar.gz"
        mv "${BUILD_DIR}/${PROJECT_NAME}-x86_64.AppImage" "${ARTIFACT_DIR}/${ARTIFACT_NAME}.AppImage"
        ;;

    "Windows")
        mkdir $BUILD_DIR/$PROJECT_NAME/
        cp $BUILD_DIR/$PROJECT_NAME.exe $BUILD_DIR/$PROJECT_NAME/
        $QT_HOST_PATH/bin/windeployqt $BUILD_DIR/$PROJECT_NAME/$PROJECT_NAME.exe
        tar -cjvf $BUILD_DIR/$PROJECT_NAME.tar.bz2 $BUILD_DIR/$PROJECT_NAME

        # move to $ARTIFACT_DIR
        mv "${BUILD_DIR}/${PROJECT_NAME}.tar.bz2" "${ARTIFACT_DIR}/${ARTIFACT_NAME}.tar.bz2"

        ;;
    "Android")
        set +x
            if [[ -z "${ANDROID_KEYSTORE_FILE:-}" ]]; then
                export ANDROID_KEYSTORE_FILE=~/.android/debug.keystore
                export ANDROID_KEYSTORE_PASS="android"
                export ANDROID_KEYALIAS="androiddebugkey"
                export ANDROID_KEYALIAS_PASS="android"
                echo "No signature key provided. Using $ANDROID_KEYSTORE_FILE"
            fi

            # Apk sign
            $ANDROID_SDK_ROOT/build-tools/$API_LEVEL.0.0/apksigner sign \
                --ks $ANDROID_KEYSTORE_FILE \
                --ks-pass pass:$ANDROID_KEYSTORE_PASS \
                --ks-key-alias $ANDROID_KEYALIAS \
                --key-pass pass:$ANDROID_KEYALIAS_PASS \
                $BUILD_DIR/android-build/$PROJECT_NAME.apk

            # Android App Bundle create and sign
            if [[ "$BUILD_TYPE" == "Release" ]]; then
                $QT_HOST_PATH/bin/androiddeployqt \
                    --input $BUILD_DIR/android-$PROJECT_NAME-deployment-settings.json \
                    --output $BUILD_DIR/android-build/ \
                    --aab \
                    --sign $ANDROID_KEYSTORE_FILE $ANDROID_KEYALIAS \
                    --storepass $ANDROID_KEYSTORE_PASS \
                    --keypass $ANDROID_KEYALIAS_PASS
                # move to $ARTIFACT_DIR
                mv "${BUILD_DIR}/android-build/build/outputs/bundle/release/android-build-release.aab" "${ARTIFACT_DIR}/${ARTIFACT_NAME}.aab"
            fi
        set -x

        # move to $ARTIFACT_DIR
        mv "${BUILD_DIR}/android-build/${PROJECT_NAME}.apk" "${ARTIFACT_DIR}/${ARTIFACT_NAME}.apk"
        ;;
esac
