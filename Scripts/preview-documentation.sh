#!/bin/bash

##===----------------------------------------------------------------------===##
##
## This source file is part of the OpenSwiftUI open source project
##
## Copyright (c) 2026 the OpenSwiftUI project authors
## Licensed under Apache License v2.0
##
## See LICENSE.txt for license information
##
## SPDX-License-Identifier: Apache-2.0
##
##===----------------------------------------------------------------------===##

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CONFIG_PATH=".vdc.json"
OUTPUT_PATH=""
CACHE_PATH=""
PREVIEW_BIND="127.0.0.1"
PREVIEW_PORT=8766
BUILD_SITE=true
ASSEMBLE_ONLY=false
REBUILD=false
USE_OCI_CACHE=false

usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Build and serve OpenSwiftUI's multi-version VersionedDocC site locally.

By default, the script builds cache misses without accessing OCI, assembles the
site, and starts the VersionedDocC preview server at 127.0.0.1:8766.

OPTIONS:
    --no-build             Serve an already assembled site without building
    --assemble-only        Assemble only from existing version caches
    --rebuild              Rebuild every selected documentation version
    --use-oci-cache        Allow restoring configured release caches from GHCR
    --config PATH          VersionedDocC configuration (default: .vdc.json)
    --output PATH          Override the assembled site output path
    --cache PATH           Override the version cache path for the build step
    --bind ADDRESS         Preview server address (default: 127.0.0.1)
    --port PORT            Preview server port (default: 8766)
    -h, --help             Show this help message

EXAMPLES:
    # Build missing versions offline, assemble, and preview
    $(basename "$0")

    # Serve the existing assembled site immediately
    $(basename "$0") --no-build

    # Restore release caches from GHCR before building cache misses
    $(basename "$0") --use-oci-cache

    # Reassemble restored local caches without invoking Swift or DocC
    $(basename "$0") --assemble-only

EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-build)
            BUILD_SITE=false
            shift
            ;;
        --assemble-only)
            ASSEMBLE_ONLY=true
            shift
            ;;
        --rebuild)
            REBUILD=true
            shift
            ;;
        --use-oci-cache)
            USE_OCI_CACHE=true
            shift
            ;;
        --config)
            CONFIG_PATH="$2"
            shift 2
            ;;
        --output)
            OUTPUT_PATH="$2"
            shift 2
            ;;
        --cache)
            CACHE_PATH="$2"
            shift 2
            ;;
        --bind)
            PREVIEW_BIND="$2"
            shift 2
            ;;
        --port)
            PREVIEW_PORT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "error: unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

if [[ ! "$PREVIEW_PORT" =~ ^[0-9]+$ ]] || (( PREVIEW_PORT < 1 || PREVIEW_PORT > 65535 )); then
    echo "error: --port must be an integer from 1 through 65535" >&2
    exit 2
fi

if [[ "$BUILD_SITE" == false ]] && {
    [[ "$ASSEMBLE_ONLY" == true ]] ||
    [[ "$REBUILD" == true ]] ||
    [[ "$USE_OCI_CACHE" == true ]] ||
    [[ -n "$CACHE_PATH" ]];
}; then
    echo "error: --no-build cannot be combined with build-only options" >&2
    exit 2
fi

if [[ "$ASSEMBLE_ONLY" == true ]] && [[ "$REBUILD" == true ]]; then
    echo "error: --assemble-only cannot be combined with --rebuild" >&2
    exit 2
fi

if command -v lsof >/dev/null 2>&1 &&
    lsof -nP -iTCP:"$PREVIEW_PORT" -sTCP:LISTEN >/dev/null 2>&1; then
    echo "error: preview port $PREVIEW_PORT is already in use" >&2
    lsof -nP -iTCP:"$PREVIEW_PORT" -sTCP:LISTEN >&2
    echo "Use --port to select another port." >&2
    exit 1
fi

command -v swift >/dev/null 2>&1 || {
    echo "error: swift is required" >&2
    exit 1
}

if [[ ! -f "$REPO_ROOT/$CONFIG_PATH" ]] && [[ ! -f "$CONFIG_PATH" ]]; then
    echo "error: missing VersionedDocC configuration: $CONFIG_PATH" >&2
    exit 1
fi

cd "$REPO_ROOT"
export OPENSWIFTUI_VERSIONED_DOCC_PLUGIN=1

SWIFT_PLUGIN_ARGUMENTS=(
    --disable-sandbox
    --allow-writing-to-package-directory
    --allow-network-connections all
    versioned-documentation
)

if [[ "$BUILD_SITE" == true ]]; then
    BUILD_ARGUMENTS=(
        build
        --config "$CONFIG_PATH"
        --preview-port "$PREVIEW_PORT"
    )

    if [[ -n "$OUTPUT_PATH" ]]; then
        BUILD_ARGUMENTS+=(--output "$OUTPUT_PATH")
    fi
    if [[ -n "$CACHE_PATH" ]]; then
        BUILD_ARGUMENTS+=(--cache "$CACHE_PATH")
    fi
    if [[ "$ASSEMBLE_ONLY" == true ]]; then
        BUILD_ARGUMENTS+=(--assemble-only)
    fi
    if [[ "$REBUILD" == true ]]; then
        BUILD_ARGUMENTS+=(--rebuild)
    fi
    if [[ "$USE_OCI_CACHE" == false ]]; then
        BUILD_ARGUMENTS+=(--no-oci-cache)
    fi

    swift package "${SWIFT_PLUGIN_ARGUMENTS[@]}" "${BUILD_ARGUMENTS[@]}"
fi

PREVIEW_ARGUMENTS=(
    preview
    --config "$CONFIG_PATH"
    --bind "$PREVIEW_BIND"
    --port "$PREVIEW_PORT"
)

if [[ -n "$OUTPUT_PATH" ]]; then
    PREVIEW_ARGUMENTS+=(--output "$OUTPUT_PATH")
fi

PREVIEW_PROCESS_ID=""

cleanup_preview() {
    local listener_id

    trap - EXIT INT TERM

    if command -v lsof >/dev/null 2>&1; then
        while IFS= read -r listener_id; do
            [[ -n "$listener_id" ]] || continue
            kill -TERM "$listener_id" 2>/dev/null || true
        done < <(lsof -t -iTCP:"$PREVIEW_PORT" -sTCP:LISTEN 2>/dev/null || true)
    fi

    if [[ -n "$PREVIEW_PROCESS_ID" ]]; then
        kill -TERM "$PREVIEW_PROCESS_ID" 2>/dev/null || true
        wait "$PREVIEW_PROCESS_ID" 2>/dev/null || true
        PREVIEW_PROCESS_ID=""
    fi
}

trap cleanup_preview EXIT INT TERM

echo "Starting VersionedDocC preview server. Press Ctrl+C to stop."
swift package "${SWIFT_PLUGIN_ARGUMENTS[@]}" "${PREVIEW_ARGUMENTS[@]}" &
PREVIEW_PROCESS_ID=$!

set +e
wait "$PREVIEW_PROCESS_ID"
PREVIEW_STATUS=$?
set -e

cleanup_preview
trap - EXIT INT TERM
exit "$PREVIEW_STATUS"
