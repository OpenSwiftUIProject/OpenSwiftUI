# README

## Pre-Requirements

Run the CI setup script from the `OpenSwiftUI` repository root. It checks out the local package dependencies used by the generated Example project.

```shell
# From OpenSwiftUI/Example
../Scripts/CI/darwin_setup_build.sh
```

`OpenCoreGraphics` and `OpenObservation` are resolved through the `OpenSwiftUI` package dependency.

## Configure AttributeGraph Backend

Since OpenAttributeGraph is not yet completed, you need to configure an AG backend before building.

This example defaults to Apple's private AttributeGraph framework through the repository's root `mise.toml`.

To use Compute instead, run setup with the Compute mise environment:

```shell
./setup.sh --compute
```

The Compute environment is defined in the repository's root `mise.compute.toml`. It disables the private AttributeGraph framework and uses the Compute binary configured there.

## Generate Project

The recommended setup path is the local setup script:

```shell
./setup.sh
```

The script trusts and installs the tools declared by the repository's root `mise.toml`, then runs Tuist through `mise exec` so the pinned Tuist version is used.

To generate the project with Compute:

```shell
./setup.sh --compute
```

This uses `mise --env compute`, which loads the repository's root `mise.compute.toml` for `mise install`, `tuist install`, and `tuist generate`.

To run the steps manually:

```shell
mise trust ../mise.toml
mise install
mise exec -- tuist install
mise exec -- tuist generate --no-open
```

Or with Compute:

```shell
mise trust ../mise.compute.toml
mise --env compute install
mise --env compute exec -- tuist install
mise --env compute exec -- tuist generate --no-open
```

By default, the generated Debug Example targets do not include any debug UI inspector server. You can switch the debug inspector server before running `tuist install` and `tuist generate`:

```shell
# Use LookInside
export OPENSWIFTUI_EXAMPLE_LOOKINSIDE_SERVER=1
export OPENSWIFTUI_EXAMPLE_LOOKIN_SERVER=0

# Use Lookin
export OPENSWIFTUI_EXAMPLE_LOOKINSIDE_SERVER=0
export OPENSWIFTUI_EXAMPLE_LOOKIN_SERVER=1

# Disable both
export OPENSWIFTUI_EXAMPLE_LOOKINSIDE_SERVER=0
export OPENSWIFTUI_EXAMPLE_LOOKIN_SERVER=0
```

Do not enable both server variables at the same time.

## Example

A OpenSwiftUI/SwiftUI `App` lifecycle example.

- Choose `SwiftUIDebug` configuration to run with SwiftUI
- Choose `OpenSwiftUIDebug` configuration to run with OpenSwiftUI

## HostingExample

A UIKit/AppKit hosting example that manually sets up the application lifecycle and window using `UIHostingView` / `NSHostingView`.

- Choose `SwiftUIDebug` configuration to run with SwiftUI
- Choose `OpenSwiftUIDebug` configuration to run with OpenSwiftUI

### visionOS Build

The public visionOS SDKs mark `UIScreen` unavailable. OpenSwiftUI builds for
visionOS devices and the visionOS Simulator with a UIKit header overlay from
`DarwinPrivateFrameworks`. Run from `OpenSwiftUI/Example`, with the same Xcode
for all steps:

```shell
../../DarwinPrivateFrameworks/Scripts/XR/install_xr_uikit_overlay.sh
./setup.sh --compute

xcodebuild build \
    -workspace Example.xcworkspace \
    -scheme OSUI_HostingExample \
    -configuration OpenSwiftUIDebug \
    -destination 'generic/platform=visionOS Simulator' \
    CODE_SIGNING_ALLOWED=NO
```

For a visionOS device, use `-destination 'generic/platform=visionOS'`.

The `--compute` setup uses the Compute backend, whose binary includes visionOS
slices. Run the overlay script again after you switch Xcode. To use another
overlay file, set `OPENSWIFTUI_XR_OVERLAY`.

Gestures is not linked on visionOS.

#### Simulator Runtime

Xcode shows visionOS Simulator destinations only when an installed simulator
runtime matches the visionOS SDK. Each SDK has a default runtime build. For
example, Xcode 26.6 contains the `xros26.5` SDK, and its default runtime is
visionOS 26.5 (`23O469`).

OpenSwiftUI prefer to use the visionOS 2.5 runtime (`22O473`). With only that
runtime installed, Xcode reports that visionOS 26.5 is not installed. Then it
hides all visionOS Simulator destinations, including `generic/platform=visionOS Simulator`.
Storyboard and asset catalog compilation also fails.

To use the installed runtime, map the SDK to it:

```shell
xcrun simctl runtime match set xros26.5 22O473
```

This setting applies to the current user and stays until you change it. Run it
one time on each machine. If you install a different Xcode, run it again with
the SDK version of that Xcode.

To see the current mapping, find the `xros` entries in this output. The
`Chosen Runtime` line shows the runtime that Xcode uses:

```shell
xcrun simctl runtime match list
```

To restore the default runtime of the SDK:

```shell
xcrun simctl runtime match set xros26.5 --default
```

If you install the default runtime of the SDK (for example, with
`xcodebuild -downloadPlatform visionOS`), the mapping is not necessary. The
simulator then runs that visionOS version instead of visionOS 2.5.

## Tests

See [Tests](Tests/README.md) for UI and interaction test targets, shared tags,
snapshot recording, and reference images.
