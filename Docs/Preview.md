# Preview Support

## Current Status

OpenSwiftUI supports Xcode Preview rendering through the shim introduced in [PR #829](https://github.com/OpenSwiftUIProject/OpenSwiftUI/pull/829). macOS Preview support was enabled by the binary framework fixes in [PR #952](https://github.com/OpenSwiftUIProject/OpenSwiftUI/pull/952). Source builds and binary distributions must also satisfy the linkage requirements below.

### How It Works

Since OpenSwiftUI cannot use SwiftUI's `#Preview` macro directly (it targets `SwiftUI.View`), we use a **shim-based approach**:

1. A `_previewVC()` helper wraps an `OpenSwiftUI.View` in a platform hosting controller (`UIHostingController` / `NSHostingController`)
2. The hosting controller (a `UIViewController` / `NSViewController`) is returned to SwiftUI's `#Preview` macro

```swift
#Preview("HostingVC") {
    ContentView()._previewVC()
}
```

The same preview declaration works on both supported targets. Native macOS targets return an `NSViewController` backed by `NSHostingController`; iOS and Mac Catalyst targets return a `UIViewController` backed by `UIHostingController`.

### Binary XCFramework Requirements

Xcode Preview's XOJIT loading model requires both `OpenSwiftUI.framework` and `OpenSwiftUICore.framework` to be dynamic. Packaging `OpenSwiftUICore` as a static framework allows Preview to relink another copy of Core into the preview product, which can duplicate runtime metadata and crash the Preview process.

Link `OpenSwiftUICore` with `-ObjC` when building the framework so Objective-C categories from the static `OpenSwiftUI_SPI` dependency are retained in the Core dylib. This is a framework-build setting; consumers of the resulting XCFrameworks do not need to add `-ObjC`.

This layout was validated with locally built XCFrameworks consumed through `OpenSwiftUI-spm` local binary targets: the Tuist Example's `HostingVC` Preview rendered without consumer-side linker flags.

### The `waitingForPreviewThunks` Problem

In Xcode Preview mode, SwiftUI gates graph instantiation behind a `waitingForPreviewThunks` flag (checked via `XCODE_RUNNING_FOR_PREVIEWS` env var). After all preview dylibs are loaded, `PreviewsInjection.framework` calls `SwiftUI.__previewThunksHaveFinishedLoading()` to unblock graph hosts.

**The problem**: `PreviewsInjection` calls SwiftUI's version via a **library-specific GOT binding** (two-level namespace). OpenSwiftUI's version is never called, causing graph instantiation to block indefinitely and producing an empty display list.

**Current fix**: `waitingForPreviewThunks` is hardcoded to `false`, bypassing the blocking entirely. This is semantically correct because OpenSwiftUI has no preview thunk producers today.

## SwiftUI PreviewsInjection Reference Sequence

The following sequence describes SwiftUI's reference path. OpenSwiftUI currently bypasses the initial wait as described above.

```mermaid
sequenceDiagram
    participant PI as PreviewsInjection
    participant XOJIT as XOJITExecutor
    participant DPL as DYLDDynamicProductLoader
    participant SUI as SwiftUI
    participant GH as GraphHost

    Note over GH: waitingForPreviewThunks = true
    Note over GH: instantiateIfNeeded() → BLOCKED

    PI->>PI: __previews_injection_jit_link_entrypoint()
    PI->>PI: Check __PREVIEWS_JIT_LINK env var
    PI->>XOJIT: handleRunProgramOnMainThread()

    Note over DPL: Called during JIT execution
    loop For each DynamicProduct
        alt .dylib type
            DPL->>DPL: dlopen(bundlePath)
            Note over DPL: Thunks registered during dlopen
        else .xojit type
            DPL->>DPL: Skip (already loaded by XOJIT)
        end
    end

    DPL->>SUI: __previewThunksHaveFinishedLoading()
    SUI->>SUI: waitingForPreviewThunks = false
    SUI->>GH: graphDelegate.graphDidChange() for each blocked host
    Note over GH: Next layout pass → instantiate() → renders

    PI->>XOJIT: waitForTermination()
```

## Future Plan

The current shim-based approach is a temporary bridge. The long-term goal is for OpenSwiftUI to have its **own** native preview support:

### Phase 1: Own `#Preview` Macro
- Implement OpenSwiftUI's own `#Preview` macro that targets `OpenSwiftUI.View` directly
- Eliminate the need for `_previewVC()` shims and hosting controller wrappers
- Users would write `#Preview { MyView() }` with OpenSwiftUI views directly

### Phase 2: Own Preview Thunk Registration
- Implement an independent preview thunk registration system
- Re-enable `waitingForPreviewThunks` with OpenSwiftUI's own unblocking mechanism
- Decouple entirely from `PreviewsInjection.framework`'s SwiftUI-specific GOT binding

### Phase 3: Non-Apple Preview Host
- Build a standalone preview host that works outside Xcode
- Enable live previews on Linux/Windows where Xcode is not available
- Support hot-reload workflows independent of Apple's preview infrastructure
