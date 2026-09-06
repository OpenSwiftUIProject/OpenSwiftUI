#!/usr/bin/env bash

set -euo pipefail

TEST_DIRECTORY="$(
    cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
    pwd -P
)"
# shellcheck source=/dev/null
source "$TEST_DIRECTORY/../common.sh"

assert_contains() {
    local file="$1"
    local expected="$2"

    if ! grep -Fq -- "$expected" "$file"; then
        echo "Expected $file to contain: $expected" >&2
        echo "Actual contents:" >&2
        sed 's/^/    /' "$file" >&2
        return 1
    fi
}

assert_not_contains() {
    local file="$1"
    local unexpected="$2"

    if grep -Fq -- "$unexpected" "$file"; then
        echo "Expected $file not to contain: $unexpected" >&2
        echo "Actual contents:" >&2
        sed 's/^/    /' "$file" >&2
        return 1
    fi
}

configure_test_environment() {
    local temporary_directory="$1"

    TEST_COMMAND_LOG="$temporary_directory/commands.log"
    TEST_OUTPUT_LOG="$temporary_directory/output.log"
    export CI=1
    export GITHUB_ACTIONS=true

    : >"$TEST_COMMAND_LOG"
}

tuist_trust_mise_configuration() {
    :
}

tuist_mise() {
    printf '%s\n' "$*" >>"$TEST_COMMAND_LOG"

    if [[ "$*" == "install" && "${TEST_INSTALL_SHOULD_FAIL:-false}" == "true" ]]; then
        return 1
    fi

    if [[ "$*" == "exec -- tuist auth login" && "${TEST_AUTH_SHOULD_FAIL:-false}" == "true" ]]; then
        return 1
    fi
}

test_ci_setup_does_not_start_cache() (
    local temporary_directory
    temporary_directory="$(mktemp -d)"
    trap 'rm -rf "$temporary_directory"' EXIT
    configure_test_environment "$temporary_directory"

    tuist_ci_setup >"$TEST_OUTPUT_LOG" 2>&1

    assert_contains "$TEST_COMMAND_LOG" "install"
    assert_contains "$TEST_COMMAND_LOG" "tuist auth login"
    assert_not_contains "$TEST_COMMAND_LOG" "tuist setup cache"
)

test_build_disables_remote_cache_locally_and_in_ci() (
    local temporary_directory
    temporary_directory="$(mktemp -d)"
    trap 'rm -rf "$temporary_directory"' EXIT
    configure_test_environment "$temporary_directory"

    local environment
    for environment in local ci; do
        if [[ "$environment" == local ]]; then
            unset CI GITHUB_ACTIONS
        else
            export CI=1
            export GITHUB_ACTIONS=true
        fi

        : >"$TEST_COMMAND_LOG"
        tuist_xcodebuild "$temporary_directory/result.xcresult" build -scheme Example \
            COMPILATION_CACHE_ENABLE_CACHING=YES \
            COMPILATION_CACHE_REMOTE_SERVICE_PATH=/tmp/old-tuist-cache.sock \
            COMPILATION_CACHE_ENABLE_PLUGIN=YES >"$TEST_OUTPUT_LOG" 2>&1

        assert_contains "$TEST_COMMAND_LOG" "tuist xcodebuild build -resultBundlePath $temporary_directory/result.xcresult -scheme Example"
        local build_command
        build_command="$(tail -n 1 "$TEST_COMMAND_LOG")"
        if [[ "$build_command" != *"COMPILATION_CACHE_ENABLE_CACHING=NO COMPILATION_CACHE_REMOTE_SERVICE_PATH= COMPILATION_CACHE_ENABLE_PLUGIN=NO" ]]; then
            echo "Expected the $environment build to override remote cache settings." >&2
            return 1
        fi
        assert_not_contains "$TEST_OUTPUT_LOG" "::warning::"
        assert_not_contains "$TEST_OUTPUT_LOG" "tuist setup cache"
    done
)

test_authentication_failure_remains_fatal() (
    local temporary_directory
    temporary_directory="$(mktemp -d)"
    trap 'rm -rf "$temporary_directory"' EXIT
    configure_test_environment "$temporary_directory"
    TEST_AUTH_SHOULD_FAIL=true

    set +e
    tuist_ci_setup >"$TEST_OUTPUT_LOG" 2>&1
    local status=$?
    set -e

    if [[ $status -eq 0 ]]; then
        echo "Expected Tuist authentication failure to remain fatal." >&2
        return 1
    fi

    assert_not_contains "$TEST_COMMAND_LOG" "tuist setup cache"
)

test_mise_install_failure_remains_fatal() (
    local temporary_directory
    temporary_directory="$(mktemp -d)"
    trap 'rm -rf "$temporary_directory"' EXIT
    configure_test_environment "$temporary_directory"
    TEST_INSTALL_SHOULD_FAIL=true

    set +e
    tuist_ci_setup >"$TEST_OUTPUT_LOG" 2>&1
    local status=$?
    set -e

    if [[ $status -eq 0 ]]; then
        echo "Expected mise installation failure to remain fatal." >&2
        return 1
    fi

    assert_not_contains "$TEST_COMMAND_LOG" "tuist auth login"
    assert_not_contains "$TEST_COMMAND_LOG" "tuist setup cache"
)

run_test() {
    local test_name="$1"
    local status

    set +e
    (
        set -e
        "$test_name"
    )
    status=$?
    set -e

    if [[ $status -eq 0 ]]; then
        echo "PASS: $test_name"
    else
        echo "FAIL: $test_name" >&2
        return 1
    fi
}

run_test test_ci_setup_does_not_start_cache
run_test test_build_disables_remote_cache_locally_and_in_ci
run_test test_authentication_failure_remains_fatal
run_test test_mise_install_failure_remains_fatal
