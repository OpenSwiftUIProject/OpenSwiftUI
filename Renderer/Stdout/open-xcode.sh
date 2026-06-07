#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "The Tuist Xcode workflow is only available on macOS." >&2
    exit 1
fi

tuist install
tuist generate --no-open
open StdoutRenderer.xcworkspace
