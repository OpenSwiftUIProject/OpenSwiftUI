## SwiftCorelibs

System API compatibility headers for non-Darwin platforms, sourced from the [Swift project](https://github.com/swiftlang/swift-corelibs-foundation).

Provides the following header sets:

| Directory | Description |
|-----------|-------------|
| **CoreFoundation** | CoreFoundation types (CFBase, CFArray, CFDictionary, CFString, CFRuntime, etc.) from [swift-corelibs-foundation](https://github.com/swiftlang/swift-corelibs-foundation) |
| **dispatch** | Grand Central Dispatch (libdispatch) headers from [swift-corelibs-libdispatch](https://github.com/swiftlang/swift-corelibs-libdispatch) |
| **os** | OS abstraction headers (os/object.h) from [swift-corelibs-libdispatch](https://github.com/swiftlang/swift-corelibs-libdispatch) |

Only used on non-Darwin platforms (Linux, WASI, Windows) via `-isystem` include path.

### Alternative: Use Swift toolchain headers

Instead of the bundled headers, you can point to your Swift toolchain's headers by setting the `OPENSWIFTUI_LIB_SWIFT_PATH` environment variable:

```shell
# Using swiftly
export OPENSWIFTUI_LIB_SWIFT_PATH="$(swiftly use --print-location)/usr/lib/swift"

# Using a Swift SDK
export OPENSWIFTUI_LIB_SWIFT_PATH=~/.swiftpm/swift-sdks/<sdk>/usr/lib/swift
```

When `OPENSWIFTUI_LIB_SWIFT_PATH` is set, it overrides the bundled SwiftCorelibs headers.
