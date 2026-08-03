#!/usr/bin/env bash

TUIST_REPOSITORY_ROOT="$(
    cd "$(dirname "${BASH_SOURCE[0]}")/../.." >/dev/null 2>&1
    pwd -P
)"
TUIST_STATE_DIRECTORY="${TUIST_STATE_DIRECTORY:-${XDG_STATE_HOME:-$HOME/.local/state}/tuist}"
TUIST_CACHE_SOCKET_PATH="${TUIST_CACHE_SOCKET_PATH:-$TUIST_STATE_DIRECTORY/OpenSwiftUIProject_openswiftui.sock}"
TUIST_CACHE_DAEMON_STDERR_PATH="${TUIST_CACHE_DAEMON_STDERR_PATH:-$TUIST_STATE_DIRECTORY/tuist.cache.OpenSwiftUIProject_openswiftui.stderr.log}"
TUIST_MISE_ENVIRONMENT="${TUIST_MISE_ENVIRONMENT:-}"

tuist_use_mise_environment() {
    if [[ $# -ne 1 || -z "$1" ]]; then
        echo "Usage: tuist_use_mise_environment <environment>" >&2
        return 64
    fi

    TUIST_MISE_ENVIRONMENT="$1"
}

tuist_mise() {
    if [[ -n "$TUIST_MISE_ENVIRONMENT" ]]; then
        mise --env "$TUIST_MISE_ENVIRONMENT" "$@"
    else
        mise "$@"
    fi
}

tuist_trust_mise_configuration() {
    mise trust mise.toml

    if [[ -n "$TUIST_MISE_ENVIRONMENT" ]]; then
        local environment_config="mise.$TUIST_MISE_ENVIRONMENT.toml"
        if [[ ! -f "$environment_config" ]]; then
            echo "Mise environment configuration does not exist: $environment_config" >&2
            return 66
        fi
        mise trust "$environment_config"
    fi
}

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

tuist_print_cache_daemon_stderr() {
    if [[ -r "$TUIST_CACHE_DAEMON_STDERR_PATH" ]]; then
        echo "Tuist cache daemon stderr ($TUIST_CACHE_DAEMON_STDERR_PATH):" >&2
        tail -n 200 "$TUIST_CACHE_DAEMON_STDERR_PATH" >&2
    else
        echo "Tuist cache daemon stderr is unavailable at $TUIST_CACHE_DAEMON_STDERR_PATH." >&2
    fi
}

tuist_report_cache_unavailable() {
    local message="$1"

    if [[ "${GITHUB_ACTIONS:-}" == "true" ]]; then
        echo "::warning::$message" >&2
    else
        echo "warning: $message" >&2
    fi

    tuist_print_cache_daemon_stderr
}

tuist_ci_setup() (
    set -e

    cd "$TUIST_REPOSITORY_ROOT"
    tuist_trust_mise_configuration
    tuist_mise install
    tuist_mise exec -- tuist auth login

    if ! tuist_mise exec -- tuist setup cache --path "$TUIST_REPOSITORY_ROOT"; then
        tuist_report_cache_unavailable "Tuist Xcode cache setup failed; continuing without compilation caching."
        return 0
    fi

    if ! tuist_wait_for_cache_service; then
        tuist_report_cache_unavailable "Tuist Xcode cache daemon did not become ready; continuing without compilation caching."
    fi

    return 0
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
    else
        cache_settings=(
            COMPILATION_CACHE_ENABLE_CACHING=NO
            COMPILATION_CACHE_ENABLE_PLUGIN=NO
        )

        if [[ -n "${CI:-}" ]]; then
            tuist_report_cache_unavailable "Tuist Xcode cache service is unavailable at $TUIST_CACHE_SOCKET_PATH; continuing without compilation caching."
        else
            echo "Tuist cache service is unavailable; building without compilation caching." >&2
            echo "Run 'mise exec -- tuist setup cache' to enable it locally." >&2
        fi
    fi

    rm -rf "$result_bundle_path"
    tuist_mise exec -- tuist xcodebuild "$action" \
        -resultBundlePath "$result_bundle_path" \
        "$@" \
        "${cache_settings[@]}"
)
