#!/bin/bash

##===----------------------------------------------------------------------===##
##
## This source file is part of the OpenSwiftUI open source project
##
## Copyright (c) 2026 the OpenSwiftUI project authors
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
CONFIG_PATH="${VDC_CONFIG_PATH:-.vdc.json}"
BUILD_ROOT="$REPO_ROOT/.docs/build/additional-symbol-graphs"
RESOLVED_VERSIONS_PATH="${VDC_RESOLVED_VERSIONS_PATH:-$BUILD_ROOT/resolved-versions.json}"
TEMPORARY_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/openswiftui-docc-graphs.XXXXXX")"

cleanup() {
    rm -rf "$TEMPORARY_ROOT"
}

trap cleanup EXIT INT TERM

command -v swift >/dev/null 2>&1 || {
    echo "error: swift is required" >&2
    exit 1
}
command -v xcrun >/dev/null 2>&1 || {
    echo "error: xcrun is required" >&2
    exit 1
}
command -v python3 >/dev/null 2>&1 || {
    echo "error: python3 is required" >&2
    exit 1
}
command -v git >/dev/null 2>&1 || {
    echo "error: git is required" >&2
    exit 1
}

: "${OPENSWIFTUI_WERROR:=0}"
: "${OPENSWIFTUI_COMPATIBILITY_TEST:=0}"
: "${OPENSWIFTUI_SWIFT_LOG:=0}"
: "${OPENSWIFTUI_SWIFT_CRYPTO:=0}"
: "${OPENSWIFTUI_TARGET_RELEASE:=2024}"
: "${OPENSWIFTUI_USE_LOCAL_DEPS:=1}"
: "${OPENSWIFTUI_VERSIONED_DOCC_PLUGIN:=1}"
: "${OPENSWIFTUI_LINK_TESTING:=0}"
: "${OPENSWIFTUI_IGNORE_AVAILABILITY:=0}"
: "${OPENSWIFTUI_LIBRARY_EVOLUTION:=0}"
export OPENSWIFTUI_WERROR
export OPENSWIFTUI_COMPATIBILITY_TEST
export OPENSWIFTUI_SWIFT_LOG
export OPENSWIFTUI_SWIFT_CRYPTO
export OPENSWIFTUI_TARGET_RELEASE
export OPENSWIFTUI_USE_LOCAL_DEPS
export OPENSWIFTUI_VERSIONED_DOCC_PLUGIN
export OPENSWIFTUI_LINK_TESTING
export OPENSWIFTUI_IGNORE_AVAILABILITY
export OPENSWIFTUI_LIBRARY_EVOLUTION
export VDC_GENERATE_DOCS=1

MACOS_SDK="$(xcrun --sdk macosx --show-sdk-path)"

resolve_documentation_versions() {
    local output_argument="${RESOLVED_VERSIONS_PATH#"$REPO_ROOT"/}"

    if [[ -n "${VDC_RESOLVED_VERSIONS_PATH:-}" ]]; then
        [[ -f "$RESOLVED_VERSIONS_PATH" ]] || {
            echo "error: missing resolved versions file: $RESOLVED_VERSIONS_PATH" >&2
            exit 1
        }
        return
    fi
    mkdir -p "$BUILD_ROOT"
    swift package \
        --disable-sandbox \
        --allow-writing-to-package-directory \
        --allow-network-connections all \
        versioned-documentation \
        resolve-versions \
        --config "$CONFIG_PATH" \
        --output "$output_argument"
}

resolved_dependency_revision() {
    local resolved_path="$1"
    local package_identity="$2"

    python3 - "$resolved_path" "$package_identity" <<'PY'
import json
import pathlib
import sys

resolved_path = pathlib.Path(sys.argv[1])
identity = sys.argv[2].casefold()
with resolved_path.open(encoding="utf-8") as file:
    pins = json.load(file).get("pins", [])
for pin in pins:
    if pin.get("identity", "").casefold() != identity:
        continue
    revision = pin.get("state", {}).get("revision")
    if revision:
        print(revision)
        raise SystemExit(0)
raise SystemExit(f"error: {resolved_path} has no revision for {identity}")
PY
}

prepare_dependency_checkout() {
    local canonical_path="$1"
    local expected_revision="$2"
    local documentation_version="$3"
    local module_name="$4"
    local checkout_path

    if [[ ! -e "$canonical_path/.git" ]]; then
        echo "error: missing dependency repository: $canonical_path" >&2
        exit 1
    fi
    if ! git -C "$canonical_path" cat-file -e "${expected_revision}^{commit}" 2>/dev/null; then
        echo "Fetching $module_name revision $expected_revision..."
        git -C "$canonical_path" fetch origin "$expected_revision"
    fi
    if [[ "$(git -C "$canonical_path" rev-parse HEAD)" == "$expected_revision" ]]; then
        PREPARED_DEPENDENCY_PATH="$canonical_path"
        return
    fi

    checkout_path="$TEMPORARY_ROOT/$documentation_version/$module_name"
    mkdir -p "$(dirname "$checkout_path")"
    git clone --quiet --shared --no-checkout "$canonical_path" "$checkout_path"
    git -C "$checkout_path" checkout --quiet --detach "$expected_revision"
    if [[ -d "$canonical_path/Checkouts/swift" ]]; then
        mkdir -p "$checkout_path/Checkouts/swift"
        for swift_checkout_component in include stdlib; do
            if [[ ! -e "$checkout_path/Checkouts/swift/$swift_checkout_component" ]]; then
                ln -s \
                    "$canonical_path/Checkouts/swift/$swift_checkout_component" \
                    "$checkout_path/Checkouts/swift/$swift_checkout_component"
            fi
        done
    fi
    PREPARED_DEPENDENCY_PATH="$checkout_path"
}

