# Web Renderer

This directory contains a SwiftWASM proof of concept that compiles an
OpenSwiftUI `App` and renders its display list into a browser-owned Canvas 2D
surface. The Swift package depends on the local OpenSwiftUI checkout at
`../..`; JavaScriptKit is confined to this browser adapter.

The first implementation intentionally supports the same static subset as the
stdout renderer: solid colors, solid-color shapes approximated by their frame,
opacity, affine transforms, flattened lists, and matched state lists. It
performs one full Canvas redraw at launch. Unsupported visual effects are
skipped as complete subtrees. Text, images, arbitrary paths, animation,
interaction, and incremental updates are not implemented yet.

## Build

Install a swift.org Swift 6.3.2 toolchain and its matching Wasm SDK, then run:

```sh
./build-example.sh
```

The script cross-compiles the complete OpenSwiftUI package graph and uses
JavaScriptKit's SwiftPM command plugin to write `Bundle/ExampleApp.wasm` and
its JavaScript runtime files.

## Preview

Serve the directory over HTTP after building:

```sh
python3 -m http.server 8000
```

Then open <http://localhost:8000/>. The generated Canvas has
`data-display-list-version` and `data-render-command-count` attributes so a
browser smoke test can assert that the Swift display list reached the page.

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
a callback-based web frame boundary, keeping browser APIs out of the DSL and
layout implementation.
