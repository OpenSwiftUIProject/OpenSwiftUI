# Web Renderer

This directory contains a SwiftWASM proof of concept that compiles an
OpenSwiftUI `App` and renders its display list into a browser-owned Canvas 2D
surface. The Swift package depends on the local OpenSwiftUI checkout at
`../..`; JavaScriptKit is confined to this browser adapter.

The first implementation supports a static subset: solid colors, ellipses and
circular rounded rectangles, opacity, affine transforms, flattened
lists, matched state lists, and single-line text with a system font. The
browser measures and draws supported text through Canvas 2D.

`LinearGradient`, `RadialGradient`, `EllipticalGradient`, and
`AngularGradient` (including its full-turn conic initializer) can fill
rectangles, circles, ellipses, and circular rounded rectangles. The renderer
uses OpenSwiftUI's resolved stops and approximates its color interpolation
with sampled Canvas stops. Angular and conic fills require Canvas
`createConicGradient`. Gradient text and masks are not supported yet.

The WASI host feeds browser pointer down/move/up/cancel events into the shared
`EventBindingManager`, responder hit testing, and gesture graph. Both
`onTapGesture` and `.gesture(TapGesture().onEnded { ... })` use the core
recognizer; the Canvas adapter does not implement its own tap counts or hit
rectangles. Mouse, touch, and pen sequences use independent identities, with
pointer capture and cancellation on capture loss or page deactivation.
Gesture deadlines run on the JavaScript event loop, and `@State` changes
schedule another frame. Gesture behavior is limited by the shared core's
current implementation; this adapter does not supply missing recognizers,
keyboard/focus support, or native platform gesture recognizers.
WASI path hit testing supports rectangles, ellipses, and rounded rectangles
with a uniform circular radius. Continuous corners, stroked, trimmed, and
arbitrary paths are not hit targets yet. Other solid-color shapes still render
as their frame bounds.
Unsupported visual effects are skipped as complete subtrees. Images, arbitrary
paths, and complex text layout are not implemented yet.

## Interactive controls

On WASI, the default `Slider` style draws a rounded track and circular thumb
and uses the shared gesture graph for track clicks and drags. The upstream
binding handles the range and optional step, and `onEditingChanged` reports
the start and end of pointer editing, including cancellation.

`Stepper` and `Toggle` use the shared Button interaction. A bounded
`Stepper` disables each segment at its corresponding limit. Each activation
applies one step and calls `onEditingChanged` before and after the change.
The default `Toggle` has an iOS-style rounded track and circular thumb.
These Canvas controls do not implement browser keyboard or accessibility
support or press-and-hold repetition.

For a Playground smoke check, use this `ContentView`:

```swift
import OpenSwiftUI

struct ContentView: View {
    @State private var isEnabled = true
    @State private var lockedSwitch = false
    @State private var level = 25.0
    @State private var isEditing = false
    @State private var quantity = 2

    var body: some View {
        VStack(spacing: 12) {
            Toggle(isOn: $isEnabled) {
                Text(isEnabled ? "Slider enabled" : "Slider disabled")
            }
            Slider(value: $level, in: 0...100, step: 5) {
                Text("Level")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("100")
            } onEditingChanged: { editing in
                isEditing = editing
            }
            .disabled(!isEnabled)
            Text("Level: \(Int(level)) · \(isEditing ? "Editing" : "Idle")")
            Stepper(value: $quantity, in: 0...5) {
                Text("Quantity: \(quantity)")
            }
            Toggle(isOn: $lockedSwitch) {
                Text(lockedSwitch ? "Locked switch: On" : "Locked switch: Off")
            }
            .disabled(true)
        }
        .frame(width: 320)
        .foregroundStyle(Color.white)
    }
}
```

Click and drag along the track to check that the displayed value changes in
steps of five and clamps at both ends, including when dragging outside the
track. Release or cancel the pointer to return to `Idle`. Toggle the first
switch off and check that the slider no longer changes. Clicking the locked
switch should leave it off. Tap the Stepper's minus and plus buttons until
the lower and upper limits; the relevant segment should dim and no longer
change the value.

## JavaScript-backed values

The WASI-only `JavaScriptReader` SPI lets a web app synchronously resolve a
JavaScript-backed value and use a `Sendable` Swift snapshot to build a view.
JavaScript bridge objects stay inside the resolver closure, so OpenSwiftUI
doesn't depend on JavaScriptKit or retain thread-bound JavaScript handles. The
resolver can run more than once and should be fast and free of side effects.

The example uses this reader to display a best-effort browser-reported identity
and version. Chromium-based browsers can intentionally report themselves as
Chrome, so the result isn't guaranteed product detection.

The example also renders a small text-style matrix combining four foreground
colors with light, medium, heavy, and black font weights. Together with the
existing examples, this covers CSS weights 300 through 900. Its Canvas metadata
includes distinct color and font-weight counts so browser smoke tests can
verify that both styles reached the renderer. `ExampleApp/ContentView.swift`
is intentionally separate from the trusted app and Canvas adapter so the local
playground can edit only that source file. It includes a Button and
state-driven Slider, Toggle, and Stepper examples.

