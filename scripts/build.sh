#!/usr/bin/bash
set -euox pipefail

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
source ./scripts/config.h.sh ./src/config.h

# Build number as seconds since 2024-01-01 00:00:00 UTC
EPOCH_UTC=1704067200
NOW_UTC=$(date -u +%s)
export BUILD_NUMBER=$((NOW_UTC - EPOCH_UTC))

# cmake preset name: e.g. android-armv8-debug
export CMAKE_PRESET="${OS,,}-${ABI,,}-${BUILD_TYPE,,}"

# create build dir
export BUILD_DIR=./build/$CMAKE_PRESET

conan profile detect -f
CONAN_COMMON_ARGS=(
    -s os=$OS
    -s arch=$ABI
    -s build_type=$BUILD_TYPE
    -s compiler.cppstd=20
    -c tools.cmake.cmaketoolchain:generator=Ninja
    --output-folder="$BUILD_DIR"
    "${CONAN_EXTRA_ARGS[@]}"
)
case $OS in
    "Linux")
        ;;
    "Windows")
        # CONAN_COMMON_ARGS+=(
        #     -c tools.microsoft.bash:subsystem=msys2 \
        #     -c tools.microsoft.bash:active=True \
        # )
        ;;
    "Android")
        CONAN_COMMON_ARGS+=(
            -s compiler=clang \
            -s compiler.version=14 \
            -s os.api_level=$API_LEVEL \
            -c tools.android:ndk_path=$ANDROID_NDK \
        )
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

contains_stage() {
    local target="$1"
    local stages_csv="$2"
    IFS=',' read -r -a stages <<< "$stages_csv"
    for stage in "${stages[@]}"; do
        stage="${stage//[[:space:]]/}"
        if [[ "$stage" == "$target" ]]; then
            return 0
        fi
    done
    return 1
}

if contains_stage "Configure" "$STAGES"; then
    rm -rf $BUILD_DIR
    conan install . "${CONAN_COMMON_ARGS[@]}" --build=missing
    conan build . "${CONAN_COMMON_ARGS[@]}" --conf user.step:target=configure
fi
if contains_stage "Build" "$STAGES"; then
    conan build . "${CONAN_COMMON_ARGS[@]}" --conf user.step:target=build
fi
if contains_stage "Package" "$STAGES"; then
    conan build . "${CONAN_COMMON_ARGS[@]}" --conf user.step:target=package
fi
if contains_stage "Deploy" "$STAGES"; then
    conan build . "${CONAN_COMMON_ARGS[@]}" --conf user.step:target=deploy
fi
