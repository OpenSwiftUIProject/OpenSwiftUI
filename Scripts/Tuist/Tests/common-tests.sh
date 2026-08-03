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
    TEST_CACHE_READY_FLAG="$temporary_directory/cache-ready"
    TUIST_CACHE_SOCKET_PATH="$temporary_directory/cache.sock"
    TUIST_CACHE_DAEMON_STDERR_PATH="$temporary_directory/cache-daemon.stderr.log"
    export CI=1
    export GITHUB_ACTIONS=true

    : >"$TEST_COMMAND_LOG"
    echo "cache daemon test failure" >"$TUIST_CACHE_DAEMON_STDERR_PATH"
}

tuist_trust_mise_configuration() {
    :
}

tuist_cache_service_is_ready() {
    [[ -e "$TEST_CACHE_READY_FLAG" ]]
}

tuist_wait_for_cache_service() {
    tuist_cache_service_is_ready || return 69
}

tuist_mise() {
    printf '%s\n' "$*" >>"$TEST_COMMAND_LOG"

    if [[ "$*" == "install" && "${TEST_INSTALL_SHOULD_FAIL:-false}" == "true" ]]; then
        return 1
    fi

    if [[ "$*" == "exec -- tuist setup cache --path $TUIST_REPOSITORY_ROOT" && "${TEST_SETUP_SHOULD_FAIL:-false}" == "true" ]]; then
        return 1
    fi

    if [[ "$*" == "exec -- tuist auth login" && "${TEST_AUTH_SHOULD_FAIL:-false}" == "true" ]]; then
        return 1
    fi
}

test_healthy_cache_uses_remote_compilation_cache() (
    local temporary_directory
    temporary_directory="$(mktemp -d)"
    trap 'rm -rf "$temporary_directory"' EXIT
    configure_test_environment "$temporary_directory"
    touch "$TEST_CACHE_READY_FLAG"

    tuist_ci_setup >"$TEST_OUTPUT_LOG" 2>&1
    tuist_xcodebuild "$temporary_directory/result.xcresult" build -scheme Example >"$TEST_OUTPUT_LOG" 2>&1

    assert_contains "$TEST_COMMAND_LOG" "COMPILATION_CACHE_ENABLE_CACHING=YES"
    assert_contains "$TEST_COMMAND_LOG" "COMPILATION_CACHE_REMOTE_SERVICE_PATH=$TUIST_CACHE_SOCKET_PATH"
    assert_contains "$TEST_COMMAND_LOG" "COMPILATION_CACHE_ENABLE_PLUGIN=YES"
    assert_not_contains "$TEST_COMMAND_LOG" "COMPILATION_CACHE_ENABLE_CACHING=NO"
)

test_cache_setup_failure_is_non_fatal_and_reports_diagnostics() (
    local temporary_directory
    temporary_directory="$(mktemp -d)"
    trap 'rm -rf "$temporary_directory"' EXIT
    configure_test_environment "$temporary_directory"
    TEST_SETUP_SHOULD_FAIL=true

    tuist_ci_setup >"$TEST_OUTPUT_LOG" 2>&1

    assert_contains "$TEST_OUTPUT_LOG" "::warning::Tuist Xcode cache setup failed; continuing without compilation caching."
    assert_contains "$TEST_OUTPUT_LOG" "cache daemon test failure"
)

test_cache_readiness_failure_is_non_fatal_and_reports_diagnostics() (
    local temporary_directory
    temporary_directory="$(mktemp -d)"
    trap 'rm -rf "$temporary_directory"' EXIT
    configure_test_environment "$temporary_directory"

    tuist_ci_setup >"$TEST_OUTPUT_LOG" 2>&1

    assert_contains "$TEST_OUTPUT_LOG" "::warning::Tuist Xcode cache daemon did not become ready; continuing without compilation caching."
    assert_contains "$TEST_OUTPUT_LOG" "cache daemon test failure"
)

test_disappearing_cache_socket_disables_compilation_cache() (
    local temporary_directory
    temporary_directory="$(mktemp -d)"
    trap 'rm -rf "$temporary_directory"' EXIT
    configure_test_environment "$temporary_directory"
    touch "$TEST_CACHE_READY_FLAG"

    tuist_ci_setup >"$TEST_OUTPUT_LOG" 2>&1
    rm "$TEST_CACHE_READY_FLAG"
    tuist_xcodebuild "$temporary_directory/result.xcresult" test -scheme Example >>"$TEST_OUTPUT_LOG" 2>&1

    assert_contains "$TEST_COMMAND_LOG" "COMPILATION_CACHE_ENABLE_CACHING=NO"
    assert_contains "$TEST_COMMAND_LOG" "COMPILATION_CACHE_ENABLE_PLUGIN=NO"
    assert_not_contains "$TEST_COMMAND_LOG" "COMPILATION_CACHE_ENABLE_CACHING=YES"
    assert_contains "$TEST_OUTPUT_LOG" "::warning::Tuist Xcode cache service is unavailable"
    assert_contains "$TEST_OUTPUT_LOG" "cache daemon test failure"
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

run_test test_healthy_cache_uses_remote_compilation_cache
run_test test_cache_setup_failure_is_non_fatal_and_reports_diagnostics
run_test test_cache_readiness_failure_is_non_fatal_and_reports_diagnostics
run_test test_disappearing_cache_socket_disables_compilation_cache
run_test test_authentication_failure_remains_fatal
run_test test_mise_install_failure_remains_fatal
