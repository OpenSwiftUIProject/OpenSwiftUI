#!/bin/bash

##===----------------------------------------------------------------------===##
##
## This source file is part of the OpenSwiftUI open source project
##
## Copyright (c) 2025 the OpenSwiftUI project authors
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
DOCS_DIR="$REPO_ROOT/.docs"
BUILD_DIR="$DOCS_DIR/build"
SYMBOL_GRAPH_DIR="$BUILD_DIR/symbol-graphs"
DOCC_OUTPUT_DIR="$BUILD_DIR/docc-output"

# Default configuration
PREVIEW_MODE=false
MINIMUM_ACCESS_LEVEL="public"
TARGET_NAME="OpenSwiftUI"
HOSTING_BASE_PATH=""
CLEAN_BUILD=false
PREVIEW_PORT=8000

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Build and publish Swift documentation to GitHub Pages using DocC.

OPTIONS:
    --preview                  Preview documentation locally instead of publishing
    --minimum-access-level     Set minimum access level (public, internal, private)
                              Default: public
    --target TARGET           Target to document (default: OpenSwiftUI)
    --hosting-base-path PATH  Base path for hosting (e.g., /OpenSwiftUI)
    --port PORT               Port for preview server (default: 8000)
    --clean                   Clean build artifacts and force rebuild
    -h, --help                Show this help message

EXAMPLES:
    # Build and publish to GitHub Pages
    $(basename "$0")

    # Preview documentation locally
    $(basename "$0") --preview

    # Include internal symbols
    $(basename "$0") --minimum-access-level internal --preview

    # Document a specific target
    $(basename "$0") --target OpenSwiftUICore --preview

EOF
    exit 0
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to run docc command
rundocc() {
    if command -v xcrun >/dev/null 2>&1; then
        xcrun docc "$@"
    else
        docc "$@"
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --preview)
            PREVIEW_MODE=true
            shift
            ;;
        --minimum-access-level)
            MINIMUM_ACCESS_LEVEL="$2"
            shift 2
            ;;
        --target)
            TARGET_NAME="$2"
            shift 2
            ;;
        --hosting-base-path)
            HOSTING_BASE_PATH="$2"
            shift 2
            ;;
        --port)
            PREVIEW_PORT="$2"
            shift 2
            ;;
        --clean)
            CLEAN_BUILD=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate minimum access level
case "$MINIMUM_ACCESS_LEVEL" in
    public|internal|private|fileprivate)
        ;;
    *)
        log_error "Invalid minimum access level: $MINIMUM_ACCESS_LEVEL"
        log_error "Valid values: public, internal, private, fileprivate"
        exit 1
        ;;
esac

log_info "Configuration:"
log_info "  Target: $TARGET_NAME"
log_info "  Minimum Access Level: $MINIMUM_ACCESS_LEVEL"
log_info "  Preview Mode: $PREVIEW_MODE"
if [[ -n "$HOSTING_BASE_PATH" ]]; then
    log_info "  Hosting Base Path: $HOSTING_BASE_PATH"
fi

# Check for required tools
command -v swift >/dev/null 2>&1 || {
    log_error "swift is required but not installed. Aborting."
    exit 1
}

# Check for docc
if ! command -v docc >/dev/null 2>&1 && ! command -v xcrun >/dev/null 2>&1; then
    log_error "docc is required but not found. Please install Swift-DocC."
    exit 1
fi

# Clean build if requested
if [[ "$CLEAN_BUILD" == true ]]; then
    log_info "Cleaning build artifacts..."
    swift package clean
    rm -rf "$DOCS_DIR"
fi

# Create build directories
log_info "Preparing build directories..."
mkdir -p "$SYMBOL_GRAPH_DIR"
mkdir -p "$DOCC_OUTPUT_DIR"

# Step 1: Generate symbol graphs
cd "$REPO_ROOT"

# Use default .build directory for symbol graphs (reuses existing build)
SWIFT_BUILD_DIR=".build"
DEFAULT_SYMBOL_GRAPH_DIR="$SWIFT_BUILD_DIR/symbol-graphs"

