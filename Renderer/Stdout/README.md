# Stdout Renderer

This directory contains a minimal OpenSwiftUI app with the stdout renderer
enabled. The Swift package depends on the local OpenSwiftUI checkout at `../..`.

## CLI

```sh
./run-example.sh
```

The script selects AttributeGraph on macOS and Compute on other platforms,
then runs `swift run ExampleApp`.

## macOS Xcode

Use the Tuist project when running the demo from Xcode on macOS:

```sh
./open-xcode.sh
```

The script runs `tuist install`, generates the workspace without opening during
generation, then opens `StdoutRenderer.xcworkspace`. If `mise` is available, the
script uses the repository-pinned Tuist version.

The Tuist project uses local OpenSwiftUI, OpenAttributeGraph, OpenRenderBox,
and DarwinPrivateFrameworks dependencies so Xcode does not need to open the
Swift package directly. Its package settings mirror the generated Example
project's local OpenSwiftUI product destinations, keeping AttributeGraph
enabled on macOS while preserving valid generated target platforms.

The example configures the app renderer with terminal view mode:

```swift
@_spi(StdoutRenderer) import OpenSwiftUI

static var rendererConfiguration: _RendererConfiguration? {
    var options = _RendererConfiguration.StdoutOptions()
    options.viewMode = .terminal
    return .stdout(options)
}
```

## View modes

The default `displayList` mode writes one line for each supported display-list
command. It includes resolved frames and colors, and now includes resolved text
runs on macOS.

Terminal mode maps the logical surface into terminal cells. Solid colors become
cell backgrounds and text becomes cell content. Set `terminalSize` for
deterministic output, or leave it as `nil` to use `TIOCGWINSZ`, followed by the
`COLUMNS` and `LINES` environment variables, and finally an 80 by 24 fallback.

```swift
var options = _RendererConfiguration.StdoutOptions()
options.viewMode = .terminal
options.terminalSize = .init(columns: 80, rows: 24)
```

`colorMode` defaults to `automatic`. Automatic detection emits no ANSI color
when standard output is not a terminal, when `TERM=dumb`, or when a nonempty
`NO_COLOR` value is present. It recognizes `COLORTERM=truecolor` / `24bit`,
direct-color terminal names, and `TERM` values containing `256color`; other
named terminals use the ANSI 16-color palette. An explicit `colorMode` overrides
automatic detection.

Available explicit modes are `monochrome`, `ansi16`, `ansi256`, and
`trueColor`. Monochrome output uses block characters for solid color regions so
the view remains visible when output is redirected.

## Text support

On macOS, resolved `Text` display-list content is emitted as text commands and
rendered into terminal cells. Foreground colors are preserved for individual
attributed-string runs. Text command extraction is currently compiled only on
macOS.

On Linux, string and color resolution already use the non-Darwin shims, but
`NSAttributedString` measurement in
`Sources/OpenSwiftUICore/View/Text/Text/Text+StringDrawingContext.swift` still
returns zero-sized metrics. The display-list commit therefore removes the empty
text frame before the stdout renderer can see it.

A full Linux implementation should add a platform text-layout provider rather
than assigning fixed terminal widths in the generic SwiftUI layout engine.
[Pango](https://docs.gtk.org/Pango/) is the most direct candidate because it
provides shaping, bidirectional layout, wrapping, ellipsizing, baselines, and
logical/ink extents, with HarfBuzz and FreeType integrations. A smaller
terminal-only provider would still need Unicode cell-width handling, including
[East Asian Width](https://www.unicode.org/reports/tr11/), and would not provide
general SwiftUI-compatible measurement.
