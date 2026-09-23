# SDL3 UI framework

An experimental, opt-in UI framework adapter alongside UIKit and AppKit.
Select it at build time with `OPENSWIFTUI_UI_FRAMEWORK=SDL3`. The default native
app entrypoints remain unchanged. This is not a Linux-specific renderer, a
stdout renderer, a JSON helper process, or a DisplayList-to-Shaft-widget bridge.

## Architecture

```text
App / WindowGroup
  -> SDLApp: AppGraph, SDL windows, main-thread event loop
  -> SDLHostingView: ViewGraph, environment, layout, update deadlines
  -> ViewRendererHost.render / ViewGraphRenderHost.renderDisplayList
  -> SDLViewUpdater: typed DisplayList -> SDL_Renderer -> window
```

The adapter lives in `Sources/OpenSwiftUI/App/App/SDL3` and
`Sources/OpenSwiftUI/Integration/{Hosting,Drawing}/SDL3`, with input translation
in `Sources/OpenSwiftUI/Event/Platform/SDL3`. Only OpenSwiftUI
depends on SwiftSDL3. OpenSwiftUICore uses its existing, framework-neutral
`ViewGraphRenderHost` protocol to dispatch to the adapter. Existing
UIKit/AppKit `DisplayList.ViewRenderer` behavior is the fallback, unchanged.
No fake CALayer platform or changes to the native ViewSystem enum are needed.

The SDL loop services Foundation RunLoop work and graph transaction observers,
then renders invalidated windows. It waits up to 16 ms for SDL events so main
queue tasks and timers are not starved. Windows are not rendered continuously
when idle. Update requests wake SDL; presentation remains on the main thread.
Pixel size and display scale determine logical layout size. Resize/display
scale events invalidate layout; expose events repaint even without a new DL.

UI framework, drawing engine and graph engine are separate choices. This
prototype uses SDL's 2D renderer, selected by SDL (Metal on the tested Mac,
OpenGL/Mesa on the tested Linux host). A later Skia drawing implementation can
replace SDLViewUpdater without replacing App/WindowGroup or the event loop.
macOS uses AttributeGraph; Linux uses Compute's CI source tag
`0.5.2-bugfix.1`. Neither choice identifies the UI framework.

## Current scope

- Static WindowGroup scenes, one SDL window per scene, close/quit handling.
- Color rectangles, affine transforms, simple opacity, geometry groups.
- Layout, resizing, high-DPI scale, expose repaint and State-driven updates.
- Focus changes update the hosting view's scene phase.
- Mouse button/motion events enter the existing responder and TapGesture pipeline.
- Debug builds can read back their own rendered frame as a BMP.

Text/font layout, Path, images, clipping/masks, group compositing, interpolated
animations, native representables, keyboard/control input, IME and accessibility
are not implemented. Unsupported DL content/effects produce a diagnostic and
are skipped, not replaced with misleading rectangles. Dynamic scene insertion,
window titles and app-level scene-phase aggregation are also follow-ups.
The example deliberately uses real Color views rather than placeholder text
or the legacy Linux example. A single primary-button click toggles the top
red/green area; a double click toggles the bottom blue/yellow area. Both use
`onTapGesture` to mutate `@State`. The optional timer toggle is off by default
and remains a State-update test, not an animation interpolation test.

## Pointer input

```text
SDL mouse down / motion / up
  -> SDLMouseEventSource: window routing, coordinates, event identity, modifiers
  -> EventBindingManager + HitTestBindingModifier
  -> ViewGraph.sendEvents -> existing TapGesture / gesture callbacks
  -> @State -> ViewGraph invalidation -> SDLViewUpdater
```

The host requests `.viewResponders` as well as layout and DisplayList. Mouse
coordinates are converted from SDL window units into the same logical points
used for layout; the responder tree handles local coordinate conversion and
hit testing. SDL's click count preserves double-click sequence identity, but
OpenSwiftUI's recognizer still decides tap count, duration and movement limits.
SDL's default mouse auto-capture supplies drag/up events outside the window.
Focus loss, hiding, minimizing and closing cancel input. Terminal gesture
phases reset the event graph before the next sequence.

This uses the shared ViewGraph event path, not UIKit/AppKit recognizers. It
does not enable the UIKit-specific gesture-container path. Native touch,
pinch/rotation, hover, scrolling, keyboard focus and IME bridges are not yet
implemented or validated. SDL may emulate mouse input for touch, but that is
not a multi-touch implementation.

The Linux input build passes 11 SDL integration tests plus the related core
gesture/responder regression suites (60 tests total). Tests cover real State
changes through synthetic SDL events; live RDP clicking is a separate check.
The user subsequently confirmed that the Linux RDP interaction worked.
This iteration has not rebuilt or validated macOS input.

## Build and run

Requires Swift 6.3+, the normal sibling OpenSwiftUI dependencies, and the local
`SwiftSDL3` checkout. The Linux build uses the existing SwiftSDL3 source-list
patch in that checkout; it has not been migrated into OpenSwiftUI.

From the OpenSwiftUI repository:

