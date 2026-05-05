# XCFramework Packaging Notes

This document records the investigation into distributing OpenSwiftUI as a single
`OpenSwiftUI.xcframework`, the problems found with that shape, and the practical
fallback design.

## Context

OpenSwiftUI currently has more than one Swift module in its public build graph.
The important modules for binary distribution are:

- `OpenSwiftUI`
- `OpenSwiftUICore`
- `OpenObservation`
- `OpenAttributeGraphShims`
- `OpenCoreGraphicsShims`
- `OpenQuartzCoreShims`
- `OpenRenderBoxShims`

The attempted single-artifact design produced one `OpenSwiftUI.xcframework`
containing one `OpenSwiftUI.framework`. The framework Mach-O linked the object
code from the dependency modules, so the runtime code was present in one binary.
However, the Swift module graph was still multi-module.

## Root Problem

Swift binary distribution has two separate concerns:

- The Mach-O binary must contain or link the implementation code.
- The Swift compiler must be able to resolve every module referenced by public
  `.swiftinterface` files.

The single-framework experiment solved the first concern, but not the second.
The generated `OpenSwiftUI.swiftinterface` still contains public module imports:

```swift
public import OpenCoreGraphicsShims
public import OpenObservation
@_exported public import OpenSwiftUICore
```

`OpenSwiftUICore.swiftinterface` also imports dependency modules:

```swift
public import OpenCoreGraphicsShims
public import OpenObservation
public import OpenQuartzCoreShims
```

Therefore, a client compiling `import OpenSwiftUI` still needs the compiler to
find `OpenSwiftUICore`, `OpenObservation`, and the shim modules as Swift modules,
even when their object code is already linked into `OpenSwiftUI.framework`.

## Observed Tool Behavior

### SwiftPM CLI

For a binary target that points at an xcframework, SwiftPM CLI passes a Swift
include path to the selected xcframework slice root, for example:

```text
-I Frameworks/OpenSwiftUI.xcframework/macos-arm64
```

If the dependency `.swiftmodule` directories are placed or symlinked at that
slice root, SwiftPM CLI can resolve them without consumer-side `unsafeFlags`.

### Xcode

Xcode's package build path is different. `ProcessXCFramework` selects the
matching framework from the xcframework and copies only that framework into the
build products directory:

```text
Build/Products/Debug/OpenSwiftUI.framework
```

The extra files at the xcframework slice root are not copied. Xcode then invokes
Swift with paths similar to:

```text
-I Build/Products/Debug
-F Build/Products/Debug
```

It does not add:

```text
-I Build/Products/Debug/OpenSwiftUI.framework/Modules
```

As a result, dependency modules hidden inside `OpenSwiftUI.framework/Modules`
are not discoverable by Xcode without extra settings.

## Experiments

### Consumer Search Paths

Adding an explicit include path to the consumer works:

```text
-I Frameworks/OpenSwiftUI.xcframework/macos-arm64/OpenSwiftUI.framework/Modules
```

The equivalent Xcode build setting is `SWIFT_INCLUDE_PATHS`.

This is not a good user-facing integration because every consumer needs a
platform-specific workaround.

### Slice-Root Module Symlinks

Adding symlinks at the selected slice root works for SwiftPM CLI:

```text
OpenSwiftUI.xcframework/macos-arm64/OpenSwiftUICore.swiftmodule
  -> OpenSwiftUI.framework/Modules/OpenSwiftUICore.swiftmodule
```

This keeps artifact size small and avoids consumer-side `unsafeFlags` for
`swift build`.

It does not fix Xcode because `ProcessXCFramework` does not copy those slice-root
symlinks into `Build/Products`.

### Restoring Binary `.swiftmodule` Files

`xcodebuild -create-xcframework` may drop binary `.swiftmodule` files and keep
textual `.swiftinterface` files. Restoring the binary `.swiftmodule` files into
`OpenSwiftUI.framework/Modules` did not fix Xcode. The binary module still
records dependencies on other Swift modules, and Xcode still needs a search path
that can find them.

