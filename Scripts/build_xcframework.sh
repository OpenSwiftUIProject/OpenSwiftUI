#!/bin/zsh

# Script modified from https://docs.emergetools.com/docs/analyzing-a-spm-framework-ios

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# xcodebuild uses the current directory to find the SPM workspace
cd "$PROJECT_ROOT"

PROJECT_BUILD_DIR="${PROJECT_BUILD_DIR:-"${PROJECT_ROOT}/build"}"

# Use xcodebuild's default DerivedData to avoid scheme resolution issues with SPM workspaces.
# Detect the workspace name from the directory and find the matching DerivedData.
WORKSPACE_NAME="$(basename "$PROJECT_ROOT")"
XCODEBUILD_DERIVED_DATA_PATH=$(find ~/Library/Developer/Xcode/DerivedData -maxdepth 1 -name "${WORKSPACE_NAME}-*" -type d 2>/dev/null | head -1)
if [ -z "$XCODEBUILD_DERIVED_DATA_PATH" ]; then
    echo "Warning: Could not find DerivedData for workspace '$WORKSPACE_NAME'. Will detect after first build."
fi

# Parse arguments
# --sdk and --archs are paired: --sdk <sdk> --archs <arch1,arch2>
# If --archs is omitted for an SDK, all default architectures are built.
SDKS=()
DEBUG_MODE=false
PACKAGE_NAME=""
declare -A SDK_ARCHS  # sdk -> "arch1,arch2" or empty for default

while [[ $# -gt 0 ]]; do
    case "$1" in
        --sdk)
            SDKS+=("$2")
            shift 2
            ;;
        --archs)
            # Apply to the last --sdk
            if [ ${#SDKS[@]} -gt 0 ]; then
                SDK_ARCHS["${SDKS[-1]}"]="$2"
            fi
            shift 2
            ;;
        --debug)
            DEBUG_MODE=true
            shift
            ;;
        *)
            if [ -z "$PACKAGE_NAME" ]; then
                PACKAGE_NAME="$1"
            fi
            shift
            ;;
    esac
done

# Default: macosx and iphonesimulator
# Note: iphoneos SDK support is blocked by an AG issue. See #835
if [ ${#SDKS[@]} -eq 0 ]; then
    SDKS=("macosx" "iphonesimulator")
fi

if [ -z "$PACKAGE_NAME" ]; then
    echo "No package name provided. Using the first scheme found in the Package.swift."
    PACKAGE_NAME=$(xcodebuild -list -project "$PROJECT_ROOT" | awk 'schemes && NF>0 { print $1; exit } /Schemes:$/ { schemes = 1 }')
    echo "Using: $PACKAGE_NAME"
fi

echo "SDKs: ${SDKS[*]}"
for sdk in "${SDKS[@]}"; do
    if [ -n "${SDK_ARCHS[$sdk]:-}" ]; then
        echo "  $sdk: ARCHS=${SDK_ARCHS[$sdk]}"
    else
        echo "  $sdk: (default archs)"
    fi
done
echo "Debug mode: $DEBUG_MODE"

# Dependency modules that need stub xcframeworks (referenced in public swiftinterface)
DEP_MODULES=("OpenSwiftUICore" "OpenAttributeGraphShims" "OpenCoreGraphicsShims" "OpenObservation" "OpenQuartzCoreShims" "OpenRenderBoxShims")

sdk_destination() {
    case "$1" in
        iphonesimulator) echo "generic/platform=iOS Simulator" ;;
        iphoneos) echo "generic/platform=iOS" ;;
        macosx) echo "generic/platform=macOS" ;;
        *) echo "generic/platform=$1" ;;
    esac
}

