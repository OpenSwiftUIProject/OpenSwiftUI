# Embedded display and input profile

This experiment compiles selected OpenSwiftUICore sources into a single
`OpenSwiftUI` module for Embedded Swift. It retains the declarative
`struct ContentView: View` and `@ViewBuilder` composition path while replacing
the dynamic graph renderer with a synchronous, generic `EmbeddedRenderSink`.

This is an explicit source profile, not a regular SwiftPM target with all
framework dependencies made optional. `sources.txt` is the authoritative list.
Do not pass `OPENSWIFTUI_EMBEDDED` to the full default package source set.

## Build and integrate

Use Swift 6.3.1 RELEASE with Embedded RISC-V libraries. ESP32-C3 also needs the
ESP-IDF 5.5.3 toolchain on PATH. Output belongs in the containing workspace:

    python3 Scripts/build_embedded.py --target riscv32 --output ../build/riscv32
    Scripts/test_embedded.sh

`idf.cmake` exposes `openswiftui_link_embedded(target)` after the ESP-IDF Swift
component is configured. It builds an independent `.swiftmodule` and `.a`, adds
the import path to Swift compilation, and links the archive into the firmware.
The selected source list participates in CMake dependency tracking.

Embedded Swift specializes generic declarations into their clients. A small
archive therefore does not imply that all rendering code executes from that
archive. The source module and archive together are the build interface. The
C-callable `openswiftui_embedded_version()` reports profile ABI version 3.

## Source selection and semantics

Shared declarations: View/PrimitiveView and body composition, ViewBuilder's
expression/empty/single/conditional logic, EmptyView, Never and conditional
content storage. The Embedded branches replace MainActor/graph requirements
and tuple metadata traversal with compile-time generic dispatch and ordered
pairs. Default-platform implementations are retained behind compilation guards.

Embedded primitives now participate in measure/place layout. `RootGeometry`
accepts the physical screen and insets, proposes the available area, measures the
root and centers its fitted bounds. The platform must supply actual text/font
and image measurements through `EmbeddedRenderSink`; measurement failure must
remain visible to the caller. Images use intrinsic size unless `resizable()` is
explicit. Text wraps at the proposed width with the platform's fixed font.

`Layout` has `makeCache`, `sizeThatFits` and `placeSubviews` phases. Its generic
`LayoutSubviews<Content, Sink>` provides `sizeThatFits(index, proposal:)` and
`place(index, x:y:proposal:)`; `layout { ... }` builds a typed container. This
is an Embedded-specific API with integer pixels, not the desktop existential
Subview/CGRect API. Clients can implement custom layouts; tests exercise a
separate-module custom layout with a typed cache.

VStack/HStack measure minimum and maximum sizes along their major axis, allocate
less-flexible children first, then place them in declaration order with explicit
spacing/alignment. Unspecified dimensions request ideal sizes; a finite 32767
pixel probe supplies the maximum. Default spacing is a constant 8 pixels.
Subviews that decline a proposal may overflow; the platform clips to its content
viewport. Builder pairs, custom bodies, optionals and conditionals flatten into
children; absent views add no spacing. Each container is limited to 32 children.
Small arrays hold measurement caches; no existential or persistent view graph is
allocated. Frame, padding and backgrounds participate in measurement; offsets
leave the parent-reported size unchanged.

The original graph-backed RootGeometry/StackLayout implementations were inspected
and their proposal/measurement/placement model informed this port. They are not
compiled here. Baseline/RTL alignment, layout priorities, Spacer, full safe-area
propagation, intrinsic spacing negotiation and desktop cache invalidation remain
unsupported. The profile is synchronous and the root insets are host-configured.

Foundation, AttributeGraph, RenderBox, existential view trees, full dynamic state,
observation, diffing, animations, platform App/Scene, accessibility,
SF Symbols and asset-catalog/runtime image decoding are excluded. Other
workspace repositories are available for further work but are not linked here.

A sink runs synchronously under platform-controlled serialization. It must clip
to its viewport, bound allocations/text/assets, and report unsupported assets.
No framebuffer or UI object storage is owned by the generic View layer.

## Physical buttons and retained state

`view.onPhyicButton(.up/.down/.ok) { ... }` installs a synchronous click closure.
The spelling is intentional. Host dispatch evaluates the current body and invokes
one matching handler: outermost modifier first, otherwise children in declaration
order. Conditional/optional branches only participate when present. The modifier
preserves layout child counts and geometry. There is no focus or hit-test layer.
Actions are not registered or retained between passes, so captures reflect the
current body and there is no stale closure table to clear on rerender.

    struct ContentView: View {
        @State private var blue = false
        var body: some View {
            (blue ? Color.blue : Color.red)
                .onPhyicButton(.up) { blue = false }
                .onPhyicButton(.down) { blue = true }
                .onPhyicButton(.ok) { blue.toggle() }
        }
    }
    let host = EmbeddedViewHost { ContentView() }
    host.send(.down)
    if host.needsRender {
        host.render(rootGeometry: geometry, to: &sink)
    }

The builder is required: it associates newly constructed state boxes with this
host. The host retains the root value, and copying a State wrapper shares its
storage. Each write invalidates only its owning host; repeated writes coalesce
until the next render. `invalidate()` also permits retry after a sink failure.
All construction, input, state access and rendering must be platform-serialized.
State writes during rendering and reentrant host dispatch/render fail explicitly.
The platform releases its host on exit and is responsible for dropping old input.

This is retained-root State, not the default GraphHost/DynamicProperty runtime.
State in stored children constructed with the root is supported. State in new
children created by `body` is unsupported: without structural identity such state
would reset, so initialization outside a host builder fails explicitly instead.
Binding projection (`$state`), dynamic child identity and asynchronous scheduling
are not provided. The normal platform's State implementation is unchanged.
No additional framework repository is required by this profile.

## Validation

`Scripts/test_embedded.sh` compiles the real module and a separate Embedded
client executable, testing nested body traversal, conditional/optional
branches, draw order, color bounds, root geometry, changing screen proposals,
stack alignment/flexibility/remainders, text wrapping, intrinsic images, modifiers
a client-defined Layout, State lifetime/host isolation, handler precedence,
conditional routing, fresh captures and teardown. It does not
invoke XCTest or Swift Testing, whose runtimes are outside this target profile.

FoloToy integration additionally verifies its actual ContentView and C boundary,
builds the same LVGL renderer on the host for pixel preview, and runs the
ESP32-C3 merged-image gate. Hardware results are recorded in the firmware
repository separately from these host checks.

See the [Embedded Swift linkage model](https://forums.swift.org/t/embedded-swift-linkage-model/81441)
for cross-module specialization behavior.
