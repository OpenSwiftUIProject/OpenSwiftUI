#!/bin/bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <framework-binary>" >&2
    exit 64
fi

binary="$1"

if ! linked_libraries="$(otool -L "$binary")"; then
    echo "Error: Could not inspect framework dependencies at $binary." >&2
    exit 1
fi

while IFS= read -r dependency; do
    if [[ "$dependency" =~ ^@rpath/[^/]+\.framework/.+$ ||
          "$dependency" =~ ^/System/Library/(Private)?Frameworks/[^/]+\.framework/.+$ ||
          "$dependency" =~ ^/usr/lib/.+\.dylib$ ||
          "$dependency" =~ ^@rpath/[^/]+\.dylib$ ]]; then
        continue
    fi

    echo "Error: $binary has an unsupported runtime dependency: $dependency" >&2
    exit 1
done < <(sed -n 's/^[[:space:]][[:space:]]*\(.*\) (compatibility version .*$/\1/p' <<< "$linked_libraries")
