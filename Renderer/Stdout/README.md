# Stdout Renderer

This package runs a minimal OpenSwiftUI app with the stdout renderer enabled.
The package depends on the local OpenSwiftUI checkout at `../..`.

## Run

```sh
swift run ExampleApp
```

The example configures the app renderer with:

```swift
@_spi(StdoutRenderer) import OpenSwiftUI

static var _rendererConfiguration: _RendererConfiguration? { .stdout() }
```
