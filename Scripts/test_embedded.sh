#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/openswiftui-embedded.XXXXXX")"
trap 'rm -rf -- "${test_dir}"' EXIT
host_flags=()
if [[ "$(uname -s)" == Darwin ]]; then
    host_flags=(-sdk "$(xcrun --show-sdk-path)")
fi
for swift_mode in embedded standard; do
    for platform in generic folotoy; do
        output="${test_dir}/${swift_mode}-${platform}"
        python3 "${repo_root}/Scripts/build_embedded.py" --target host --output "${output}" \
            --swift-mode "${swift_mode}" --platform "${platform}"
        flags=(-DOPENSWIFTUI_LVGL -wmo -Osize -parse-as-library "${host_flags[@]}" -I "${output}")
        if [[ "${swift_mode}" == embedded ]]; then
            flags+=(-enable-experimental-feature Embedded)
        fi
        suites=(RenderingTests LayoutTests AnimationTests)
        if [[ "${platform}" == folotoy ]]; then
            flags+=(-DOPENSWIFTUI_PLATFORM_FOLOTOY)
            suites+=(InputTests)
            "${SWIFTC:-swiftc}" "${flags[@]}" -typecheck "${repo_root}/Embedded/Tests/FoloToyAvailability.swift"
        else
            if "${SWIFTC:-swiftc}" "${flags[@]}" -typecheck "${repo_root}/Embedded/Tests/FoloToyAvailability.swift" >"${output}/unavailable.log" 2>&1; then
                echo 'ERROR: FoloToy input leaked into the generic LVGL profile' >&2
                exit 1
            fi
            for diagnostic in "cannot find type 'PhysicalButton'" "has no member 'onPhyicButton'" "has no member 'send'"; do
                grep -F "${diagnostic}" "${output}/unavailable.log" >/dev/null
            done
        fi
        for suite in "${suites[@]}"; do
            "${SWIFTC:-swiftc}" "${flags[@]}" "${repo_root}/Embedded/Tests/${suite}.swift" \
                "${output}/libOpenSwiftUI.a" -o "${output}/${suite}"
            "${output}/${suite}"
        done
        echo "LVGL profile boundary: PASS (${swift_mode}, ${platform})"
    done
done