### Removing Imports From `OpenSwiftUI.swiftinterface`

Removing only:

```swift
public import OpenCoreGraphicsShims
```

from `OpenSwiftUI.swiftinterface` can compile in the simple SwiftPM CLI probe,
because `OpenSwiftUI.swiftinterface` does not directly reference that module.
This is only a cleanup opportunity, not a complete fix, because
`OpenSwiftUICore.swiftinterface` still imports `OpenCoreGraphicsShims`.

Removing either of these imports is not viable:

```swift
public import OpenObservation
@_exported public import OpenSwiftUICore
```

`OpenSwiftUI.swiftinterface` directly references those modules in public API, for
example `OpenObservation.Observable`, `OpenSwiftUICore.View`,
`OpenSwiftUICore.Binding`, and `OpenSwiftUICore.ViewBuilder`.

## Possible Workarounds

### Wrapper Package Search Paths

A wrapper package could hide the include-path workaround by adding unsafe Swift
flags internally. This keeps the user-facing dependency small, but it is still a
path-sensitive workaround and relies on `unsafeFlags`.

This should not be the preferred release shape.

### Module-Only Sidecar Artifacts

It may be possible to ship module-only or mostly-empty sidecar frameworks while
keeping most object code in `OpenSwiftUI.framework`. This is non-standard and
hard to reason about because Xcode and SwiftPM still need each module to appear
as a normal dependency during compilation.

This is more fragile than shipping normal static frameworks for each module.

### True Single Swift Module

The structural fix for one `OpenSwiftUI.xcframework` is to make the public Swift
module graph truly single-module. That means the distributed
`OpenSwiftUI.swiftinterface` must not reference `OpenSwiftUICore`,
`OpenObservation`, or shim modules as separate modules.

Possible ways to get there:

- Move or compile the public distribution sources into one `OpenSwiftUI` module.
- Add a distribution-only target that compiles the relevant sources under the
  `OpenSwiftUI` module name.
- Avoid exposing dependency module names in public API and generated
  `.swiftinterface` files.

This is the cleanest single-artifact design, but it is a larger architectural
change because the current source and test structure intentionally uses multiple
modules.

## Recommended Fallback

Use multiple xcframeworks, one per Swift module, and expose them through one
Swift package product.

Prefer static frameworks for these xcframeworks:

- They preserve the Swift module graph for the compiler.
- They avoid embedding many dynamic frameworks into client apps.
- They let the final app link the implementation code into the app binary.
- They keep the user-facing API as one package product.

The package shape should be similar to:

```swift
let package = Package(
    name: "OpenSwiftUI",
    products: [
        .library(
            name: "OpenSwiftUI",
            targets: [
                "OpenSwiftUI",
                "OpenSwiftUICore",
                "OpenObservation",
                "OpenAttributeGraphShims",
                "OpenCoreGraphicsShims",
                "OpenQuartzCoreShims",
                "OpenRenderBoxShims",
            ]
        ),
    ],
    targets: [
        .binaryTarget(name: "OpenSwiftUI", url: "...", checksum: "..."),
        .binaryTarget(name: "OpenSwiftUICore", url: "...", checksum: "..."),
        .binaryTarget(name: "OpenObservation", url: "...", checksum: "..."),
        .binaryTarget(name: "OpenAttributeGraphShims", url: "...", checksum: "..."),
        .binaryTarget(name: "OpenCoreGraphicsShims", url: "...", checksum: "..."),
        .binaryTarget(name: "OpenQuartzCoreShims", url: "...", checksum: "..."),
        .binaryTarget(name: "OpenRenderBoxShims", url: "...", checksum: "..."),
    ]
)
```

Consumers still write:

```swift
import OpenSwiftUI
```

and depend on the single `OpenSwiftUI` package product. The distribution uses
multiple binary targets internally only so that Xcode and SwiftPM can resolve the
Swift module graph normally.

Dynamic frameworks should be avoided unless there is a runtime reason to share
or load the frameworks dynamically. They make embedding, signing, launch-time
loading, and artifact management more complicated.
