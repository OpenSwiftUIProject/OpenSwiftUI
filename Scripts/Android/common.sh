#!/usr/bin/env bash
# Shared by the command-line runner and Gradle's native build task.
set -euo pipefail

fail() { printf 'error: %s\n' "$*" >&2; exit 1; }
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ANDROID_PROJECT="$REPO_ROOT/Android/OpenSwiftUIAndroidDemo"
ANDROID_BUILD="$REPO_ROOT/.build/android-demo"
SWIFT_SCRATCH="$ANDROID_BUILD/swift"
UIKIT_CHECKOUT="$SWIFT_SCRATCH/checkouts/UIKit-cross-platform"
if [[ -n "${OPENSWIFTUI_ANDROID_UIKIT_PATH:-}" ]]; then
    [[ -d "$OPENSWIFTUI_ANDROID_UIKIT_PATH" ]] || fail "Missing UIKit checkout: $OPENSWIFTUI_ANDROID_UIKIT_PATH"
    UIKIT_CHECKOUT="$(cd "$OPENSWIFTUI_ANDROID_UIKIT_PATH" && pwd)"
    export OPENSWIFTUI_ANDROID_UIKIT_PATH="$UIKIT_CHECKOUT"
fi
SWIFT_VERSION=6.3.2
SWIFT_ANDROID_TRIPLE=aarch64-unknown-linux-android28

case "$(uname -s)" in
    Darwin)
        export ANDROID_HOME="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
        sdk_home="$HOME/Library/org.swift.swiftpm/swift-sdks"
        default_swift="$HOME/Library/Developer/Toolchains/swift-$SWIFT_VERSION-RELEASE.xctoolchain/usr/bin/swift"
        if [[ -z "${DEVELOPER_DIR:-}" && -d /Applications/Xcode-26.3.0.app ]]; then
            export DEVELOPER_DIR=/Applications/Xcode-26.3.0.app/Contents/Developer
        fi
        if [[ -z "${JAVA_HOME:-}" && -d '/Applications/Android Studio.app/Contents/jbr/Contents/Home' ]]; then
            export JAVA_HOME='/Applications/Android Studio.app/Contents/jbr/Contents/Home'
        fi
        ;;
    Linux)
        export ANDROID_HOME="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}"
        sdk_home="$HOME/.local/share/swiftpm/swift-sdks"
        default_swift="${SWIFTLY_HOME_DIR:-$HOME/.local/share/swiftly}/toolchains/$SWIFT_VERSION/usr/bin/swift"
        ;;
    *) fail 'The Android demo runner supports macOS and Linux hosts.' ;;
esac
export PATH="${JAVA_HOME:+$JAVA_HOME/bin:}$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$HOME/.swiftly/bin:$PATH"
export SWIFT_ANDROID_SDK_PATH="${SWIFT_ANDROID_SDK_PATH:-$sdk_home/swift-$SWIFT_VERSION-RELEASE_android.artifactbundle/swift-android}"
swift_sdk_args=(--swift-sdks-path "$(dirname "$(dirname "$SWIFT_ANDROID_SDK_PATH")")"
    --swift-sdk "swift-$SWIFT_VERSION-RELEASE_android" --triple "$SWIFT_ANDROID_TRIPLE")
export ANDROID_NDK_HOME="${ANDROID_NDK_HOME:-$HOME/android-ndk/android-ndk-r27d}"
if [[ ! -d "$ANDROID_NDK_HOME" && -d "$ANDROID_HOME/ndk/27.3.13750724" ]]; then
    export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/27.3.13750724"
fi

if [[ -n "${SWIFT_EXEC:-}" ]]; then
    swift_command=("$SWIFT_EXEC")
elif [[ -x "$default_swift" ]]; then
    swift_command=("$default_swift")
elif command -v swiftly >/dev/null 2>&1; then
    swift_command=(swiftly run)
else
    fail "Install the official Swift $SWIFT_VERSION toolchain, or set SWIFT_EXEC."
fi
swift_cmd() {
    if [[ "${swift_command[0]}" == swiftly ]]; then
        swiftly run swift "$@" "+$SWIFT_VERSION"
    else
        "${swift_command[@]}" "$@"
    fi
}

