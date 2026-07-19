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

The Compute environment is defined in the repository's root `mise.compute.toml`. It disables the private AttributeGraph framework and uses `OpenSwiftUIProject/Compute` from source with `0.3.0-bugfix.1` tag.

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
