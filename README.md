# Crossplatform Qt App template #
This template is designed to make it easy to start developing a cross-platform application. To customize your own project, you just need to correct src/config.h, set the listed environment variables and add a code to the src directory.
Tested under android, linux, windows.

## Requirements ##
Qt, Conan, Android NDK, [linuxdeploy](https://github.com/linuxdeploy/linuxdeploy)

### Script invoke examples: ###
```bash
./build.sh \
    Qt6_DIR=/opt/Qt/6.6.2/gcc_64 \
    OS=Linux \
    ABI=x86_64 \
    BUILD_TYPE=Release \
    STAGE=All
```

```bash
./build.sh \
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/ \
    ANDROID_SDK_ROOT=/opt/android-sdk/ \
    ANDROID_NDK=/opt/android-sdk/ndk/26.2.11394342 \
    Qt6_DIR=/opt/Qt/6.6.2/android_arm64_v8a \
    API_LEVEL=33 \
    ANDROID_DEVICE=28ff7904 \
    OS=Android \
    ABI=armv8 \
    BUILD_TYPE=Debug \
    STAGE=All
```

### Required environment or commandline variables: ###
```bash
Qt6_DIR=/opt/Qt/6.6.2/gcc_64     # Qt for target platform

OS=Linux             # Android, Linux, Windows
ABI=x86_64           # armv8, armv7, x86_64, x86
BUILD_TYPE=Debug     # Debug, Release
STAGE=All            # Config, Build, Deploy, All
```

```bash
# android specific variables:
JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/
ANDROID_SDK_ROOT=/opt/android-sdk/
ANDROID_NDK=/opt/android-sdk/ndk/26.2.11394342

API_LEVEL=33
ANDROID_DEVICE=28ff7904 # or 192.168.1.38:5555
ANDROID_KEYSTORE_FILE=/path/to/sign.keystore
```
