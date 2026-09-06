#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/openswiftui-embedded.XXXXXX")"
trap 'rm -rf -- "${test_dir}"' EXIT
python3 "${repo_root}/Scripts/build_embedded.py" --target host --output "${test_dir}"
host_flags=()
if [[ "$(uname -s)" == Darwin ]]; then
    host_flags=(-sdk "$(xcrun --show-sdk-path)")
fi
for suite in RenderingTests LayoutTests InputTests; do
    "${SWIFTC:-swiftc}" -enable-experimental-feature Embedded -wmo -Osize -parse-as-library \
        "${host_flags[@]}" -I "${test_dir}" "${repo_root}/Embedded/Tests/${suite}.swift" \
        "${test_dir}/libOpenSwiftUI.a" -o "${test_dir}/${suite}"
    "${test_dir}/${suite}"
done
