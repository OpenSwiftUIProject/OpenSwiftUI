#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

KEEP_DERIVED_DATA=true
SKIP_TUIST_INSTALL=false
FRAMEWORK_NAMES=()

# Rough planning estimates for a recent Apple Silicon Mac with dependencies
# already installed. These are not benchmarks: Xcode/Swift versions, thermal
# state, local/remote compilation caches, and the changed module all matter.
#
#                             Clean build      Warm no-change build
#   OpenSwiftUICore           ~3-8 minutes     ~10-60 seconds
#   OpenSwiftUI (plus Core)   ~5-12 minutes    ~20-90 seconds
#
# A Release source change, especially in OpenSwiftUICore, can invalidate most of
# the target and bring a nominally warm build close to the clean-build range.
print_usage() {
    cat <<'USAGE'
Usage: Scripts/build_xcframework_slice.sh [options] [osuicore|osui ...]

Build a single-architecture Release XCFramework for local binary comparison.
The default target is OpenSwiftUICore.

Typical timing on a recent Apple Silicon Mac (rough planning estimates):
  OpenSwiftUICore           clean ~3-8 min;  warm no-change ~10-60 sec
  OpenSwiftUI (plus Core)   clean ~5-12 min; warm no-change ~20-90 sec
A Release source change can make a warm build approach the clean-build range.

Options:
  --clean                 Discard DerivedData before building.
  --skip-tuist-install    Skip tuist install.
  --help                  Show this help.

Targets:
  osuicore, OpenSwiftUICore   Build OpenSwiftUICore.
  osui, OpenSwiftUI           Build OpenSwiftUI.

Examples:
  Scripts/build_xcframework_slice.sh
  Scripts/build_xcframework_slice.sh osui
  Scripts/build_xcframework_slice.sh --clean osuicore osui
USAGE
}

format_duration() {
    local total_seconds="$1"
    printf '%02d:%02d:%02d' \
        "$((total_seconds / 3600))" \
        "$(((total_seconds % 3600) / 60))" \
        "$((total_seconds % 60))"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)
            print_usage
            exit 0
            ;;
        --clean)
            KEEP_DERIVED_DATA=false
            shift
            ;;
        --skip-tuist-install)
            SKIP_TUIST_INSTALL=true
            shift
            ;;
        osuicore|OpenSwiftUICore)
            FRAMEWORK_NAMES+=("OpenSwiftUICore")
            shift
            ;;
        osui|OpenSwiftUI)
            FRAMEWORK_NAMES+=("OpenSwiftUI")
            shift
            ;;
        *)
            echo "Error: Unknown argument: $1" >&2
            print_usage >&2
            exit 64
            ;;
    esac
done

if [ ${#FRAMEWORK_NAMES[@]} -eq 0 ]; then
    FRAMEWORK_NAMES=("OpenSwiftUICore")
fi

build_args=(
    --compute
    --sdk iphonesimulator
    --archs arm64
)

if [ "$KEEP_DERIVED_DATA" = true ]; then
    build_args+=(--keep-derived-data)
fi

if [ "$SKIP_TUIST_INSTALL" = true ]; then
    build_args+=(--skip-tuist-install)
fi

for framework_name in "${FRAMEWORK_NAMES[@]}"; do
    build_args+=(--framework "$framework_name")
done

project_build_dir="${PROJECT_BUILD_DIR:-"$PROJECT_ROOT/build"}"
if [[ "$project_build_dir" != /* ]]; then
    project_build_dir="$PROJECT_ROOT/$project_build_dir"
fi
derived_data_path="$project_build_dir/DerivedData"

if [ "$KEEP_DERIVED_DATA" = false ]; then
    cache_state="cold (--clean requested)"
elif [ -d "$derived_data_path" ]; then
    cache_state="warm (reusing existing DerivedData)"
else
    cache_state="cold (no existing DerivedData)"
fi

display_command=(Scripts/build_xcframework.sh "${build_args[@]}")
printf -v command_line '%q ' "${display_command[@]}"
command_line="${command_line% }"

started_at="$(date '+%Y-%m-%dT%H:%M:%S%z')"
started_seconds=$SECONDS

echo "Local XCFramework build started"
echo "  Started:       $started_at"
echo "  Cache state:   $cache_state"
echo "  Frameworks:    ${FRAMEWORK_NAMES[*]}"
echo "  Configuration: Release"
echo "  Backend:       Compute"
echo "  SDK:           iphonesimulator"
echo "  Architectures: arm64"
echo "  DerivedData:   $derived_data_path"
echo "  Command:       $command_line"
echo

if "$SCRIPT_DIR/build_xcframework.sh" "${build_args[@]}"; then
    build_status=0
    result="succeeded"
else
    build_status=$?
    result="failed (exit $build_status)"
fi

elapsed_seconds=$((SECONDS - started_seconds))
finished_at="$(date '+%Y-%m-%dT%H:%M:%S%z')"

echo
echo "Local XCFramework build $result"
echo "  Finished:          $finished_at"
echo "  Elapsed:           $(format_duration "$elapsed_seconds")"
echo "  Cache state:       $cache_state"
echo "  Frameworks:        ${FRAMEWORK_NAMES[*]}"
echo "  Completed command: $command_line"

exit "$build_status"
