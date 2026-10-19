#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
PACKAGE_ROOT="${OPENSWIFTUI_BINARY_PACKAGE_PATH:-$SOURCE_ROOT/../OpenSwiftUI-spm}"
BUILD_ROOT="${PROJECT_BUILD_DIR:-$SOURCE_ROOT/../build}"
skip_build=false

for argument in "$@"; do
    case "$argument" in
        --skip-build) skip_build=true ;;
        --help|-h)
            cat <<'USAGE'
Usage: Scripts/CI/check_binary_interface.sh [--skip-build]

Build the complete release XCFrameworks, then compile the OpenSwiftUI-spm
Example for iOS Simulator, macOS, and visionOS Simulator against their textual
interfaces. No simulator boots.

PROJECT_BUILD_DIR sets the build directory (default: ../build).
OPENSWIFTUI_BINARY_PACKAGE_PATH selects the consumer checkout
(default: ../OpenSwiftUI-spm; cloned with gh if absent).
--skip-build verifies existing XCFrameworks without rebuilding them.
Each verification uses fresh DerivedData and keeps its logs and xcresult.
USAGE
            exit 0 ;;
        *) echo "Unknown argument: $argument" >&2; exit 64 ;;
    esac
done

mkdir -p "$BUILD_ROOT"
BUILD_ROOT="$(cd "$BUILD_ROOT" && pwd -P)"
export PROJECT_BUILD_DIR="$BUILD_ROOT"

if [[ "$skip_build" == false ]]; then
    export OPENSWIFTUI_OPENATTRIBUTESHIMS_ATTRIBUTEGRAPH=0
    export OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE=1
    export OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE_BINARY=0
    # Match the release build, including its visionOS UIKit overlay.
    overlay_root="$BUILD_ROOT/xr-uikit-overlay"
    "$SOURCE_ROOT/../DarwinPrivateFrameworks/Scripts/XR/install_xr_uikit_overlay.sh" \
        --output "$overlay_root"
    export OPENSWIFTUI_XR_OVERLAY="$overlay_root/overlay.yaml"
    "$SOURCE_ROOT/Scripts/build_xcframework.sh" --compute OpenSwiftUI
fi

# The package falls back to release URLs for missing local frameworks.
# Reject incomplete output so a published binary cannot hide a candidate bug.
for framework in OpenSwiftUI OpenSwiftUICore OpenAttributeGraphShims \
    OpenCoreGraphicsShims OpenObservation OpenQuartzCoreShims OpenRenderBoxShims; do
    if [[ ! -d "$BUILD_ROOT/$framework.xcframework" ]]; then
        echo "Missing local framework: $BUILD_ROOT/$framework.xcframework" >&2
        exit 1
    fi
done

if [[ ! -e "$PACKAGE_ROOT" ]]; then
    gh repo clone OpenSwiftUIProject/OpenSwiftUI-spm "$PACKAGE_ROOT"
fi
PACKAGE_ROOT="$(cd "$PACKAGE_ROOT" && pwd -P)"
export OPENSWIFTUI_LOCAL_XCFRAMEWORKS_PATH="$BUILD_ROOT"
verification_root="$(mktemp -d "$BUILD_ROOT/interface-check.XXXXXX")"
echo "Binary package: $PACKAGE_ROOT"
echo "Local XCFrameworks: $OPENSWIFTUI_LOCAL_XCFRAMEWORKS_PATH"
echo "Verification results: $verification_root"

cd "$PACKAGE_ROOT/Example"
./setup.sh 2>&1 | tee "$verification_root/setup.log"
# Prefer interfaces even when the producer and consumer use the same compiler.
# Fresh DerivedData prevents a cached compiled module from hiding interface errors.
status=0
for platform in ios macos visionos; do
    case "$platform" in
        ios) destination='generic/platform=iOS Simulator' ;;
        macos) destination='generic/platform=macOS' ;;
        visionos) destination='generic/platform=visionOS Simulator' ;;
    esac
    platform_root="$verification_root/$platform"
    mkdir -p "$platform_root"
    echo "Verifying $platform interfaces"
    if xcodebuild build \
        -workspace Example.xcworkspace \
        -scheme Example-Workspace \
        -configuration Debug \
        -destination "$destination" \
        -derivedDataPath "$platform_root/DerivedData" \
        -resultBundlePath "$platform_root/Example.xcresult" \
        ARCHS=arm64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO \
        'OTHER_SWIFT_FLAGS=$(inherited) -Xfrontend -module-load-mode -Xfrontend prefer-interface' \
        2>&1 | tee "$platform_root/build.log"; then
        echo "$platform: passed"
    else
        status=$?
        echo "$platform: failed (exit $status)" >&2
    fi
done
exit "$status"
