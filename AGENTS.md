# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## Project Overview

OpenSwiftUI is an open source implementation of Apple's SwiftUI framework, designed to:
- Build GUI apps on non-Apple platforms (Linux, Windows)  
- Diagnose and debug SwiftUI issues on Apple platforms
- Maintain API compatibility with SwiftUI

This project is in active development and contains multiple Swift packages with extensive environment-based configuration.

## Build Commands

### Standard Build
```bash
./Scripts/build.sh
# Or directly: swift build
```

### Build with Library Evolution
```bash
./Scripts/build_swiftinterface.sh
# Generates module interfaces for library evolution
```

### Environment Variables
The build system uses many environment variables for configuration:
- `OPENSWIFTUI_BUILD_FOR_DARWIN_PLATFORM`: Build for Darwin platforms (default: true on macOS)
- `OPENSWIFTUI_DEVELOPMENT`: Enable development mode features
- `OPENSWIFTUI_USE_LOCAL_DEPS`: Use local dependency paths instead of remote repos
- `OPENSWIFTUI_LIBRARY_EVOLUTION`: Enable library evolution support
- `OPENSWIFTUI_COMPATIBILITY_TEST`: Run compatibility tests with SwiftUI

## Test Commands

### Run All Tests
```bash
swift test
```

### Run Specific Test Target
```bash
swift test --filter OpenSwiftUICoreTests
swift test --filter OpenSwiftUICompatibilityTests
swift test --filter OpenSwiftUISymbolDualTests
```

### Test with Coverage
```bash
swift test --enable-code-coverage
```

### List Available Tests
```bash
swift test --list-tests
```

## Dependencies Setup

The project requires cloning additional repositories in the same parent directory:

```bash
cd ..
git clone https://github.com/OpenSwiftUIProject/OpenAttributeGraph.git
git clone https://github.com/OpenSwiftUIProject/OpenRenderBox.git
git clone https://github.com/OpenSwiftUIProject/DarwinPrivateFrameworks.git
```

## Architecture

### Core Modules

1. **OpenSwiftUI_SPI**: System Programming Interface and low-level utilities
2. **OpenSwiftUICore**: Core framework implementation with animations, layout, graphics

--------------------------------------------------------------------------------
## Documentation

Use swift-docc format when writing documentation.

Follow SwiftUI documentation style.

Since CDDefaultCodeListingLanguage is Swift, stop using ```swift and ``` to wrap Swift code example in documentation. Instead just use a new line + 4 space indent.

Example:

```
    /// Example code:
    ///
    ///     @main
    ///     struct MyApp: App {
    ///         var body: some View {
    ///             WindowGroup {
    ///                 ContentView()
    ///             }
    ///             .environment(ProfileService.currentProfile)
    ///         }
    ///     }
    ///
    public protocol App {}
```
