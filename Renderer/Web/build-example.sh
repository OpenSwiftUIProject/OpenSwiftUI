#!/bin/bash

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SWIFT_RELEASE="${OPENSWIFTUI_WEB_SWIFT_RELEASE:-6.3.2}"
SWIFT_SDK_ID="${OPENSWIFTUI_WEB_SWIFT_SDK_ID:-swift-6.3.2-RELEASE_wasm}"
WASI_COMPATIBILITY_FLAGS=(
    -Xcc -D_WASI_EMULATED_SIGNAL
    -Xcc -D_WASI_EMULATED_MMAN
)

cd "$SCRIPT_DIR"

export OPENSWIFTUI_BUILD_FOR_DARWIN_PLATFORM=0
export OPENSWIFTUI_USE_LOCAL_DEPS=1
export OPENSWIFTUI_RENDER_GTK=0
export OPENSWIFTUI_OPENATTRIBUTESHIMS_ATTRIBUTEGRAPH=0
export OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE=1
export OPENSWIFTUI_SWIFT_TOOLCHAIN_SUPPORTED=0

if command -v swiftly >/dev/null 2>&1; then
    swiftly run swift package \
        --build-system native \
        --swift-sdk "$SWIFT_SDK_ID" \
        "${WASI_COMPATIBILITY_FLAGS[@]}" \
        plugin --allow-writing-to-package-directory \
        js \
        --product ExampleApp \
        --use-cdn \
        --output ./Bundle \
        "+$SWIFT_RELEASE"
else
    swift package \
        --build-system native \
        --swift-sdk "$SWIFT_SDK_ID" \
        "${WASI_COMPATIBILITY_FLAGS[@]}" \
        plugin --allow-writing-to-package-directory \
        js \
        --product ExampleApp \
        --use-cdn \
        --output ./Bundle
fi

echo "Built $SCRIPT_DIR/Bundle/ExampleApp.wasm"
echo "Preview with: cd $SCRIPT_DIR && python3 -m http.server 8000"
