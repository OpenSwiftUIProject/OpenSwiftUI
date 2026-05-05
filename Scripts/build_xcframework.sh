#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

PROJECT_BUILD_DIR="${PROJECT_BUILD_DIR:-"${PROJECT_ROOT}/build"}"
DERIVED_DATA_PATH="$PROJECT_BUILD_DIR/DerivedData"
XCODEPROJ="$PROJECT_ROOT/OpenSwiftUI.xcodeproj"
XCODEWORKSPACE="$PROJECT_ROOT/Workspace.xcworkspace"

# Parse arguments.
# --sdk and --archs are paired: --sdk <sdk> --archs <arch1,arch2>
# If --archs is omitted for an SDK, all default architectures are built.
SDKS=()
SDK_ARCHS=()
DEBUG_MODE=false
PACKAGE_NAME="OpenSwiftUI"
RUN_TUIST_INSTALL=true

while [[ $# -gt 0 ]]; do
    case "$1" in
        --sdk)
            SDKS+=("$2")
            SDK_ARCHS+=("")
            shift 2
            ;;
        --archs)
            if [ ${#SDKS[@]} -gt 0 ]; then
                SDK_ARCHS[$((${#SDK_ARCHS[@]} - 1))]="$2"
            fi
            shift 2
            ;;
        --debug)
            DEBUG_MODE=true
            shift
            ;;
        --skip-tuist-install)
            RUN_TUIST_INSTALL=false
            shift
            ;;
        *)
            PACKAGE_NAME="$1"
            shift
            ;;
    esac
done

# Default: macosx and iphonesimulator.
# Note: iphoneos SDK support is blocked by an AG issue. See #835.
if [ ${#SDKS[@]} -eq 0 ]; then
    SDKS=("macosx" "iphonesimulator")
    SDK_ARCHS=("" "")
fi

if [ "${OPENSWIFTUI_SKIP_TUIST_INSTALL:-0}" = "1" ]; then
    RUN_TUIST_INSTALL=false
fi

if ! command -v tuist >/dev/null 2>&1; then
    echo "Error: tuist is required to generate $PACKAGE_NAME.xcodeproj."
    exit 1
fi

if [ "$RUN_TUIST_INSTALL" = true ]; then
    echo "Installing Tuist dependencies..."
    tuist install
else
    echo "Skipping tuist install."
fi

echo "Generating Xcode project with Tuist..."
tuist generate --no-open

if [ ! -d "$XCODEPROJ" ]; then
    echo "Error: Expected Tuist to generate $XCODEPROJ."
    exit 1
fi

if [ ! -d "$XCODEWORKSPACE" ]; then
    echo "Error: Expected Tuist to generate $XCODEWORKSPACE."
    exit 1
fi

echo "SDKs: ${SDKS[*]}"
for i in "${!SDKS[@]}"; do
    if [ -n "${SDK_ARCHS[$i]}" ]; then
        echo "  ${SDKS[$i]}: ARCHS=${SDK_ARCHS[$i]}"
    else
        echo "  ${SDKS[$i]}: (default archs)"
    fi
done
echo "Debug mode: $DEBUG_MODE"

# Dependency modules referenced by public swiftinterfaces. They are copied into
# the one distributable framework instead of emitted as separate stub frameworks.
DEP_MODULES=(
    "OpenSwiftUICore"
    "OpenAttributeGraphShims"
    "OpenCoreGraphicsShims"
    "OpenObservation"
    "OpenQuartzCoreShims"
    "OpenRenderBoxShims"
)

sdk_destination() {
    case "$1" in
        iphonesimulator) echo "generic/platform=iOS Simulator" ;;
        iphoneos) echo "generic/platform=iOS" ;;
        macosx) echo "generic/platform=macOS" ;;
        *) echo "generic/platform=$1" ;;
    esac
}

build_products_suffix() {
    case "$1" in
        macosx) echo "Release" ;;
        *) echo "Release-$1" ;;
    esac
}

framework_path() {
    local archive_path="$1"
    local scheme="$2"
    echo "$archive_path/Products/Library/Frameworks/$scheme.framework"
}

framework_modules_path() {
    local framework="$1"
    if [ -d "$framework/Versions" ]; then
        echo "$framework/Versions/Current/Modules"
    else
        echo "$framework/Modules"
    fi
}

strip_private_interfaces() {
    local modules_path="$1"
    if [ "$DEBUG_MODE" = false ]; then
        find "$modules_path" -name "*.package.swiftinterface" -delete
        find "$modules_path" -name "*.private.swiftinterface" -delete
    fi
}

canonical_path() {
    local path="$1"
    if [ -e "$path" ]; then
        (cd "$(dirname "$path")" && printf "%s/%s\n" "$(pwd -P)" "$(basename "$path")")
    else
        echo "$path"
    fi
}

find_swiftmodule() {
    local build_products_path="$1"
    local archive_path="$2"
    local module_name="$3"

    local candidates=(
        "$build_products_path/$module_name.swiftmodule"
        "$build_products_path/$module_name.framework/Modules/$module_name.swiftmodule"
        "$build_products_path/$module_name.framework/Versions/A/Modules/$module_name.swiftmodule"
        "$archive_path/Products/Library/Frameworks/$module_name.framework/Modules/$module_name.swiftmodule"
        "$archive_path/Products/Library/Frameworks/$module_name.framework/Versions/A/Modules/$module_name.swiftmodule"
    )

    for candidate in "${candidates[@]}"; do
        if [ -d "$candidate" ]; then
            echo "$candidate"
            return
        fi
    done
}