build_framework() {
    local sdk="$1"
    local destination="$2"
    local scheme="$3"

    local XCODEBUILD_ARCHIVE_PATH="$PROJECT_BUILD_DIR/$scheme-$sdk.xcarchive"

    rm -rf "$XCODEBUILD_ARCHIVE_PATH"

    local archs_arg=""
    if [ -n "${SDK_ARCHS[$sdk]:-}" ]; then
        # Replace commas with spaces for ARCHS setting
        archs_arg="ARCHS=${SDK_ARCHS[$sdk]//,/ }"
    fi

    OPENSWIFTUI_LIBRARY_TYPE=dynamic \
    OPENSWIFTUI_OPENATTRIBUTESHIMS_ATTRIBUTEGRAPH=1 \
    OPENSWIFTUI_LIBRARY_EVOLUTION=1 \
    xcodebuild archive \
        -scheme "$scheme" \
        -archivePath "$XCODEBUILD_ARCHIVE_PATH" \
        -sdk "$sdk" \
        -destination "$destination" \
        INSTALL_PATH='Library/Frameworks' \
        SWIFT_EMIT_MODULE_INTERFACE=YES \
        SWIFT_ACTIVE_COMPILATION_CONDITIONS='$(inherited) OPENSWIFTUI_XCFRAMEWORK_BUILD' \
        $archs_arg

    # Detect DerivedData path after the first archive if not yet known
    if [ -z "$XCODEBUILD_DERIVED_DATA_PATH" ]; then
        XCODEBUILD_DERIVED_DATA_PATH=$(find ~/Library/Developer/Xcode/DerivedData -maxdepth 1 -name "${WORKSPACE_NAME}-*" -type d 2>/dev/null | head -1)
        if [ -z "$XCODEBUILD_DERIVED_DATA_PATH" ]; then
            echo "Error: Could not find DerivedData for workspace '$WORKSPACE_NAME'."
            exit 1
        fi
    fi

    # Determine the build products path suffix
    local build_products_suffix="Release-$sdk"
    if [ "$sdk" = "macosx" ]; then
        build_products_suffix="Release"
    fi
    local BUILD_PRODUCTS_PATH="$XCODEBUILD_DERIVED_DATA_PATH/Build/Intermediates.noindex/ArchiveIntermediates/$scheme/BuildProductsPath/$build_products_suffix"

    # Copy main scheme swiftmodule into the framework
    if [ "$sdk" = "macosx" ]; then
        FRAMEWORK_MODULES_PATH="$XCODEBUILD_ARCHIVE_PATH/Products/Library/Frameworks/$scheme.framework/Versions/Current/Modules"
        mkdir -p "$FRAMEWORK_MODULES_PATH"
        cp -r "$BUILD_PRODUCTS_PATH/$scheme.swiftmodule" "$FRAMEWORK_MODULES_PATH/$scheme.swiftmodule"
        rm -rf "$XCODEBUILD_ARCHIVE_PATH/Products/Library/Frameworks/$scheme.framework/Modules"
        ln -s Versions/Current/Modules "$XCODEBUILD_ARCHIVE_PATH/Products/Library/Frameworks/$scheme.framework/Modules"
    else
        FRAMEWORK_MODULES_PATH="$XCODEBUILD_ARCHIVE_PATH/Products/Library/Frameworks/$scheme.framework/Modules"
        mkdir -p "$FRAMEWORK_MODULES_PATH"
        cp -r "$BUILD_PRODUCTS_PATH/$scheme.swiftmodule" "$FRAMEWORK_MODULES_PATH/$scheme.swiftmodule"
    fi

    # Delete private and package swiftinterface (unless --debug)
    if [ "$DEBUG_MODE" = false ]; then
        rm -f "$FRAMEWORK_MODULES_PATH/$scheme.swiftmodule"/*.package.swiftinterface
        rm -f "$FRAMEWORK_MODULES_PATH/$scheme.swiftmodule"/*.private.swiftinterface
    fi

    # Capture dependency swiftmodules before next build overwrites DerivedData
    for dep in "${DEP_MODULES[@]}"; do
        local dep_swiftmodule="$BUILD_PRODUCTS_PATH/$dep.swiftmodule"
        if [ -d "$dep_swiftmodule" ]; then
            local dep_cache="$PROJECT_BUILD_DIR/dep-modules/$dep/$sdk"
            mkdir -p "$dep_cache"
            cp -r "$dep_swiftmodule" "$dep_cache/$dep.swiftmodule"
            # Strip private/package interfaces from stubs (unless --debug)
            if [ "$DEBUG_MODE" = false ]; then
                rm -f "$dep_cache/$dep.swiftmodule"/*.package.swiftinterface
                rm -f "$dep_cache/$dep.swiftmodule"/*.private.swiftinterface
            fi
        fi
    done
}

for sdk in "${SDKS[@]}"; do
    build_framework "$sdk" "$(sdk_destination "$sdk")" "$PACKAGE_NAME"
done

echo "Builds completed successfully."

# Create main xcframework
rm -rf "$PROJECT_BUILD_DIR/$PACKAGE_NAME.xcframework"
create_args=()
for sdk in "${SDKS[@]}"; do
    create_args+=(-framework "$PROJECT_BUILD_DIR/$PACKAGE_NAME-$sdk.xcarchive/Products/Library/Frameworks/$PACKAGE_NAME.framework")
done
xcodebuild -create-xcframework "${create_args[@]}" -output "$PROJECT_BUILD_DIR/$PACKAGE_NAME.xcframework"

# Copy dSYMs
for sdk in "${SDKS[@]}"; do
    # Determine the xcframework slice directory name
    local_dsym_dir=""
    case "$sdk" in
        iphonesimulator) local_dsym_dir=$(ls -d "$PROJECT_BUILD_DIR/$PACKAGE_NAME.xcframework"/ios-*simulator 2>/dev/null | head -1) ;;
        iphoneos) local_dsym_dir=$(ls -d "$PROJECT_BUILD_DIR/$PACKAGE_NAME.xcframework"/ios-arm64 2>/dev/null | head -1) ;;
        macosx) local_dsym_dir=$(ls -d "$PROJECT_BUILD_DIR/$PACKAGE_NAME.xcframework"/macos-* 2>/dev/null | head -1) ;;
    esac
    if [ -n "$local_dsym_dir" ] && [ -d "$PROJECT_BUILD_DIR/$PACKAGE_NAME-$sdk.xcarchive/dSYMs" ]; then
        cp -r "$PROJECT_BUILD_DIR/$PACKAGE_NAME-$sdk.xcarchive/dSYMs" "$local_dsym_dir/"
    fi
done

# Create stub xcframeworks for dependency modules
# These contain only swiftmodule/swiftinterface (no binary) since the code
# is statically linked into the main framework.
for dep in "${DEP_MODULES[@]}"; do
    echo "Creating stub xcframework for $dep..."
    rm -rf "$PROJECT_BUILD_DIR/$dep.xcframework"

    # Build per-platform stub frameworks
    for sdk in "${SDKS[@]}"; do
        local_dep_cache="$PROJECT_BUILD_DIR/dep-modules/$dep/$sdk"
        if [ ! -d "$local_dep_cache/$dep.swiftmodule" ]; then
            echo "Warning: No swiftmodule found for $dep ($sdk), skipping."
            continue
        fi

        stub_fw="$PROJECT_BUILD_DIR/dep-stubs/$sdk/$dep.framework"
        sdk_path="$(xcrun --sdk $sdk --show-sdk-path)"

        # Detect architectures from the main framework binary
        main_binary="$PROJECT_BUILD_DIR/$PACKAGE_NAME-$sdk.xcarchive/Products/Library/Frameworks/$PACKAGE_NAME.framework/$PACKAGE_NAME"
        if [ "$sdk" = "macosx" ]; then
            main_binary="$PROJECT_BUILD_DIR/$PACKAGE_NAME-$sdk.xcarchive/Products/Library/Frameworks/$PACKAGE_NAME.framework/Versions/A/$PACKAGE_NAME"
        fi
        stub_archs=$(lipo -archs "$main_binary" 2>/dev/null || echo "arm64")

        # Determine install_name and clang target suffix per SDK
        install_name_path=""
        if [ "$sdk" = "macosx" ]; then
            mkdir -p "$stub_fw/Versions/A/Modules"
            cp -r "$local_dep_cache/$dep.swiftmodule" "$stub_fw/Versions/A/Modules/$dep.swiftmodule"
            ln -sfn A "$stub_fw/Versions/Current"
            ln -sfn Versions/Current/Modules "$stub_fw/Modules"
            install_name_path="@rpath/$dep.framework/Versions/A/$dep"
        else
            mkdir -p "$stub_fw/Modules"
            cp -r "$local_dep_cache/$dep.swiftmodule" "$stub_fw/Modules/$dep.swiftmodule"
            install_name_path="@rpath/$dep.framework/$dep"
        fi

        # Build stub dylib for each arch then lipo if needed
        dylib_files=()
        for arch in $stub_archs; do
            target_triple=""
            case "$sdk" in
                iphoneos) target_triple="${arch}-apple-ios18.0" ;;
                iphonesimulator) target_triple="${arch}-apple-ios18.0-simulator" ;;
                macosx) target_triple="${arch}-apple-macos15.0" ;;
            esac
            clang -dynamiclib -x c /dev/null -o "/tmp/$dep-$arch.dylib" \
                -install_name "$install_name_path" \
                -isysroot "$sdk_path" -target "$target_triple" 2>/dev/null
            dylib_files+=("/tmp/$dep-$arch.dylib")
        done

        output_dylib=""
        if [ "$sdk" = "macosx" ]; then
            output_dylib="$stub_fw/Versions/A/$dep"
        else
            output_dylib="$stub_fw/$dep"
        fi

        if [ ${#dylib_files[@]} -eq 1 ]; then
            mv "${dylib_files[0]}" "$output_dylib"
        else
            lipo -create "${dylib_files[@]}" -output "$output_dylib"
            rm -f "${dylib_files[@]}"
        fi

        if [ "$sdk" = "macosx" ]; then
            ln -sfn "Versions/A/$dep" "$stub_fw/$dep"
        fi

        # Create Info.plist with CFBundleExecutable
        # macOS frameworks need Info.plist inside Versions/A/Resources/
        plist_dir="$stub_fw"
        if [ "$sdk" = "macosx" ]; then
            mkdir -p "$stub_fw/Versions/A/Resources"
            plist_dir="$stub_fw/Versions/A/Resources"
            ln -sfn Versions/Current/Resources "$stub_fw/Resources"
        fi
        cat > "$plist_dir/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$dep</string>
    <key>CFBundleIdentifier</key>
    <string>org.openswiftui.$dep</string>
    <key>CFBundleName</key>
    <string>$dep</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
</dict>
</plist>
PLIST
    done

    # Create xcframework from stubs
    create_args=()
    for sdk in "${SDKS[@]}"; do
        stub_fw="$PROJECT_BUILD_DIR/dep-stubs/$sdk/$dep.framework"
        if [ -d "$stub_fw" ]; then
            create_args+=(-framework "$stub_fw")
        fi
    done
    xcodebuild -create-xcframework "${create_args[@]}" -output "$PROJECT_BUILD_DIR/$dep.xcframework"
done

# Clean up temp directories
rm -rf "$PROJECT_BUILD_DIR/dep-modules" "$PROJECT_BUILD_DIR/dep-stubs"
