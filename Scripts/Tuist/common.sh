#!/usr/bin/env bash

TUIST_REPOSITORY_ROOT="$(
    cd "$(dirname "${BASH_SOURCE[0]}")/../.." >/dev/null 2>&1
    pwd -P
)"
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

tuist_ci_setup() (
    set -e

    cd "$TUIST_REPOSITORY_ROOT"
    tuist_trust_mise_configuration
    tuist_mise install
    tuist_mise exec -- tuist auth login
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

    rm -rf "$result_bundle_path"
    # Override remote cache settings from existing generated projects.
    tuist_mise exec -- tuist xcodebuild "$action" \
        -resultBundlePath "$result_bundle_path" \
        "$@" \
        COMPILATION_CACHE_ENABLE_CACHING=NO \
        COMPILATION_CACHE_REMOTE_SERVICE_PATH= \
        COMPILATION_CACHE_ENABLE_PLUGIN=NO
)