```bash
Renderer/SDL3/run-example.sh build
Renderer/SDL3/run-example.sh launch
# Or build and launch together:
Renderer/SDL3/run-example.sh run
```

On macOS, use a Swift 6.3-capable Xcode via `DEVELOPER_DIR` if the default
toolchain is older. `SWIFT_COMMAND` can point to that toolchain's `usr/bin/swift`.
Do not set `SWIFT_EXEC` to `swift`; SwiftPM expects a compiler (`swiftc`) there.
The default build directory is `.build-sdl3`.

On Linux, build on the VM's native filesystem when sources are shared from
macOS. Use a distinct scratch path rather than sharing a macOS build cache:

```bash
export OPENSWIFTUI_SDL_BUILD_PATH="$HOME/.cache/openswiftui-sdl3-build"
Renderer/SDL3/run-example.sh build
# In the Linux desktop terminal (for example the existing xrdp session):
unset LIBGL_ALWAYS_INDIRECT
export LIBGL_ALWAYS_SOFTWARE=1
Renderer/SDL3/run-example.sh launch
```

Keep DISPLAY from the Linux desktop session. Do not redirect it to XQuartz.
The script adds the Swift toolchain library directory to LD_LIBRARY_PATH for
Compute's `libswiftDemangle.so`. Keep Swift and system runtime libraries
installed; these are development artifacts, not standalone distributables.

Ubuntu build prerequisites used by the sibling packages include `libssl-dev`,
`uuid-dev`, `libdbus-1-dev`, `libibus-1.0-dev`, `libdrm-dev`, `libwayland-dev`
and X11 development packages. GUI validation additionally requires a working
X11/Wayland session and a supported SDL rendering driver. `xvfb`, `xauth` and
Mesa permit headless X11 testing.

## macOS Xcode / Tuist

Generate and open the dedicated macOS workspace:

```bash
Renderer/SDL3/open-xcode.sh
```

Requires a Swift 6.3+ Xcode toolchain; select it with `DEVELOPER_DIR` when
necessary. The script uses the repository-pinned Tuist through mise when
available, configures SDL3 and the local dependencies, installs packages,
generates `Renderer/SDL3/SDL3.xcworkspace`, and opens it. Pass `--no-open`
to generate without opening Xcode. Opening honors the selected Xcode in
`DEVELOPER_DIR` (or `xcode-select`); it does not change the global selection.

Select the **SDL3Demo** scheme and **My Mac**, then Run. The scheme enables
DisplayList logging and the click-driven State example (timer disabled). It uses the same
`Example/SDLExampleApp.swift` as the SwiftPM executable, not a separate app.
The compiled OpenSwiftUI framework has `OPENSWIFTUI_SDL3` enabled, so running
from Xcode does not need a UI-framework environment variable in the scheme.

SwiftSDL3 is linked statically into the OpenSwiftUI framework. Local Darwin
framework shims follow the existing renderer example's Tuist configuration.
The SDL target enables Objective-C ARC and Clang modules, matching SwiftPM;
embedded dynamic frameworks use `@rpath`. Generation does not require remote
cache authentication.

To build the generated workspace without opening Xcode:

```bash
xcodebuild -workspace Renderer/SDL3/SDL3.xcworkspace \
  -scheme SDL3Demo -configuration Debug -destination 'platform=macOS' \
  -derivedDataPath Renderer/SDL3/.xcodebuild build
```

The app is `Renderer/SDL3/.xcodebuild/Build/Products/Debug/SDL3Demo.app`.
Validated with Tuist 4.206.0 and Xcode 26.6 / Swift 6.3.3: generation, Debug
build with default local signing, an actual SDL Metal window, State-driven
color changes, 470/20/470 pixel bands at 2x, and clean exit on window close.
Release/archive and Xcode previews have not been validated.

## Verification

```bash
Renderer/SDL3/run-example.sh test
OPENSWIFTUI_SDL_DEMO_ANIMATE=1 OPENSWIFTUI_PRINT_TREE=1 Renderer/SDL3/run-example.sh launch
```

The focused test suite checks rectangle pixels and scaled spacing, nested
origins/transforms, opacity, clearing an old frame, and SDL resize events
updating ViewGraph layout from 640x480 to 800x600. Input tests cover state
changes through single/double taps, gaps and window routing, secondary buttons,
movement, long presses, focus-loss cancellation and window-unit conversion.
The window tests require
a graphics session; on Linux it can run under `xvfb-run -a`.

Set `OPENSWIFTUI_SDL_CAPTURE_PATH=/tmp/sdl3-frame.bmp` to inspect the latest
frame in a debug build. Capture reads the application's renderer immediately
before presentation; it is not a screenshot of the desktop/RDP client.
Disable it for normal use because GPU readback and file output are synchronous.

SDL contracts: [main-thread rendering](https://wiki.libsdl.org/SDL3/SDL_CreateRenderer),
[event waiting](https://wiki.libsdl.org/SDL3/SDL_WaitEventTimeout),
[pixel density and display scale](https://wiki.libsdl.org/SDL3/README-highdpi),
[mouse buttons](https://wiki.libsdl.org/SDL3/SDL_MouseButtonEvent).