copy_swiftmodule() {
    local build_products_path="$1"
    local archive_path="$2"
    local module_name="$3"
    local modules_path="$4"

    local swiftmodule
    swiftmodule="$(find_swiftmodule "$build_products_path" "$archive_path" "$module_name")"
    if [ -z "$swiftmodule" ]; then
        echo "Warning: No swiftmodule found for $module_name."
        return
    fi

    local destination="$modules_path/$module_name.swiftmodule"
    if [ "$(canonical_path "$swiftmodule")" = "$(canonical_path "$destination")" ]; then
        return
    fi

    rm -rf "$destination"
    cp -R "$swiftmodule" "$destination"
}

build_framework() {
    local sdk="$1"
    local destination="$2"
    local scheme="$3"
    local archs="$4"

    local archive_path="$PROJECT_BUILD_DIR/$scheme-$sdk.xcarchive"
    local build_products_path="$DERIVED_DATA_PATH/Build/Intermediates.noindex/ArchiveIntermediates/$scheme/BuildProductsPath/$(build_products_suffix "$sdk")"

    rm -rf "$archive_path"

    local xcodebuild_args=(
        archive
        -workspace "$XCODEWORKSPACE"
        -scheme "$scheme"
        -configuration Release
        -archivePath "$archive_path"
        -sdk "$sdk"
        -destination "$destination"
        -derivedDataPath "$DERIVED_DATA_PATH"
        -skipPackagePluginValidation
        -skipMacroValidation
        INSTALL_PATH=Library/Frameworks
        SKIP_INSTALL=NO
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES
        SWIFT_EMIT_MODULE_INTERFACE=YES
        "SWIFT_ACTIVE_COMPILATION_CONDITIONS=\$(inherited) OPENSWIFTUI_XCFRAMEWORK_BUILD"
        ENABLE_USER_SCRIPT_SANDBOXING=NO
    )

    if [ -n "$archs" ]; then
        xcodebuild_args+=("ARCHS=${archs//,/ }")
    fi

    xcodebuild "${xcodebuild_args[@]}"

    local framework
    framework="$(framework_path "$archive_path" "$scheme")"
    if [ ! -d "$framework" ]; then
        echo "Error: Archive did not contain $framework."
        exit 1
    fi

    local modules_path
    modules_path="$(framework_modules_path "$framework")"
    mkdir -p "$modules_path"

    if [ "$sdk" = "macosx" ]; then
        rm -rf "$framework/Modules"
        ln -s Versions/Current/Modules "$framework/Modules"
    fi

    copy_swiftmodule "$build_products_path" "$archive_path" "$scheme" "$modules_path"
    for dep in "${DEP_MODULES[@]}"; do
        copy_swiftmodule "$build_products_path" "$archive_path" "$dep" "$modules_path"
    done
    strip_private_interfaces "$modules_path"
}

rm -rf "$DERIVED_DATA_PATH"
mkdir -p "$PROJECT_BUILD_DIR"

for i in "${!SDKS[@]}"; do
    build_framework "${SDKS[$i]}" "$(sdk_destination "${SDKS[$i]}")" "$PACKAGE_NAME" "${SDK_ARCHS[$i]}"
done

echo "Archives completed successfully."

rm -rf "$PROJECT_BUILD_DIR/$PACKAGE_NAME.xcframework"
create_args=()
for sdk in "${SDKS[@]}"; do
    create_args+=(-framework "$(framework_path "$PROJECT_BUILD_DIR/$PACKAGE_NAME-$sdk.xcarchive" "$PACKAGE_NAME")")
done
xcodebuild -create-xcframework "${create_args[@]}" -output "$PROJECT_BUILD_DIR/$PACKAGE_NAME.xcframework"

# Copy dSYMs into each XCFramework slice for consumers that want local symbols.
for sdk in "${SDKS[@]}"; do
    local_dsym_dir=""
    case "$sdk" in
        iphonesimulator) local_dsym_dir=$(ls -d "$PROJECT_BUILD_DIR/$PACKAGE_NAME.xcframework"/ios-*simulator 2>/dev/null | head -1) ;;
        iphoneos) local_dsym_dir=$(ls -d "$PROJECT_BUILD_DIR/$PACKAGE_NAME.xcframework"/ios-arm64 2>/dev/null | head -1) ;;
        macosx) local_dsym_dir=$(ls -d "$PROJECT_BUILD_DIR/$PACKAGE_NAME.xcframework"/macos-* 2>/dev/null | head -1) ;;
    esac

    if [ -n "$local_dsym_dir" ] && [ -d "$PROJECT_BUILD_DIR/$PACKAGE_NAME-$sdk.xcarchive/dSYMs" ]; then
        cp -R "$PROJECT_BUILD_DIR/$PACKAGE_NAME-$sdk.xcarchive/dSYMs" "$local_dsym_dir/"
    fi
done

echo "Created $PROJECT_BUILD_DIR/$PACKAGE_NAME.xcframework"