# These settings also reach OpenAttributeGraph's transitive Compute dependency.
export OPENSWIFTUI_BUILD_FOR_DARWIN_PLATFORM=0 OPENATTRIBUTEGRAPH_BUILD_FOR_DARWIN_PLATFORM=0 OPENRENDERBOX_BUILD_FOR_DARWIN_PLATFORM=0
export OPENSWIFTUI_USE_LOCAL_DEPS=0 OPENATTRIBUTEGRAPH_USE_LOCAL_DEPS=0 OPENRENDERBOX_USE_LOCAL_DEPS=0
export OPENSWIFTUI_LIBRARY_EVOLUTION=0 OPENATTRIBUTEGRAPH_LIBRARY_EVOLUTION=0 OPENRENDERBOX_LIBRARY_EVOLUTION=0
export OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE=1 OPENATTRIBUTEGRAPH_OPENATTRIBUTESHIMS_COMPUTE=1
export OPENATTRIBUTEGRAPH_OPENATTRIBUTESHIMS_COMPUTE_BINARY=0
export OPENATTRIBUTEGRAPH_OPENATTRIBUTESHIMS_COMPUTE_SOURCE_REPO=OpenSwiftUIProject/Compute
export OPENATTRIBUTEGRAPH_OPENATTRIBUTESHIMS_COMPUTE_SOURCE_BRANCH=android/dev
export OPENSWIFTUI_ANDROID_UIKIT=1 OPENSWIFTUI_RENDER_GTK=0
export OPENRENDERBOX_LIB_SWIFT_PATH="$SWIFT_ANDROID_SDK_PATH/swift-resources/usr/lib/swift_static-aarch64"
export OPENSWIFTUI_ANDROID_SWIFT_STATIC_LIB_DIR="$OPENRENDERBOX_LIB_SWIFT_PATH/android"

# Public upstream submodules use SSH URLs. Rewrite only in this process tree,
# so a clean clone does not require a GitHub SSH key or global Git changes.
git_config_count="${GIT_CONFIG_COUNT:-0}"
export "GIT_CONFIG_KEY_${git_config_count}=url.https://github.com/.insteadOf"
export "GIT_CONFIG_VALUE_${git_config_count}=git@github.com:"
export GIT_CONFIG_COUNT="$((git_config_count + 1))"

check_native_environment() {
    local version
    version="$(swift_cmd --version)"
    [[ "$version" == *"Swift version $SWIFT_VERSION ("* ]] || fail "Expected Swift $SWIFT_VERSION; got: $version"
    [[ -f "$SWIFT_ANDROID_SDK_PATH/swift-sdk.json" ]] || fail "Missing matching Swift Android SDK: $SWIFT_ANDROID_SDK_PATH"
    [[ "$(basename "$(dirname "$SWIFT_ANDROID_SDK_PATH")")" == "swift-$SWIFT_VERSION-RELEASE_android.artifactbundle" ]] || fail "SWIFT_ANDROID_SDK_PATH must point inside the matching Swift $SWIFT_VERSION Android artifact bundle."
    [[ -f "$ANDROID_NDK_HOME/source.properties" ]] || fail "Set ANDROID_NDK_HOME to Android NDK r27d."
    grep -q '^Pkg.Revision = 27.3.13750724' "$ANDROID_NDK_HOME/source.properties" || fail 'This demo expects Android NDK r27d (27.3.13750724).'
    [[ -d "$SWIFT_ANDROID_SDK_PATH/ndk-sysroot/usr/include" ]] || fail 'Configure the Swift Android SDK with its scripts/setup-android-sdk.sh first.'
    local candidates=("$ANDROID_NDK_HOME"/toolchains/llvm/prebuilt/*/sysroot/usr/lib/aarch64-linux-android/libc++_shared.so)
    [[ ${#candidates[@]} -eq 1 && -f "${candidates[0]}" ]] || fail 'Cannot locate the NDK arm64 libc++_shared.so.'
    ANDROID_LIBCXX="${candidates[0]}"
}

resolve_android() {
    check_native_environment
    swift_cmd package --package-path "$ANDROID_PROJECT" --scratch-path "$SWIFT_SCRATCH" \
        --cache-path "$ANDROID_BUILD/cache" "${swift_sdk_args[@]}" resolve
    [[ -f "$UIKIT_CHECKOUT/build.gradle" ]] || fail 'UIKit remote checkout was not resolved.'
}
