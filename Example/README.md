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

## UX Tests

`OpenSwiftUIUXTests` runs Swift Testing suites in `TestingHost` on iPhone, iPad,
and Mac. It uses the
[OpenSwiftUIProject Hammer fork](https://github.com/OpenSwiftUIProject/Hammer)
to send touch events on iOS and mouse events on macOS.

1. Run `SUI_UXTests` to create or update reference images with SwiftUI.
2. Run `OSUI_UXTests` on the same destination to verify OpenSwiftUI against those images.

Use `withUXTestHost(of:)` to host a view and clean up after the test. Call the
helper, `tap()`, and `waitUntil(_:timeout:)` with `try await`. Keep gesture tests
on the main actor in serialized suites because they share application windows
and Hammer settings.

Call `try await host.assertSnapshot(named:)` to compare the current hosted view
with a reference image. It captures the same view used for interactions, so it
preserves view state and supports more interactions after each snapshot:

```swift
try await withUXTestHost(of: content) { host in
    try await host.assertSnapshot(named: "before")
    try await host.tap()
    try await host.waitUntil(count == 1)
    try await host.assertSnapshot(named: "after")
}
```

Use `.snapshots(record: .never, diffTool: diffTool)` on snapshot test suites,
as in the UI tests. The helper uses the same recording defaults: `SUI_UXTests`
records reference images and reports recording issues; `OSUI_UXTests` compares
against those references. Pass `record:` to override this behavior. Reference
images use `SNAPSHOT_REFERENCE_DIR` or `Example/ReferenceImages`, followed by the
platform, OS version, and test file ID. Snapshot names include the hosted view's
size. Give each case a distinct name in parameterized tests.

On macOS, tests use an offscreen window to preserve application focus. Set
`HAMMER_SHOW_TEST_WINDOW=1` in the test scheme's environment to show the window
while debugging.

CI runs `OSUI_UXTests` with persistent references. Request `update` or set
`update_reference=true` to run `SUI_UXTests` first, including for the initial
baseline. UI and UX tests share platform and configuration choices, test
filters, reference storage, and recording locks. The default configurations use
the SwiftUI renderer with AttributeGraph and the OpenSwiftUI renderer with
Compute. CI accepts recording issues only when no other failures are present;
a recording failure stops verification.
See [Optional CI workflows](../Docs/CI/README.md#ux-tests) for dispatch and PR
comment commands.
