# Example Tests

UI and interaction tests run in `TestingHost` as separate test targets in the
generated Example workspace. Both targets use SnapshotTesting and the shared
helpers in this directory.

## Layout

| Directory | Purpose |
| --- | --- |
| `OpenSwiftUIUITests` | UI snapshot tests and their hosting helpers. |
| `OpenSwiftUIInteractionTests` | Gesture and state tests that use Hammer to send input events. |
| `Shared` | Snapshot configuration, reference paths, and Swift Testing tags compiled into both targets. |
| `ReferenceImages` | Local snapshot references, grouped by platform, OS version, test module, and source file. |

## Run Tests

Follow the [project setup instructions](../README.md#generate-project), then
open the generated `Example.xcworkspace` and select a test scheme:

| Test target | Record with SwiftUI | Verify with OpenSwiftUI |
| --- | --- | --- |
| `OpenSwiftUIUITests` | `SUI_UITests` | `OSUI_UITests` |
| `OpenSwiftUIInteractionTests` | `SUI_InteractionTests` | `OSUI_InteractionTests` |

Run the SwiftUI scheme to create or update reference images, then run the
OpenSwiftUI scheme on the same destination and OS version. Recording reports
snapshot recording issues; verification compares against the saved images.

Both targets compile [Shared/Tag.swift](Shared/Tag.swift). Use `.localization`
for localization-sensitive tests and `.interaction` for interaction suites.

## Snapshot References

[Shared/SnapshotTesting.swift](Shared/SnapshotTesting.swift) defines the recording
defaults, image comparison tool, and reference paths. Use
`.snapshots(record: .never, diffTool: diffTool)` on snapshot test suites, as in the
existing UI tests. The shared helpers record with SwiftUI and compare with
OpenSwiftUI by default. Pass `record:` to override this behavior.

References use `SNAPSHOT_REFERENCE_DIR` or `Example/Tests/ReferenceImages`, followed
by the platform, OS version, and test file ID. UI and interaction tests use
separate module directories. Snapshot names include the hosted view's size;
give each argument a distinct snapshot name in parameterized tests.

Reference PNG files are ignored by Git. See the
[reference storage guide](ReferenceImages/README.md) for local and CI paths.

## Interaction Tests

Interaction tests use the
[OpenSwiftUIProject Hammer fork](https://github.com/OpenSwiftUIProject/Hammer)
to send touch events on iPhone and iPad, and mouse events on Mac. Mark suites
with `.tags(.interaction)` and keep them on the main actor. Serialize tests that
share application windows and Hammer settings.

Use `withInteractionTestHost(of:size:)` to host a view and clean up after the test.
The default content size is 200×200 points, shared with UI tests through
`defaultSize` in [Shared/SnapshotTesting.swift](Shared/SnapshotTesting.swift).
Pass `size` only when a test needs another content size. The hosted view and its
snapshots use that size on both macOS and iOS, independently of the screen size.
Call the helper, `tap()`, and `waitUntil(_:timeout:)` with `try await`.
`assertSnapshot(named:)` captures the current hosted view and preserves its
state for later interactions:

```swift
try await withInteractionTestHost(of: content) { host in
    try await host.assertSnapshot(named: "before")
    try await host.tap()
    try await host.waitUntil(count == 1)
    try await host.assertSnapshot(named: "after")
}
```

On macOS, tests use an offscreen window to preserve application focus. Set
`HAMMER_SHOW_TEST_WINDOW=1` in the scheme environment to show it while debugging.

## CI

Interaction CI runs `OSUI_InteractionTests` with persistent references. Request
`update` or set `update_reference=true` to run `SUI_InteractionTests` first,
including for the initial baseline. UI CI also records when references are
missing. Both workflows share platform and configuration choices, test filters,
reference storage, and recording locks.

The default configurations use the SwiftUI renderer with AttributeGraph and the
OpenSwiftUI renderer with Compute. CI accepts recording issues only when no
other failures are present; a recording failure stops verification.
See [Optional CI workflows](../../Docs/CI/README.md) for dispatch and PR comment
commands.
