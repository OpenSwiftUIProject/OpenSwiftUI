#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
should_open=1
case "${1:-}" in
--no-open) should_open=0 ;;
"") ;;
*) printf 'Usage: %s [--no-open]\n' "$0" >&2; exit 2 ;;
esac

if [[ "$(uname -s)" != Darwin ]]; then
    printf 'The Tuist Xcode workflow is only available on macOS. Use run-example.sh on Linux.\n' >&2
    exit 1
fi

cd "$script_dir"
export OPENSWIFTUI_UI_FRAMEWORK=SDL3
export OPENSWIFTUI_SWIFTUI_RENDERER=0
export OPENSWIFTUI_USE_LOCAL_DEPS=1
export OPENATTRIBUTEGRAPH_USE_LOCAL_DEPS=1
export OPENSWIFTUI_OPENATTRIBUTESHIMS_ATTRIBUTEGRAPH=1
export OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE=0
export OPENSWIFTUI_LIBRARY_EVOLUTION=0
export OPENSWIFTUI_WERROR=0

run_tuist() {
    if command -v mise >/dev/null 2>&1; then
        mise exec -- tuist "$@"
    else
        tuist "$@"
    fi
}

if command -v mise >/dev/null 2>&1; then
    mise trust "$script_dir/../../mise.toml"
fi
run_tuist install
run_tuist generate --no-open
if [[ "$should_open" == 1 ]]; then
    developer_dir="${DEVELOPER_DIR:-$(xcode-select -p)}"
    xcode_app="${developer_dir%/Contents/Developer}"
    if [[ "$xcode_app" == *.app && -d "$xcode_app" ]]; then
        open -a "$xcode_app" SDL3.xcworkspace
    else
        open SDL3.xcworkspace
    fi
fi
