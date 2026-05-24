#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

cd "$SCRIPT_DIR"
mise trust "$SCRIPT_DIR/mise.toml"
mise install
mise exec -- tuist install
mise exec -- tuist generate --no-open
