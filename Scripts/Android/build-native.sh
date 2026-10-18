#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
check_native_environment

swift_cmd build --package-path "$ANDROID_PROJECT" --scratch-path "$SWIFT_SCRATCH" \
    --cache-path "$ANDROID_BUILD/cache" "${swift_sdk_args[@]}" \
    --static-swift-stdlib --product OpenSwiftUIAndroidApp

out="$ANDROID_PROJECT/app/build/generated/swift-jniLibs/arm64-v8a"
mkdir -p "$(dirname "$out")"
staging="$(mktemp -d "$(dirname "$out")/.arm64-v8a.XXXXXX")"
trap 'rm -rf "$staging"' EXIT
cp "$SWIFT_ANDROID_SDK_PATH/swift-resources/usr/lib/swift-aarch64/android/"*.so "$staging/"
cp "$ANDROID_LIBCXX" "$staging/"
cp "$SWIFT_SCRATCH/$SWIFT_ANDROID_TRIPLE/debug/libOpenSwiftUIAndroidApp.so" "$staging/"
rm -rf "$out"
mv "$staging" "$out"
