#!/usr/bin/env bash

TUIST_REPOSITORY_ROOT="$(
    cd "$(dirname "${BASH_SOURCE[0]}")/../.." >/dev/null 2>&1
    pwd -P
)"
TUIST_CACHE_SOCKET_PATH="${TUIST_CACHE_SOCKET_PATH:-${XDG_STATE_HOME:-$HOME/.local/state}/tuist/OpenSwiftUIProject_openswiftui.sock}"

tuist_cache_service_is_ready() {
    [[ -S "$TUIST_CACHE_SOCKET_PATH" ]] || return 1

    if command -v lsof >/dev/null 2>&1; then
        lsof "$TUIST_CACHE_SOCKET_PATH" >/dev/null 2>&1
    fi
}

tuist_wait_for_cache_service() {
    local attempt
    for ((attempt = 0; attempt < 40; attempt++)); do
        if tuist_cache_service_is_ready; then
            return 0
        fi
        sleep 0.25
    done

    echo "Tuist cache service is not listening at $TUIST_CACHE_SOCKET_PATH." >&2
    echo "If Tuist reported a different socket, set TUIST_CACHE_SOCKET_PATH to that path." >&2
    return 69
}

tuist_ci_setup() (
    set -e

    cd "$TUIST_REPOSITORY_ROOT"
    mise trust mise.toml
    mise install
    mise exec -- tuist auth login
    mise exec -- tuist setup cache --path "$TUIST_REPOSITORY_ROOT"
    tuist_wait_for_cache_service
)

tuist_xcodebuild() (
    set -e

    if [[ $# -lt 2 ]]; then
        echo "Usage: tuist_xcodebuild <result-bundle.xcresult> <action> [arguments ...]" >&2
        return 64
    fi

    local result_bundle_path="$1"
    local action="$2"
    shift 2

    if [[ -z "$result_bundle_path" || "$result_bundle_path" != *.xcresult ]]; then
        echo "Tuist result bundle path must end in .xcresult: $result_bundle_path" >&2
        return 64
    fi

    if [[ "$result_bundle_path" != /* ]]; then
        result_bundle_path="$PWD/$result_bundle_path"
    fi

    local cache_settings=()
    if tuist_cache_service_is_ready; then
        cache_settings=(
            COMPILATION_CACHE_ENABLE_CACHING=YES
            "COMPILATION_CACHE_REMOTE_SERVICE_PATH=$TUIST_CACHE_SOCKET_PATH"
            COMPILATION_CACHE_ENABLE_PLUGIN=YES
            COMPILATION_CACHE_ENABLE_DIAGNOSTIC_REMARKS=YES
        )
    elif [[ -n "${CI:-}" ]]; then
        echo "Tuist cache service is unavailable at $TUIST_CACHE_SOCKET_PATH." >&2
        return 69
    else
        echo "Tuist cache service is unavailable; building without compilation caching." >&2
        echo "Run 'mise exec -- tuist setup cache' to enable it locally." >&2
        cache_settings=(
            COMPILATION_CACHE_ENABLE_CACHING=NO
            COMPILATION_CACHE_ENABLE_PLUGIN=NO
        )
    fi

    rm -rf "$result_bundle_path"
    mise exec -- tuist xcodebuild "$action" \
        -resultBundlePath "$result_bundle_path" \
        "$@" \
        "${cache_settings[@]}"
)
