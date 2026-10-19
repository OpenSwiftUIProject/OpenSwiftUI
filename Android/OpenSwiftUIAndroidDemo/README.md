# Android Controls Demo

This is the Breathing Colors example with text, a counter Button, and a Toggle.
It uses OpenSwiftUI's shared DisplayList renderer with UIKit-cross-platform.

## Quick Run

From the OpenSwiftUI checkout on `android/dev`:

```bash
# Pick an existing arm64 AVD. The script starts it if it is not already running.
"${ANDROID_HOME:-$HOME/Library/Android/sdk}/emulator/emulator" -list-avds
Scripts/android-demo.sh --avd YOUR_ARM64_AVD

# Or use an already connected device (select explicitly when there are several).
Scripts/android-demo.sh --serial emulator-5554
```

The script resolves remote dependencies, builds an arm64 debug APK, installs it,
and launches `org.openswiftui.androiddemo/.MainActivity`. It does not install
toolchains, download emulator images, or create an AVD automatically.

```bash
Scripts/android-demo.sh --build-only
Scripts/android-demo.sh --no-build --serial emulator-5554
Scripts/android-demo.sh --no-build --serial emulator-5554 --demo text
Scripts/android-demo.sh --no-build --serial emulator-5554 --demo static --print-tree
adb -s emulator-5554 shell run-as org.openswiftui.androiddemo cat files/display-list.log
adb -s emulator-5554 emu kill
```

Output: `app/build/outputs/apk/debug/app-arm64-v8a-debug.apk` relative to this
directory. First resolution/build downloads sources, submodules, and Gradle
dependencies; subsequent runs reuse `.build/android-demo/` in the checkout.

## Toolchains

- Official Swift **6.3.2** and the matching Swift SDK for Android **6.3.2**.
- Android NDK **r27d** (`27.3.13750724`), configured with the Swift SDK.
- Android SDK Platform **35**, platform-tools, and a JDK **17 or newer**.
- An **arm64-v8a** device or emulator with **API 28+**. API 36 is the usual
  local validation target. An x86_64-only emulator cannot run this APK.

The [Swift Android setup guide](https://www.swift.org/documentation/articles/swift-sdk-for-android-getting-started.html)
explains toolchain/SDK matching. Use the pinned versions above for this demo,
not an unrelated latest SDK with the older compiler.

Default macOS locations are discovered automatically. For custom installations:

```bash
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_NDK_HOME="$HOME/android-ndk/android-ndk-r27d"
export SWIFT_ANDROID_SDK_PATH="$HOME/Library/org.swift.swiftpm/swift-sdks/swift-6.3.2-RELEASE_android.artifactbundle/swift-android"
# Optional: SWIFT_EXEC=/path/to/the/matching/toolchain/usr/bin/swift
# Optional: JAVA_HOME=/path/to/jdk
# On macOS, select an Xcode SDK compatible with the Swift 6.3.2 host compiler.
export DEVELOPER_DIR=/Applications/Xcode-26.3.0.app/Contents/Developer
```

On Linux the defaults use `$HOME/Android/Sdk` and
`$HOME/.local/share/swiftpm/swift-sdks`. The current smoke workflow targets arm64
Android; emulator availability depends on the host architecture.

## Dependencies

No sibling source checkouts are required. The runner explicitly disables local
dependency mode and builds Compute from source:

- `OpenSwiftUIProject/Compute`, branch `android/dev`.
- `OpenSwiftUIProject/UIKit-cross-platform`, branch `android/dev`.
- OpenAttributeGraph, OpenCoreGraphics, OpenRenderBox, and OpenObservation from
  their normal remote dependencies.

`Package.resolved` in this directory pins the Android graph independently of the
root Darwin lockfile. Gradle uses UIKit's **same SwiftPM checkout** for its Kotlin
sources, rather than a separately cloned revision. This project includes the
official Gradle 8.13 wrapper and verifies the distribution checksum. Public
SSH submodule URLs are rewritten to HTTPS only for the runner's process tree;
no global Git configuration or GitHub SSH key is needed.

For unpublished UIKit changes only, set `OPENSWIFTUI_ANDROID_UIKIT_PATH` to an
explicit checkout. SwiftPM and Gradle both use that override; other dependencies
remain remote. Unset it to return to the fork's `android/dev` branch.

## Android Studio

First run `Scripts/android-demo.sh --prepare` from the checkout root. Then open
this directory in Android Studio and select the included Gradle wrapper.
Ensure the IDE has the SDK/JDK environment above.

`app:preBuild` calls `Scripts/Android/build-native.sh` before packaging Kotlin and
native libraries. The CLI script remains the quickest entry point and does not
require Android Studio to be open.

## Validation

The 2026-10-19 smoke build used remote Compute `065635a`, OAG `46f2e1b`,
OCG `19b887a`, and OpenRenderBox `f94140b`, with only the unpublished UIKit
manifest change supplied through the explicit local override.

After publishing the SDL manifest fix, remote-only `--prepare` succeeded with
Compute `065635a` and UIKit `d429138`, both on `android/dev`. The Android lockfile
now pins both remote branches. Other dependency revisions were unchanged.
This branch-name update was checked by dependency resolution and shell syntax
checks; it did not trigger another APK build.

The APK launched on arm64 API 36. Isolated taps and a logging-disabled
cold-start recheck showed Count `0` to `1` and the Toggle switching to red/off;
successive frames showed TimelineView scale/opacity changes. The crash buffer
was empty. An initial combined interaction produced an inconsistent count,
not reproduced in the rechecks; this is not an input stress-test result.