# Check if symbol graphs already exist with correct access level
REBUILD_NEEDED=false
if [[ ! -d "$DEFAULT_SYMBOL_GRAPH_DIR" ]] || [[ -z "$(ls -A "$DEFAULT_SYMBOL_GRAPH_DIR" 2>/dev/null)" ]]; then
    REBUILD_NEEDED=true
    log_info "No existing symbol graphs found, building..."
else
    log_info "Found existing symbol graphs, reusing them (use --clean to rebuild)"
fi

if [[ "$REBUILD_NEEDED" == true ]] || [[ "$CLEAN_BUILD" == true ]]; then
    log_info "Generating symbol graphs..."
    swift build \
        -Xswiftc -emit-symbol-graph \
        -Xswiftc -emit-symbol-graph-dir \
        -Xswiftc "$DEFAULT_SYMBOL_GRAPH_DIR" \
        -Xswiftc -symbol-graph-minimum-access-level \
        -Xswiftc "$MINIMUM_ACCESS_LEVEL"

    if [[ ! -d "$DEFAULT_SYMBOL_GRAPH_DIR" ]] || [[ -z "$(ls -A "$DEFAULT_SYMBOL_GRAPH_DIR")" ]]; then
        log_error "Symbol graph generation failed or produced no output"
        exit 1
    fi
fi

# Filter symbol graphs for the target module
log_info "Filtering symbol graphs for $TARGET_NAME..."
if ls "$DEFAULT_SYMBOL_GRAPH_DIR/${TARGET_NAME}"*.symbols.json >/dev/null 2>&1; then
    cp "$DEFAULT_SYMBOL_GRAPH_DIR/${TARGET_NAME}"*.symbols.json "$SYMBOL_GRAPH_DIR/"
    log_info "Symbol graphs for $TARGET_NAME copied successfully"
