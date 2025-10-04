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
DOCC_OUTPUT_DIR="$BUILD_DIR/docc-output"

# Default configuration
BUILD_DOCS=true
MINIMUM_ACCESS_LEVEL="public"
TARGET_NAME="OpenSwiftUI"
HOSTING_BASE_PATH=""
CLEAN_BUILD=false
SOURCE_SERVICE="github"
SOURCE_SERVICE_BASE_URL="https://github.com/OpenSwiftUIProject/OpenSwiftUI/blob/main"
FORCE_PUSH=true  # Force push to save git repo size (avoids accumulating large binary files)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Publish Swift documentation to GitHub Pages using DocC.

This script will build documentation (or use existing build) and deploy it
to the gh-pages branch for GitHub Pages hosting.

OPTIONS:
    --no-build                    Skip building documentation (use existing output)
    --minimum-access-level LEVEL  Set minimum access level (public, internal, private)
                                  Default: public
    --target TARGET               Target to document (default: OpenSwiftUI)
    --hosting-base-path PATH      Base path for hosting (e.g., /OpenSwiftUI)
    --source-service SERVICE      Source service (github, gitlab, bitbucket)
    --source-service-base-url URL Base URL for source service
                                  (e.g., https://github.com/user/repo/blob/main)
    --no-force                    Don't force push (preserves gh-pages history)
                                  Default: force push to save repo size
    --clean                       Clean build artifacts and force rebuild
    -h, --help                    Show this help message

EXAMPLES:
    # Build and publish to GitHub Pages (source links enabled by default)
    $(basename "$0")

    # Publish using existing documentation build
    $(basename "$0") --no-build

    # Build with internal symbols and publish
    $(basename "$0") --minimum-access-level internal

    # Document a specific target
    $(basename "$0") --target OpenSwiftUICore

    # Build and publish with custom source service (e.g., for a fork)
    $(basename "$0") \\
        --source-service github \\
        --source-service-base-url https://github.com/yourname/OpenSwiftUI/blob/custom-branch

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

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-build)
            BUILD_DOCS=false
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
        --source-service)
            SOURCE_SERVICE="$2"
            shift 2
            ;;
        --source-service-base-url)
            SOURCE_SERVICE_BASE_URL="$2"
            shift 2
            ;;
        --no-force)
            FORCE_PUSH=false
            shift
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

log_info "Configuration:"
log_info "  Target: $TARGET_NAME"
log_info "  Build Documentation: $BUILD_DOCS"
log_info "  Force Push: $FORCE_PUSH"
if [[ -n "$HOSTING_BASE_PATH" ]]; then
    log_info "  Hosting Base Path: $HOSTING_BASE_PATH"
fi

# Check for required tools
command -v git >/dev/null 2>&1 || {
    log_error "git is required but not installed. Aborting."
    exit 1
}

# Build documentation if requested
if [[ "$BUILD_DOCS" == true ]]; then
    log_info "Building documentation..."

    BUILD_SCRIPT="$SCRIPT_DIR/build-documentation.sh"
    if [[ ! -f "$BUILD_SCRIPT" ]]; then
        log_error "Build script not found: $BUILD_SCRIPT"
        exit 1
    fi

    BUILD_ARGS=()
    BUILD_ARGS+=(--target "$TARGET_NAME")
    BUILD_ARGS+=(--minimum-access-level "$MINIMUM_ACCESS_LEVEL")

    if [[ -n "$HOSTING_BASE_PATH" ]]; then
        BUILD_ARGS+=(--hosting-base-path "$HOSTING_BASE_PATH")
    fi

    if [[ -n "$SOURCE_SERVICE" ]]; then
        BUILD_ARGS+=(--source-service "$SOURCE_SERVICE")
        BUILD_ARGS+=(--source-service-base-url "$SOURCE_SERVICE_BASE_URL")
    fi

    if [[ "$CLEAN_BUILD" == true ]]; then
        BUILD_ARGS+=(--clean)
    fi

    "$BUILD_SCRIPT" "${BUILD_ARGS[@]}"
fi

# Verify documentation output exists
if [[ ! -d "$DOCC_OUTPUT_DIR" ]] || [[ -z "$(ls -A "$DOCC_OUTPUT_DIR" 2>/dev/null)" ]]; then
    log_error "Documentation output not found at: $DOCC_OUTPUT_DIR"
    log_error "Please build documentation first or run without --no-build"
    exit 1
fi

log_info "Using documentation from: $DOCC_OUTPUT_DIR"

# Deploy to GitHub Pages
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
    git fetch origin gh-pages 2>/dev/null || true
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
    if [[ "$FORCE_PUSH" == true ]]; then
        log_info "Using --force to save git repo size (avoids accumulating large binary files)"
        git push --force origin gh-pages
    else
        git push origin gh-pages
    fi

    log_info "${GREEN}✓${NC} Documentation published successfully!"
    log_info "GitHub Pages will be updated shortly at your repository's GitHub Pages URL"
fi

# Cleanup
cd "$REPO_ROOT"
git worktree remove "$GH_PAGES_DIR"

log_info "Cleaning up build artifacts..."
rm -rf "$DOCS_DIR"

log_info "Done!"
