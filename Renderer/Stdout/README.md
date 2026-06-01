# Stdout Renderer

This package runs a minimal OpenSwiftUI app with the stdout renderer enabled.
The package depends on the local OpenSwiftUI checkout at `../..`.

## Run

```sh
./run-example.sh
```

The script selects AttributeGraph on macOS and Compute on other platforms,
then runs `swift run ExampleApp`.

The example configures the app renderer with:

```swift
@_spi(StdoutRenderer) import OpenSwiftUI

static var _rendererConfiguration: _RendererConfiguration? { .stdout() }
```
