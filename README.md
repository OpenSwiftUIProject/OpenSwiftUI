# OpenSwiftUI

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FOpenSwiftUIProject%2FOpenSwiftUI%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/OpenSwiftUIProject/OpenSwiftUI) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FOpenSwiftUIProject%2FOpenSwiftUI%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/OpenSwiftUIProject/OpenSwiftUI) [![codecov](https://codecov.io/gh/OpenSwiftUIProject/OpenSwiftUI/graph/badge.svg?token=S63P3YUCAJ)](https://codecov.io/gh/OpenSwiftUIProject/OpenSwiftUI)

OpenSwiftUI is an open source implementation of Apple's [SwiftUI](https://developer.apple.com/documentation/swiftui)

The project is for the following purposes:
- Build GUI app on non-Apple platform (eg. Linux & Windows)
- Diagnose and debug SwfitUI issues on Apple platform

And the API design is to stay the same as the original SwiftUI API as possible.

Currently, this project is in early development.

You can find the API [documentation](https://swiftpackageindex.com/OpenSwiftUIProject/OpenSwiftUI/main/documentation/openswiftui) here.

> [!WARNING]
> This package use a lot of hidden API and private framework on Apple platform.
>
> Please **DO NOT** use this package in Apple's production environment(eg. App Store).
> 
> Otherwize it may break your build or crash your app at any future SDK/OS update.

## Usage

See Example folder and try it with ExampleApp

> [!IMPORTANT]  
> Clone OpenGraph in the same directory before running the example.
>
> See [Example/README.md](Example/README.md) for more detail.

## Build

### Build without testing framework

```
./Scripts/build
```

### Build with Library Evolution

```
./Scripts/openswiftui_swiftinterface
```

## Supported platforms

The table below describes the current level of support that `OpenSwiftUI` has
for various platforms:

| **Platform** | **CI Status** | **Support Status** | Build | Test | Deploy |
|-|:-|-|-|-|-|
| **macOS** | [![macOS](https://github.com/OpenSwiftUIProject/OpenSwiftUI/actions/workflows/macos.yml/badge.svg)](https://github.com/OpenSwiftUIProject/OpenSwiftUI/actions/workflows/macos.yml) [![Compatibility tests](https://github.com/OpenSwiftUIProject/OpenSwiftUI/actions/workflows/compatibility_tests.yml/badge.svg)](https://github.com/OpenSwiftUIProject/OpenSwiftUI/actions/workflows/compatibility_tests.yml) | ⭐️⭐️⭐️ *[^1] | ✅ | ✅ | ✅ |
| **iOS** | [![iOS](https://github.com/OpenSwiftUIProject/OpenSwiftUI/actions/workflows/ios.yml/badge.svg)](https://github.com/OpenSwiftUIProject/OpenSwiftUI/actions/workflows/ios.yml) | ⭐️⭐️⭐️⭐️ *[^2] | ✅ | ✅ | ✅ |
| **Ubuntu 22.04** | [![Ubuntu](https://github.com/OpenSwiftUIProject/OpenSwiftUI/actions/workflows/ubuntu.yml/badge.svg)](https://github.com/OpenSwiftUIProject/OpenSwiftUI/actions/workflows/ubuntu.yml) | ⭐️⭐️ *[^3] | ✅ | ✅ | ❌ |
| **Wasm** | [![Ubuntu](https://github.com/OpenSwiftUIProject/OpenSwiftUI/actions/workflows/ubuntu.yml/badge.svg)](https://github.com/OpenSwiftUIProject/OpenSwiftUI/actions/workflows/ubuntu.yml) | ⭐️ *[^4] | ✅ | ❌ | ❌ |
| **Windows** | | Not supported yet | ❌ | ❌ | ❌ |


[^1]: AppKit and other UI framework backend is not intergrated yet.

[^2]: UIKit intergration is partly implemented. No Render support yet.

[^3]: Build and test is supported. But some feature is cut due to known Swift compiler issue.

[^4]: Build is supported. Test is not supported yet dut to upstream issue.

> [!NOTE]
> The cross-platform OpenGraph is not fully implemented.
>
> It is only API compatible with AttributeGraph now.
>
> So most of the core feature is only available on Apple platform built with
> AttributeGraph varient.

## License

See LICENSE file - MIT

## Related Projects

- https://github.com/Cosmo/OpenSwiftUI
- https://github.com/helbertgs/OpenSwiftUI

## Star History

<a href="https://star-history.com/#OpenSwiftUIProject/OpenSwiftUI&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=OpenSwiftUIProject/OpenSwiftUI&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=OpenSwiftUIProject/OpenSwiftUI&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=OpenSwiftUIProject/OpenSwiftUI&type=Date" />
  </picture>
</a>
