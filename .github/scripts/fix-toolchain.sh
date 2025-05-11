#!/bin/bash
set -e

# Find the path to swift binary
SWIFT_PATH=$(which swift)
echo "Swift binary found at: $SWIFT_PATH"

# Extract the toolchain path from swift binary path
# Remove /usr/bin/swift from the path to get the toolchain root
TOOLCHAIN_ROOT=$(dirname $(dirname "$SWIFT_PATH"))
echo "Toolchain root: $TOOLCHAIN_ROOT"

# Construct the path to CFBase.h
CFBASE_PATH="$TOOLCHAIN_ROOT/lib/swift/CoreFoundation/CFBase.h"
echo "Looking for CFBase.h at: $CFBASE_PATH"

# Check if the file exists
if [ -f "$CFBASE_PATH" ]; then
    echo "Found CFBase.h, applying patch..."
    
    # Create a backup of the original file
    cp "$CFBASE_PATH" "$CFBASE_PATH.bak"
    
    # Replace the include line
    sed -i 's/#include <ptrauth.h>/\/\/ #include <ptrauth.h>/g' "$CFBASE_PATH"
    
    echo "Patch applied successfully."
    echo "Original file backed up at $CFBASE_PATH.bak"
else
    echo "ERROR: Could not find CFBase.h in expected location."
    echo "Toolchain structure may be different than expected."
    exit 1
fi
