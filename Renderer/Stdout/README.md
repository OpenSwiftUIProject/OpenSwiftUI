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

The Tuist project uses local OpenSwiftUI, OpenAttributeGraph, OpenRenderBox,
and DarwinPrivateFrameworks dependencies so Xcode does not need to open the
Swift package directly.

The example configures the app renderer with:

```swift
@_spi(StdoutRenderer) import OpenSwiftUI

static var rendererConfiguration: _RendererConfiguration? { .stdout() }
```
