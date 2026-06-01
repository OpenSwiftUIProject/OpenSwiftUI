# Renderers

This directory contains renderer-specific examples and helper packages that are
kept outside the main OpenSwiftUI package manifest.

## Stdout

`Stdout/` contains a small executable package that launches an OpenSwiftUI app
with the stdout renderer enabled. It is useful for checking display-list output
without adding demo targets to the main package.

Run it from this repository:

```sh
cd Renderer/Stdout
./run-example.sh
```

On macOS, use the Stdout Tuist project for Xcode runs.
