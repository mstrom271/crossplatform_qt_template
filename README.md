# SpeedRead crossplatform app #
Tested under android and linux

## Requirements ##
Qt, Android NDK, Conan

### Script invoke examples: ###
```bash
./build_and_deploy.sh \
    OS=linux \
    BUILD_TYPE=Debug \
    QT_ROOT=~/Qt/6.5.1
```

```bash
./build_and_deploy.sh \
    OS=android \
    BUILD_TYPE=Debug \
    QT_ROOT=~/Qt/6.5.1 \
    ANDROID_NDK_ROOT=/opt/android-sdk/ndk/25.1.8937393/ \
    API_LEVEL=31 \
    ABI=armv8 \
    ANDROID_DEVICE_ID=28ff7904
```

### Required environment or commandline variables: ###
```bash
OS=android          # android, linux
BUILD_TYPE=Debug    # Debug, Release
QT_ROOT=~/Qt/6.5.1
```

```bash
# android specific variables:
ANDROID_NDK_ROOT=/opt/android-sdk/ndk/25.1.8937393/
API_LEVEL=31
ABI=armv8       # armv8, armv7, x86_64, x86
ANDROID_DEVICE_ID=$(adb devices | sed -n 2p | awk '{print $1}')
```
