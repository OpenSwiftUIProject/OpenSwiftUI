# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## Project Overview

OpenSwiftUI is an open source implementation of Apple's SwiftUI framework, designed to:
- Build GUI apps on non-Apple platforms (Linux, Windows)  
- Diagnose and debug SwiftUI issues on Apple platforms
- Maintain API compatibility with SwiftUI

This project is in active development and contains multiple Swift packages with extensive environment-based configuration.

## Verification Scope

- The commands below are references, not a checklist to run after every edit.
- Use source inspection and `git diff --check` for small Swift-only edits and
  implementation audits. Do not run package, Xcode, Tuist, XCFramework, or DocC
  builds by default. Run a build when the user asks for it or when a
  header/interface-affecting change needs build verification.
- For Swift-only test changes that need execution, use
  `swift test --filter <SuiteName>`. Use an Xcode scheme or simulator only when
  requested or when SwiftPM cannot exercise the change. Honor an explicit
  instruction to skip builds or tests.
- Keep throwaway probes under `/tmp`, run with `swift <file>`, rather than
  adding temporary files to `Tests/`. A probe or syntax check does not establish
  that package tests passed.
- Complete the checks required for the change. Repeat or broaden them only for
  new changes, failures, or unresolved concerns.

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

### Build a Local XCFramework Slice

Use the slice helper for a faster iPhone Simulator arm64 Release build:

```bash
# Build the OpenSwiftUICore XCFramework slice.
Scripts/build_xcframework_slice.sh osuicore
# Build the OpenSwiftUI XCFramework slice and its Core dependency.
Scripts/build_xcframework_slice.sh osui
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

## Test Authoring

Follow `.agents/skills/openswiftui-test-authoring/SKILL.md`.

## Commits and Pull Requests

Use Conventional Commits for all new commit messages and PR titles. Follow the
[contributor guide](CONTRIBUTING.md#commit-messages-and-pull-request-titles).

Follow `.agents/skills/openswiftui-pr-authoring/SKILL.md`.

For CI fixes, inspect the failing job and prepare local changes first. Present
the diff and validation results before committing or pushing, unless the user
has already explicitly authorized those actions for the fix. A request to
investigate or fix CI alone does not authorize a commit or push.

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
