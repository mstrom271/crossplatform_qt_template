# SpeedRead crossplatform app #
Tested under android and linux

## Requirements ##
Qt, Android NDK, Conan

### Script invoke examples: ###
```bash
./build_and_deploy.sh \
    OS=Linux \
    BUILD_TYPE=Debug \
    Qt6_DIR=~/Qt/6.5.1/gcc_64
```

```bash
./build_and_deploy.sh \
    OS=Android \
    BUILD_TYPE=Debug \
    Qt6_DIR=~/Qt/6.5.1/android_arm64_v8a \
    ANDROID_NDK=/opt/android-sdk/ndk/25.1.8937393/ \
    API_LEVEL=31 \
    ABI=armv8 \
    ANDROID_DEVICE_ID=28ff7904
```

### Required environment or commandline variables: ###
```bash
OS=Android          # Android, Linux
BUILD_TYPE=Debug    # Debug, Release
Qt6_DIR=~/Qt/6.5.1/gcc_64
```

```bash
# android specific variables:
ANDROID_NDK=/opt/android-sdk/ndk/25.1.8937393/
API_LEVEL=31
ABI=armv8       # armv8, armv7, x86_64, x86
ANDROID_DEVICE_ID=$(adb devices | sed -n 2p | awk '{print $1}')
```
