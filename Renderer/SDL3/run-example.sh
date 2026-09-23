#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.."
export OPENSWIFTUI_UI_FRAMEWORK=SDL3
export OPENSWIFTUI_SWIFTUI_RENDERER=0
export OPENSWIFTUI_USE_LOCAL_DEPS=1
export OPENATTRIBUTEGRAPH_USE_LOCAL_DEPS=1
export OPENSWIFTUI_LIBRARY_EVOLUTION=0
export OPENSWIFTUI_WERROR=0

case "$(uname -s)" in
Darwin)
    export OPENSWIFTUI_OPENATTRIBUTESHIMS_ATTRIBUTEGRAPH=1
    export OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE=0
    ;;
Linux)
    export OPENSWIFTUI_OPENATTRIBUTESHIMS_ATTRIBUTEGRAPH=0
    export OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE=1
    export OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE_BINARY=0
    export OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE_SOURCE_VERSION=0.5.2-bugfix.1
    if [[ -z "${OPENSWIFTUI_LIB_SWIFT_PATH:-}" ]]; then
        swift_binary="$(readlink -f "$(command -v swift)")"
        if [[ "$(basename "$swift_binary")" == swiftly ]]; then
            OPENSWIFTUI_LIB_SWIFT_PATH="$(swiftly use --print-location)/usr/lib/swift"
        else
            OPENSWIFTUI_LIB_SWIFT_PATH="$(dirname "$(dirname "$swift_binary")")/lib/swift"
        fi
    fi
    export OPENSWIFTUI_LIB_SWIFT_PATH
    export LIBRARY_PATH="$(dirname "$OPENSWIFTUI_LIB_SWIFT_PATH")${LIBRARY_PATH:+:$LIBRARY_PATH}"
    export LD_LIBRARY_PATH="$(dirname "$OPENSWIFTUI_LIB_SWIFT_PATH")${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    ;;
esac

swift_command="${SWIFT_COMMAND:-swift}"
build_dir="${OPENSWIFTUI_SDL_BUILD_PATH:-.build-sdl3}"
case "${1:-run}" in
build)
    exec "$swift_command" build --scratch-path "$build_dir" --product OpenSwiftUISDL3Demo
    ;;
run)
    exec "$swift_command" run --scratch-path "$build_dir" OpenSwiftUISDL3Demo
    ;;
launch)
    exec "$build_dir/debug/OpenSwiftUISDL3Demo"
    ;;
test)
    exec "$swift_command" test --scratch-path "$build_dir" --filter "${OPENSWIFTUI_SDL_TEST_FILTER:-SDLViewUpdaterTests}"
    ;;
*)
    printf 'Usage: %s [build|run|launch|test]\n' "$0" >&2
    exit 2
    ;;
esac