else
    log_warning "No symbol graphs found for $TARGET_NAME, using all available symbol graphs"
    cp "$DEFAULT_SYMBOL_GRAPH_DIR"/*.symbols.json "$SYMBOL_GRAPH_DIR/"
fi

# Step 2: Find or create documentation catalog
DOCC_CATALOG=""
if [[ -d "Sources/$TARGET_NAME/${TARGET_NAME}.docc" ]]; then
    DOCC_CATALOG="Sources/$TARGET_NAME/${TARGET_NAME}.docc"
    log_info "Using documentation catalog: $DOCC_CATALOG"
else
    log_warning "No .docc catalog found for $TARGET_NAME"
    log_info "DocC will generate documentation from symbol graphs only"
fi

# Step 3: Build documentation
log_info "Building documentation archive..."

if [[ -n "$DOCC_CATALOG" ]]; then
    # We have a .docc catalog
    DOCC_ARGS=(
        "$DOCC_CATALOG"
        --output-path "$DOCC_OUTPUT_DIR"
        --emit-digest
        --transform-for-static-hosting
    )

    if [[ -n "$HOSTING_BASE_PATH" ]]; then
        DOCC_ARGS+=(--hosting-base-path "$HOSTING_BASE_PATH")
    fi

    # Add symbol graph directory if we have symbol graphs
    if [[ -d "$SYMBOL_GRAPH_DIR" ]] && [[ -n "$(ls -A "$SYMBOL_GRAPH_DIR")" ]]; then
        DOCC_ARGS+=(--additional-symbol-graph-dir "$SYMBOL_GRAPH_DIR")
    fi

    rundocc convert "${DOCC_ARGS[@]}"
else
    # No .docc catalog, create one from symbol graphs
    TEMP_DOCC_CATALOG="$BUILD_DIR/${TARGET_NAME}.docc"
    mkdir -p "$TEMP_DOCC_CATALOG"

    # Copy symbol graphs into the catalog
    if [[ -d "$SYMBOL_GRAPH_DIR" ]] && [[ -n "$(ls -A "$SYMBOL_GRAPH_DIR")" ]]; then
        cp "$SYMBOL_GRAPH_DIR"/*.symbols.json "$TEMP_DOCC_CATALOG/"
    fi

    DOCC_ARGS=(
        "$TEMP_DOCC_CATALOG"
        --output-path "$DOCC_OUTPUT_DIR"
        --emit-digest
        --transform-for-static-hosting
    )

    if [[ -n "$HOSTING_BASE_PATH" ]]; then
        DOCC_ARGS+=(--hosting-base-path "$HOSTING_BASE_PATH")
    fi

    rundocc convert "${DOCC_ARGS[@]}"
fi

log_info "Documentation built successfully"

# Step 4: Preview or publish
if [[ "$PREVIEW_MODE" == true ]]; then
    # Check if port is already in use
    if lsof -Pi :$PREVIEW_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        log_warning "Port $PREVIEW_PORT is already in use"

        # Find the process using the port
        PORT_PID=$(lsof -Pi :$PREVIEW_PORT -sTCP:LISTEN -t)
        PORT_PROCESS=$(ps -p $PORT_PID -o command= 2>/dev/null || echo "Unknown process")

        log_info "Process using port $PREVIEW_PORT (PID $PORT_PID): $PORT_PROCESS"

        # Ask user if they want to kill it
        read -p "Do you want to kill this process and start the preview server? (y/N): " -n 1 -r
        echo

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Killing process $PORT_PID..."
            kill $PORT_PID
            sleep 1

            # Verify it's killed
            if lsof -Pi :$PREVIEW_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
                log_error "Failed to kill process on port $PREVIEW_PORT"
                exit 1
            fi
            log_info "Process killed successfully"
        else
            log_error "Cannot start preview server. Please free port $PREVIEW_PORT or use --port option"
            exit 1
        fi
    fi

    log_info "Starting preview server on port $PREVIEW_PORT..."
    log_info "Documentation will be available at: http://localhost:$PREVIEW_PORT/documentation/$TARGET_NAME"
    log_info "Press Ctrl+C to stop the server"

    cd "$DOCC_OUTPUT_DIR"
    python3 -m http.server $PREVIEW_PORT
else
    # Prepare for GitHub Pages deployment
    GH_PAGES_DIR="$DOCS_DIR/gh-pages"

    log_info "Preparing GitHub Pages deployment..."

    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Not in a git repository. Cannot deploy to GitHub Pages."
        exit 1
    fi

    # Store current branch
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

    # Check if gh-pages branch exists
    if git show-ref --verify --quiet refs/heads/gh-pages; then
        log_info "Using existing gh-pages branch"
        git fetch origin gh-pages
        git worktree add "$GH_PAGES_DIR" gh-pages || {
            log_warning "Worktree already exists, removing and recreating..."
            git worktree remove "$GH_PAGES_DIR" --force
            git worktree add "$GH_PAGES_DIR" gh-pages
        }
    else
        log_info "Creating new gh-pages branch"
        git worktree add --detach "$GH_PAGES_DIR"
        cd "$GH_PAGES_DIR"
        git checkout --orphan gh-pages
        git rm -rf . 2>/dev/null || true
        cd "$REPO_ROOT"
    fi

    # Copy documentation to gh-pages worktree
    log_info "Copying documentation files..."
    rsync -av --delete "$DOCC_OUTPUT_DIR/" "$GH_PAGES_DIR/"

    # Add .nojekyll to prevent GitHub Pages from processing with Jekyll
    touch "$GH_PAGES_DIR/.nojekyll"

    # Commit and push
    cd "$GH_PAGES_DIR"
    git add -A

    if git diff --cached --quiet; then
        log_info "No changes to documentation"
    else
        log_info "Committing documentation changes..."
        git commit -m "Update documentation (generated from $CURRENT_BRANCH@$(git -C "$REPO_ROOT" rev-parse --short HEAD))"

        log_info "Pushing to gh-pages branch..."
        git push origin gh-pages

        log_info "${GREEN}✓${NC} Documentation published successfully!"
        log_info "GitHub Pages will be updated shortly at your repository's GitHub Pages URL"
    fi

    # Cleanup
    cd "$REPO_ROOT"
    git worktree remove "$GH_PAGES_DIR"

    log_info "Cleaning up build artifacts..."
    rm -rf "$DOCS_DIR"
fi

log_info "Done!"