extract_module() {
    local documentation_version="$1"
    local resolved_path="$2"
    local module_name="$3"
    local canonical_path="$4"
    local target_name="$5"
    local package_identity="$6"
    local output_path="$REPO_ROOT/.docs/external-symbol-graphs/$documentation_version/${module_name}-symbol-graphs"
    local scratch_path="$BUILD_ROOT/$documentation_version/$module_name"
    local revision_path="$output_path/.source-revision"
    local expected_revision
    local package_path

    expected_revision="$(resolved_dependency_revision "$resolved_path" "$package_identity")"

    case "$output_path" in
        "$REPO_ROOT"/.docs/external-symbol-graphs/*) ;;
        *)
            echo "error: refusing to clear unexpected path: $output_path" >&2
            exit 1
            ;;
    esac

    if [[ "${VDC_REBUILD_ADDITIONAL_SYMBOL_GRAPHS:-0}" != "1" ]] &&
        [[ -f "$revision_path" ]] &&
        [[ "$(<"$revision_path")" == "$expected_revision" ]] &&
        python3 - "$output_path" "$module_name" <<'PY'
import json
import pathlib
import sys

graph_path = pathlib.Path(sys.argv[1])
expected_module = sys.argv[2]
paths = sorted(graph_path.glob("*.symbols.json"))
if not paths:
    raise SystemExit(1)
for path in paths:
    with path.open(encoding="utf-8") as file:
        if json.load(file).get("module", {}).get("name") != expected_module:
            raise SystemExit(1)
PY
    then
        echo "Reusing $documentation_version $module_name symbol graphs at ${expected_revision:0:8}."
        return
    fi

    prepare_dependency_checkout \
        "$canonical_path" \
        "$expected_revision" \
        "$documentation_version" \
        "$module_name"
    package_path="$PREPARED_DEPENDENCY_PATH"

    mkdir -p "$output_path"
    find "$output_path" -mindepth 1 -delete
    mkdir -p "$scratch_path"
    find "$scratch_path" -mindepth 1 -delete

    echo "Extracting $documentation_version $module_name symbol graphs at ${expected_revision:0:8}..."
    OPENATTRIBUTEGRAPH_OPENATTRIBUTESHIMS_ATTRIBUTEGRAPH=0 \
    OPENSWIFTUI_OPENATTRIBUTESHIMS_ATTRIBUTEGRAPH=0 \
    OPENSWIFTUI_USE_LOCAL_DEPS=0 \
    swift build \
        --disable-sandbox \
        --disable-index-store \
        --package-path "$package_path" \
        --scratch-path "$scratch_path" \
        --target "$target_name" \
        --triple arm64-apple-macosx \
        --sdk "$MACOS_SDK" \
        -Xswiftc -emit-symbol-graph \
        -Xswiftc -emit-symbol-graph-dir \
        -Xswiftc "$output_path" \
        -Xswiftc -symbol-graph-minimum-access-level \
        -Xswiftc public \
        -Xswiftc -Xfrontend \
        -Xswiftc -skip-protocol-implementations

    python3 - "$output_path" "$module_name" <<'PY'
import json
import pathlib
import sys

graph_path = pathlib.Path(sys.argv[1])
expected_module = sys.argv[2]
retained = []

for path in sorted(graph_path.glob("*.symbols.json")):
    with path.open(encoding="utf-8") as file:
        module_name = json.load(file).get("module", {}).get("name")
    if module_name == expected_module:
        retained.append(path.name)
    else:
        path.unlink()

if not retained:
    raise SystemExit(
        f"error: no {expected_module} symbol graphs found in {graph_path}"
    )

print(f"Retained {len(retained)} {expected_module} symbol graph file(s).")
PY
    printf '%s\n' "$expected_revision" > "$revision_path"
}

cd "$REPO_ROOT"
resolve_documentation_versions

resolved_version_rows="$TEMPORARY_ROOT/resolved-versions.tsv"
python3 - "$RESOLVED_VERSIONS_PATH" "$resolved_version_rows" <<'PY'
import json
import pathlib
import sys

source_path = pathlib.Path(sys.argv[1])
output_path = pathlib.Path(sys.argv[2])
with source_path.open(encoding="utf-8") as file:
    versions = json.load(file)
if not versions:
    raise SystemExit("error: VersionedDocC resolved no documentation versions")
output_path.write_text(
    "".join(f'{version["name"]}\t{version["commit"]}\n' for version in versions),
    encoding="utf-8",
)
PY

while IFS=$'\t' read -r documentation_version documentation_commit; do
    resolved_path="$TEMPORARY_ROOT/$documentation_version/Package.resolved"
    mkdir -p "$(dirname "$resolved_path")"
    git show "${documentation_commit}:Package.resolved" > "$resolved_path"

    extract_module \
        "$documentation_version" \
        "$resolved_path" \
        "OpenAttributeGraph" \
        "$REPO_ROOT/../OpenAttributeGraph" \
        "OpenAttributeGraph" \
        "openattributegraph"

    extract_module \
        "$documentation_version" \
        "$resolved_path" \
        "OpenObservation" \
        "$REPO_ROOT/../OpenObservation" \
        "OpenObservation" \
        "openobservation"
done < "$resolved_version_rows"
