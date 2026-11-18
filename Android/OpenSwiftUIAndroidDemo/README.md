# Android Kinetic Studio Demo

Kinetic Studio shares its ContentView with the macOS and iPhone recording hosts:
three motion studies, palettes, tempo controls, pause/resume, and echo layers.
It uses OpenSwiftUI's shared DisplayList renderer with UIKit-cross-platform.
The original Breathing Colors example remains available with `--demo breathing`.
Use `--demo materials` to change material thickness with a Stepper and coverage
with a Slider. On Android, material uses an adaptive translucent tint, not backdrop blur.
Use `--demo gradients` for the shared gradient showcase or `--demo gradient-examples`
for the same `GradientExample` used by the Apple previews. Android rasterizes
gradient fills on rectangles, rounded rectangles, and ellipses through the shared
DisplayList updater; arbitrary paths and gradient strokes are not covered.

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
Scripts/android-demo.sh --no-build --serial emulator-5554 --demo breathing
Scripts/android-demo.sh --no-build --serial emulator-5554 --demo materials
Scripts/android-demo.sh --no-build --serial emulator-5554 --demo gradients
Scripts/android-demo.sh --no-build --serial emulator-5554 --demo gradient-examples
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

The runner creates a version-specific SDK discovery directory under
`.build/android-demo/sdk-store/` and selects `aarch64-unknown-linux-android28`.
This avoids SwiftPM 6.3 choosing another architecture from the multi-target
Android bundle. It does not change the globally installed SDKs.

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

For unpublished UIKit changes only, set `OPENSWIFTUI_UIKIT_CROSS_PLATFORM_PATH` to an
explicit checkout. SwiftPM and Gradle both use that override; other dependencies
remain remote. Unset it to return to the fork's `android/dev` branch. The old
`OPENSWIFTUI_ANDROID_UIKIT_PATH` still works as a fallback.

## Backend and App Targets

`OPENSWIFTUI_UIKIT_CROSS_PLATFORM=1` enables the `OpenSwiftUIUIKitCrossPlatform`
host product and defines `UIKIT_CROSS_PLATFORM` for eligible targets. The host
provides a `UIKitCrossPlatformHostingController` and renders the shared
DisplayList through UIKit-cross-platform. The embedding app owns its window and
SDL event loop.

The APK runner also sets `OPENSWIFTUI_ANDROID_APP=1` for the Android entry point,
JNI and linker settings. The legacy `OPENSWIFTUI_ANDROID_UIKIT=1` enables both
options when neither new option is set.

`OpenSwiftUILinuxDemo` still uses stdout on Linux. Running a Linux GUI with the
shared host requires Linux support in the UIKit and SDL packages, and a desktop
app entry point; switching on the backend alone does not launch a GUI.

## Android Studio

First run `Scripts/android-demo.sh --prepare` from the checkout root. Then open
this directory in Android Studio and select the included Gradle wrapper.
Ensure the IDE has the SDK/JDK environment above.

`app:preBuild` calls `Scripts/Android/build-native.sh` before packaging Kotlin and
native libraries. The CLI script remains the quickest entry point and does not
require Android Studio to be open.

## Validation

The 2026-10-21 Kinetic Studio APK was built with Swift/Android SDK 6.3.2 and run
on an arm64 API 36 emulator with host GPU rendering. Flow, Cascade, Lattice,
all palettes, tempo limits (0.5x and 2.0x), pause/resume, echo layers, and new
compositions were checked through adb interactions. Paused screenshots captured
about 15 seconds apart were pixel-identical; resumed frames changed again.
The portrait layout showed no text clipping and the crash buffer was empty.
This is a functional smoke check, not a frame-rate benchmark or physical-device
validation. Use `--demo kinetic` explicitly, or omit it for the default scene.

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