## Build

Install a swift.org Swift 6.3.2 toolchain and its matching Wasm SDK, then run:

```sh
./build-example.sh
```

The script cross-compiles the complete OpenSwiftUI package graph and uses
JavaScriptKit's SwiftPM command plugin to write `Bundle/ExampleApp.wasm` and
its JavaScript runtime files. An optional output-directory argument lets the
playground build into a private staging directory before publishing a complete
preview revision.

## Playground

Start the local build service:

```sh
npm ci
npm start
```

Then open <http://127.0.0.1:8000/>. The left pane edits
`ExampleApp/ContentView.swift` with a locally installed Ace editor. A small
local mode adapter extends Ace's Swift tokenizer with the modern keywords used
by this Swift toolchain. After 700 milliseconds without input, the service runs
an incremental SwiftWASM build. The first build uses PackageToJS to establish a
complete browser bundle and SwiftPM's native llbuild plan. Subsequent Fast
Preview builds reuse that plan, so ordinary `ContentView` edits run only the
ExampleApp incremental compile, module wrapping, and the required static link;
they don't repeat SwiftPM package planning or rebuild unchanged OpenSwiftUI
targets. Compiler diagnostics appear below the editor.
A successful revision starts in a hidden iframe and replaces the visible
Preview only after the new Canvas frame is ready. A failed compile or runtime
initialization leaves the last successful Preview on screen.

Use **Reset to Default** next to **Run** to reload and build the stock
ContentView. Its Gradients panel shows Linear, Radial, Elliptical, Angular,
and Conic swatches side by side with the control samples. The button asks before
replacing edited source. Its preset lives in the `default-content-view`
data block in `index.html`, separate from the writable compile input.

Fast Preview fails closed. A missing cache, a package/runtime configuration
change, or source that changes JavaScriptKit packaging automatically uses a
full PackageToJS build and refreshes the plan. Swift's dependency analysis may
also recompile another ExampleApp source when a `ContentView` declaration
changes its interface; the optimization deliberately doesn't force an unsafe
single-file result. Set `OPENSWIFTUI_WEB_SWIFT_BUILD_TOOL` when the matching
toolchain's `swift-build-tool` isn't discoverable beside a swiftly-installed
macOS toolchain or on `PATH`.

The service accepts source text only, binds to `127.0.0.1`, serializes builds,
and publishes complete bundles under immutable revision URLs. It is intended
for locally authored, trusted source. It is not a sandbox for untrusted Swift
or JavaScript code. Generated revisions and drafts live under `.preview/` and
are not versioned.

Ace (`ace-builds` 1.44.0, BSD-3-Clause) is loaded only from the pinned local
npm dependency. The Playground keeps scripts same-origin; its page allows
inline styles because Ace positions and themes the editable surface with
runtime-generated CSS. Highlighting is lexical; it does not provide SourceKit
type information, completion, or symbol navigation.

Frontend-only integration checks do not invoke the SwiftWASM build:

```sh
npm test
```

The current JavaScriptKit packaging mode loads its WASI browser shim from a
CDN, so the first Preview requires network access.

## Static preview

Serve the directory over HTTP after building:

```sh
python3 -m http.server 8000
```

Then open <http://127.0.0.1:8000/preview.html>. The generated Canvas has
`data-display-list-version`, `data-render-command-count`,
`data-text-color-count`, `data-text-font-weight-count`,
`data-web-input`, `data-web-pointer-event-count`, and
`data-active-pointer-count` attributes so a
browser smoke test can assert that the Swift display list, text styles, and
pointer input reached the page. `data-rendered-text` exposes the frame's text
for checking state-driven updates rather than only input delivery.

With the default `Tap count` example built, open
<http://127.0.0.1:8000/tests/gesture-smoke.html> and press Start to run the
opt-in browser gesture checks. These use real WASM and synthetic PointerEvents
to cover state updates, cancellation, movement/duration rejection, multi-tap
deadlines, pointer kinds and CSS coordinate scaling. Physical pointer capture still needs a real
mouse/touch check. The test page is served by the static server above, not the
playground service's production asset allowlist.

## Data flow

```text
OpenSwiftUI DSL
  -> AppGraph / ViewGraph / layout
  -> DisplayList
  -> static render commands
  -> JavaScriptKit
  -> CanvasRenderingContext2D
```

The browser adapter owns JavaScriptKit and Canvas. OpenSwiftUICore exposes only
a callback-based web frame boundary and WASI-only pointer-input SPI, keeping
JavaScriptKit types out of the OpenSwiftUI API and layout implementation.

```text
DOM PointerEvent -> _WebEventBridge -> EventBindingManager
  -> responder hit test -> ViewGraph gesture graph -> TapGesture.onEnded
  -> @State -> next Canvas frame
```
