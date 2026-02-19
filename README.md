# Crossplatform Qt App template #
This template is designed to make it easy to start developing a cross-platform application. To customize your own project, you just need to correct src/config.h, set the listed environment variables and add a code to the src directory.
Tested under android, linux, windows.

## Requirements ##
Qt, Conan, Android NDK, [linuxdeploy](https://github.com/linuxdeploy/linuxdeploy)

### Script invoke examples: ###
```bash
./scripts/build.sh \
    CMAKE_PREFIX_PATH=/opt/Qt/6.10.2/gcc_64 \
    QT_HOST_PATH=/opt/Qt/6.10.2/gcc_64 \
    OS=Linux \
    ABI=x86_64 \
    BUILD_TYPE=Release \
    STAGE=All
```

```bash
./scripts/build.sh \
    ANDROID_SDK_ROOT=/opt/android-sdk \
    ANDROID_NDK=/opt/android-sdk/ndk/29.0.14206865 \
    CMAKE_PREFIX_PATH=/opt/Qt/6.10.2/android_arm64_v8a \
    QT_HOST_PATH=/opt/Qt/6.10.2/gcc_64 \
    API_LEVEL=35 \
    ANDROID_DEVICE=28ff7904 \
    OS=Android \
    ABI=armv8 \
    BUILD_TYPE=Release \
    STAGE=All
```

### Required environment or commandline variables: ###
```bash
CMAKE_PREFIX_PATH=/opt/Qt/6.10.2/gcc_64      # Qt for target platform
QT_HOST_PATH=/opt/Qt/6.10.2/gcc_64           # Qt for build platform

OS=Linux             # Android, Linux, Windows
ABI=x86_64           # armv8, armv7, x86_64, x86
BUILD_TYPE=Debug     # Debug, Release
STAGE=All            # Config, Build, Deploy, All
```

```bash
# android specific variables:
ANDROID_SDK_ROOT=/opt/android-sdk/
ANDROID_NDK=/opt/android-sdk/ndk/29.0.14206865

API_LEVEL=35
ANDROID_DEVICE=P7CIRKUWBMW45XFA # or 192.168.1.39:43491
ANDROID_KEYSTORE_FILE=/path/to/sign.keystore
```
