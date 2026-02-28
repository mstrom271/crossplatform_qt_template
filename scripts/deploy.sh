#!/usr/bin/bash
set -euox pipefail

case $OS in
    "Linux")
        echo "No implementation"
        ;;
    "Windows")
        echo "No implementation"
        ;;
    "Android")
        adb -s $ANDROID_DEVICE install $BUILD_DIR/package/$PROJECT_NAME.apk
        ;;
esac
