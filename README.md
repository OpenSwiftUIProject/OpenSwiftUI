# OpenSwiftUI

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FOpenSwiftUIProject%2FOpenSwiftUI%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/OpenSwiftUIProject/OpenSwiftUI) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FOpenSwiftUIProject%2FOpenSwiftUI%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/OpenSwiftUIProject/OpenSwiftUI) [![codecov](https://codecov.io/gh/OpenSwiftUIProject/OpenSwiftUI/graph/badge.svg?token=S63P3YUCAJ)](https://codecov.io/gh/OpenSwiftUIProject/OpenSwiftUI)

OpenSwiftUI is an open source implementation of Apple's [SwiftUI](https://developer.apple.com/documentation/swiftui)

The project is for the following purposes:
- Build GUI app on non-Apple platform (eg. Linux & Windows)
- Diagnose and debug SwiftUI issues on Apple platform

And the API design and documentation is to stay as compatible with the original SwiftUI API as possible.

> [!TIP]
> "Why join the navy if you can be a pirate?" — Steve Jobs
>
> :)

Currently, this project is in early development.

The full API [documentation](https://openswiftuiproject.github.io/OpenSwiftUI/documentation/openswiftui/) is hosted on GitHub Pages.

## Notes

this project is for learning and research purposes only.

If you choose to use this project, you do so at your own risk and are responsible for compliance with any applicable laws.

The author of this project is not responsible for any consequences that may arise from your use of this project.

> [!WARNING]
> This package use a lot of hidden API and private framework on Apple platform.
>
> Please **DO NOT** use this package in Apple's production environment(eg. App Store).
> 
> Otherwize it may break your build or crash your app at any future SDK/OS update.

## Usage

### Integration Guide

To integrate OpenSwiftUI into your own Xcode project, see **[INTEGRATION.md](INTEGRATION.md)** for detailed step-by-step instructions.

### Example Application

See Example folder and try it with ExampleApp

> [!IMPORTANT]
> Clone OpenAttributeGraph in the same directory before running the example.
>
> See [Example/README.md](Example/README.md) for more detail.

## Build

The current suggested toolchain to build the project is Swift 6.1.2 / Xcode 16.4 with macOS 15.5 or iOS 18.5 Simulator.

### Build without testing framework

```
./Scripts/build
```

### Build with Library Evolution

```
./Scripts/openswiftui_swiftinterface
```

> [!NOTE]
> This project's configuration is heavily based on many environment variables.
>
> You can use the following tools on macOS platform to manage the environment variable more easily.
> 
> - [EnvPane](https://github.com/hschmidt/EnvPane/releases/): A macOS preference pane for environment variables
> - [MenuHelper](https://github.com/Kyle-Ye/MenuHelper/releases): A Finder Extension App to improve your efficiency.
> - launchctl via `Scripts/sync_launchagent.sh`

## Supported platforms

The table below describes the current level of support that `OpenSwiftUI` has
for various platforms:

### Darwin Platform Status

| **Test Type** | **CI Status** |
|-|:-|
| **SwiftUI Compatibility** | [![Compatibility tests](https://github.com/OpenSwiftUIProject/OpenSwiftUI/actions/workflows/compatibility_tests.yml/badge.svg)](https://github.com/OpenSwiftUIProject/OpenSwiftUI/actions/workflows/compatibility_tests.yml) |
| **UI Tests** | [![UI Tests](https://github.com/OpenSwiftUIProject/OpenSwiftUI/actions/workflows/uitests.yml/badge.svg)](https://github.com/OpenSwiftUIProject/OpenSwiftUI/actions/workflows/uitests.yml) |

### Platform Support

| **Platform** | **CI Status** | **Support Status** | Build | Test | Deploy |
|-|:-|-|-|-|-|
| **macOS** | [![macOS](https://github.com/OpenSwiftUIProject/OpenSwiftUI/actions/workflows/macos.yml/badge.svg)](https://github.com/OpenSwiftUIProject/OpenSwiftUI/actions/workflows/macos.yml) | ⭐️⭐️⭐️ *[^1] | ✅ | ✅ | ✅ |
| **iOS** | [![iOS](https://github.com/OpenSwiftUIProject/OpenSwiftUI/actions/workflows/ios.yml/badge.svg)](https://github.com/OpenSwiftUIProject/OpenSwiftUI/actions/workflows/ios.yml) | ⭐️⭐️⭐️⭐️ *[^2] | ✅ | ✅ | ✅ |
| **Ubuntu 22.04** | [![Ubuntu](https://github.com/OpenSwiftUIProject/OpenSwiftUI/actions/workflows/ubuntu.yml/badge.svg)](https://github.com/OpenSwiftUIProject/OpenSwiftUI/actions/workflows/ubuntu.yml) | ⭐️⭐️ *[^3] | ✅ | ✅ | ❌ |
| **Windows** | None | Not supported yet | ❌ | ❌ | ❌ |


[^1]: AppKit intergration is partly implemented. Render is support via SwiftUI's render implementation. Other UI framework backend is not intergrated yet.

[^2]: UIKit intergration is partly implemented. Render is support via SwiftUI's render implementation.

[^3]: Build and test is supported. But some feature is cut due to known Swift compiler issue.

[^4]: Build is supported. Test is not supported yet dut to upstream issue.

> [!NOTE]
> The cross-platform OpenAttributeGraph is not fully implemented.
>
> It is only API compatible with AttributeGraph now.
>
> So most of the core feature is only available on Apple platform built with
> AttributeGraph varient.

### Current supported feature

- Color/Image/Path rendering (Text is not supported yet)
- Layout system
- Animation system
- onAppear/onDisappear modifier
- Basic geometry effect

## Products

- OpenSwiftUI
    - A SwiftUI source compatibility framework.
- OpenSwiftUIExtension
    - Extensive API collections for OpenSwiftUI & SwiftUI.
- OpenSwiftUIBridge
    - A bridge layer for migrating other DSL framework to OpenSwiftUI incrementally and mixing them freely.

## Disclaimer

SwiftUI is a trademark of Apple Inc. This project is not affiliated with, endorsed by, or connected to Apple Inc. in any way. OpenSwiftUI is an independent open-source implementation created for educational and research purposes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

For third-party licenses and acknowledgements, see [CREDITS.md](CREDITS.md).

## Star History

<a href="https://star-history.com/#OpenSwiftUIProject/OpenSwiftUI&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=OpenSwiftUIProject/OpenSwiftUI&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=OpenSwiftUIProject/OpenSwiftUI&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=OpenSwiftUIProject/OpenSwiftUI&type=Date" />
  </picture>
</a>
