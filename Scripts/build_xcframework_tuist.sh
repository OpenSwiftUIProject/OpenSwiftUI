#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

BUILD_DIR="$PROJECT_ROOT/.build/Xcode"
SCHEME="OpenSwiftUI"

# Generate Xcode project via Tuist
pushd "$PROJECT_ROOT" > /dev/null
tuist generate --no-open
popd > /dev/null

# Hide SPM modulemap to prevent Clang auto-discovery conflicts
"$SCRIPT_DIR/hide_spi_modulemap.sh" hide
trap '"$SCRIPT_DIR/hide_spi_modulemap.sh" restore' EXIT

XCODEPROJ="$PROJECT_ROOT/OpenSwiftUI.xcodeproj"

# Create build and framework directories
mkdir -p "$BUILD_DIR/Archives" "$BUILD_DIR/Frameworks"

# Create framework modulemap for distribution
cat > "$BUILD_DIR/module.modulemap" << 'EOF'
framework module OpenSwiftUI {
  umbrella header "OpenSwiftUI.h"
  export *
  module * { export * }
}
EOF

# Parse arguments
DEBUG_INFO=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --debug-info)
            DEBUG_INFO=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

echo "Building xcframework for $SCHEME (debug info: $DEBUG_INFO)"

# Archive for each platform using the Tuist-generated xcodeproj
xcodebuild archive \
    -project "$XCODEPROJ" \
    -scheme "$SCHEME" \
    -destination "generic/platform=macOS" \
    -archivePath "$BUILD_DIR/Archives/$SCHEME-macOS.xcarchive" \
    ENABLE_USER_SCRIPT_SANDBOXING=NO

xcodebuild archive \
    -project "$XCODEPROJ" \
    -scheme "$SCHEME" \
    -destination "generic/platform=iOS" \
    -archivePath "$BUILD_DIR/Archives/$SCHEME-iOS.xcarchive" \
    ENABLE_USER_SCRIPT_SANDBOXING=NO

xcodebuild archive \
    -project "$XCODEPROJ" \
    -scheme "$SCHEME" \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "$BUILD_DIR/Archives/$SCHEME-iOS-Simulator.xcarchive" \
    ENABLE_USER_SCRIPT_SANDBOXING=NO

echo "Archives completed successfully."

# Create xcframework
rm -rf "$BUILD_DIR/Frameworks/$SCHEME.xcframework"

if [ "$DEBUG_INFO" = true ]; then
    echo "Creating xcframework with debug symbols..."
    xcodebuild -create-xcframework \
        -archive "$BUILD_DIR/Archives/$SCHEME-macOS.xcarchive" -framework "$SCHEME.framework" \
        -debug-symbols "$(realpath "$BUILD_DIR/Archives/$SCHEME-macOS.xcarchive/dSYMs/$SCHEME.framework.dSYM")" \
        -archive "$BUILD_DIR/Archives/$SCHEME-iOS.xcarchive" -framework "$SCHEME.framework" \
        -debug-symbols "$(realpath "$BUILD_DIR/Archives/$SCHEME-iOS.xcarchive/dSYMs/$SCHEME.framework.dSYM")" \
        -archive "$BUILD_DIR/Archives/$SCHEME-iOS-Simulator.xcarchive" -framework "$SCHEME.framework" \
        -debug-symbols "$(realpath "$BUILD_DIR/Archives/$SCHEME-iOS-Simulator.xcarchive/dSYMs/$SCHEME.framework.dSYM")" \
        -output "$BUILD_DIR/Frameworks/$SCHEME.xcframework"
else
    xcodebuild -create-xcframework \
        -archive "$BUILD_DIR/Archives/$SCHEME-macOS.xcarchive" -framework "$SCHEME.framework" \
        -archive "$BUILD_DIR/Archives/$SCHEME-iOS.xcarchive" -framework "$SCHEME.framework" \
        -archive "$BUILD_DIR/Archives/$SCHEME-iOS-Simulator.xcarchive" -framework "$SCHEME.framework" \
        -output "$BUILD_DIR/Frameworks/$SCHEME.xcframework"
fi

# Post-process swiftinterface files
find "$BUILD_DIR/Frameworks/$SCHEME.xcframework" -name "*.swiftinterface" | while read -r file; do
    echo "Processed: $file"
done

# Delete private and package swiftinterface files
find "$BUILD_DIR/Frameworks/$SCHEME.xcframework" -name "*.package.swiftinterface" -delete
find "$BUILD_DIR/Frameworks/$SCHEME.xcframework" -name "*.private.swiftinterface" -delete

# Copy module.modulemap into each framework's Modules directory
find "$BUILD_DIR/Frameworks/$SCHEME.xcframework" -type d -name "Modules" | while read -r modules_dir; do
    cp "$BUILD_DIR/module.modulemap" "$modules_dir/"
    echo "Copied modulemap to: $modules_dir"
done

# Fix missing Headers symlink (macOS framework uses Versions/Current layout)
find "$BUILD_DIR/Frameworks/$SCHEME.xcframework" -type d -name "$SCHEME.framework" | while read -r framework_dir; do
    if [ -d "$framework_dir/Versions" ] && [ ! -L "$framework_dir/Headers" ]; then
        ln -s Versions/Current/Headers "$framework_dir/Headers"
        echo "Added Headers symlink to: $framework_dir"
    fi
done

# Zip the framework, preserving symlinks
cd "$BUILD_DIR/Frameworks"
zip -r -y "$SCHEME.xcframework.zip" "$SCHEME.xcframework"
echo "Created $SCHEME.xcframework.zip"
