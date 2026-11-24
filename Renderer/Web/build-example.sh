#!/bin/bash

set -eu

if [ "$#" -gt 1 ]; then
    echo "Usage: $0 [output-directory]" >&2
    exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SWIFT_RELEASE="${OPENSWIFTUI_WEB_SWIFT_RELEASE:-6.3.2}"
SWIFT_SDK_ID="${OPENSWIFTUI_WEB_SWIFT_SDK_ID:-swift-6.3.2-RELEASE_wasm}"
OUTPUT_DIRECTORY="${1:-./Bundle}"
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
        --output "$OUTPUT_DIRECTORY" \
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
        --output "$OUTPUT_DIRECTORY"
fi

case "$OUTPUT_DIRECTORY" in
    /*) BUILT_DIRECTORY="$OUTPUT_DIRECTORY" ;;
    *) BUILT_DIRECTORY="$SCRIPT_DIR/${OUTPUT_DIRECTORY#./}" ;;
esac

echo "Built $BUILT_DIRECTORY/ExampleApp.wasm"
echo "Static preview: cd $SCRIPT_DIR && python3 -m http.server 8000"
echo "Then open http://127.0.0.1:8000/preview.html"
