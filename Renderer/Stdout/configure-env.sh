#!/usr/bin/env bash

# Sourced by the stdout run and test entry points.
case "$(uname -s)" in
Darwin)
    export OPENSWIFTUI_OPENATTRIBUTESHIMS_ATTRIBUTEGRAPH="${OPENSWIFTUI_OPENATTRIBUTESHIMS_ATTRIBUTEGRAPH:-1}"
    export OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE="${OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE:-0}"
    ;;
*)
    export OPENSWIFTUI_OPENATTRIBUTESHIMS_ATTRIBUTEGRAPH="${OPENSWIFTUI_OPENATTRIBUTESHIMS_ATTRIBUTEGRAPH:-0}"
    export OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE="${OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE:-1}"
    export OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE_SOURCE_VERSION="${OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE_SOURCE_VERSION:-0.5.2-bugfix.1}"
    if [[ -z "${OPENSWIFTUI_LIB_SWIFT_PATH:-}" ]]; then
        swift_binary="$(readlink -f "$(command -v swift)")"
        if [[ "$(basename "$swift_binary")" == "swiftly" ]]; then
            OPENSWIFTUI_LIB_SWIFT_PATH="$(swiftly use --print-location)/usr/lib/swift"
        else
            OPENSWIFTUI_LIB_SWIFT_PATH="$(dirname "$(dirname "$swift_binary")")/lib/swift"
        fi
    fi
    export OPENSWIFTUI_LIB_SWIFT_PATH
    swift_library_path="$(dirname "$OPENSWIFTUI_LIB_SWIFT_PATH")"
    export LIBRARY_PATH="$swift_library_path${LIBRARY_PATH:+:$LIBRARY_PATH}"
    export LD_LIBRARY_PATH="$swift_library_path${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    ;;
esac
