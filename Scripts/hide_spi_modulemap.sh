#!/bin/bash
# Hide/restore the SPM modulemap during Xcode builds.
#
# The SPM module.modulemap at Sources/OpenSwiftUI_SPI/ defines 12 standalone
# modules (CoreFoundation_Private, UIFoundation_Private, etc.) that Clang
# auto-discovers from header search paths. These conflict with system module
# resolution in Xcode builds.
#
# Usage:
#   ./Scripts/hide_spi_modulemap.sh hide    # Rename to .spm (before xcodebuild)
#   ./Scripts/hide_spi_modulemap.sh restore # Rename back (after xcodebuild)
#
# The Tuist project uses Configs/OpenSwiftUI_SPI.modulemap instead.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SPI_MODULEMAP="$PROJECT_ROOT/Sources/OpenSwiftUI_SPI/module.modulemap"

case "${1:-hide}" in
    hide)
        if [ -f "$SPI_MODULEMAP" ]; then
            mv "$SPI_MODULEMAP" "${SPI_MODULEMAP}.spm"
            echo "Hidden: $SPI_MODULEMAP → .spm"
        fi
        ;;
    restore)
        if [ -f "${SPI_MODULEMAP}.spm" ]; then
            mv "${SPI_MODULEMAP}.spm" "$SPI_MODULEMAP"
            echo "Restored: $SPI_MODULEMAP"
        fi
        ;;
    *)
        echo "Usage: $0 [hide|restore]"
        exit 1
        ;;
esac
