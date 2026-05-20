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

This example defaults to Apple's private AttributeGraph framework through `mise.toml`.

Or use the Compute module:

```shell
export OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE=1
export OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE_USE_BINARY=1
```

## Generate Project

```shell
mise exec -- tuist install
mise exec -- tuist generate --no-open
```

By default, the generated Debug Example targets include LookInsideServer. You can switch the debug inspector server before running `tuist install` and `tuist generate`:

```shell
# Default
export OPENSWIFTUI_EXAMPLE_LOOKINSIDE_SERVER=1
export OPENSWIFTUI_EXAMPLE_LOOKIN_SERVER=0

# Use Lookin instead
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
