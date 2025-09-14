# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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
3. **OpenSwiftUI**: Main public API layer, SwiftUI-compatible interface
4. **OpenSwiftUIExtension**: Additional APIs extending OpenSwiftUI/SwiftUI
5. **OpenSwiftUIBridge**: Bridge layer for migrating from other frameworks

### Key Source Directories

- `Sources/OpenSwiftUICore/`: Core implementation (Animation, Layout, Graphics, etc.)
- `Sources/OpenSwiftUI/`: Public API layer matching SwiftUI
- `Sources/OpenSwiftUI_SPI/`: Low-level system interfaces and utilities
- `Sources/COpenSwiftUI/`: C/Objective-C interop code
- `Tests/`: Comprehensive test suites for all modules
- `Example/`: Demo applications and UI tests

### Testing Framework

The project uses **swift-testing framework** (not XCTest):
- Import with `import Testing`
- Use `@Test` attribute for test functions
- Use `#expect()` for assertions instead of XCTest assertions
- No comments in test case bodies - keep tests clean and self-explanatory
- For floating-point comparisons, use `isApproximatelyEqual` instead of `==` to handle precision issues:
  ```swift
  #expect(value.isApproximatelyEqual(to: expectedValue))
  ```

### Compatibility Tests

When writing tests in `OpenSwiftUICompatibilityTests`:
- **DO NOT add conditional imports** - imports are handled in `Export.swift`
- **NEVER use module-qualified types** (e.g., `SwiftUI.PeriodicTimelineSchedule`)
- Write test code that works identically with both SwiftUI and OpenSwiftUI
- Simply use types directly without any module prefixes:
  ```swift
  // No conditional imports needed - Export.swift handles this
  let schedule = PeriodicTimelineSchedule(from: startDate, by: interval)
  let entries = schedule.entries(from: queryDate, mode: .normal)
  ```

### Code Style (from .github/copilot-instructions.md)

- Use `package` access level for cross-module APIs
- 4-space indentation, trim trailing whitespaces
- Use `// MARK: -` to separate code sections
- Maximum line length: 120 characters (soft limit)
- Follow SwiftUI API compatibility patterns
- Prefix internal types with `_` when mirroring SwiftUI internals

### Platform Support

- **Darwin Platforms**: Currently only iOS and macOS are supported
- **Linux**: Build and test support, some features limited
- **Windows**: Not yet supported

### Development Configurations

For the Example app:
- `SwiftUIDebug`: Run with Apple's SwiftUI
- `OpenSwiftUIDebug`: Run with OpenSwiftUI implementation

## Environment Configuration

The Package.swift heavily uses environment variables for conditional compilation:
- Most features are platform-dependent (Darwin vs non-Darwin)
- Development mode enables additional debugging features
- Library evolution mode generates .swiftinterface files
- Various private framework integrations can be toggled

## Git and GitHub Workflow

**IMPORTANT: This project uses GitBulter for version control management**

### Critical Git Rules
- **NEVER change branches** - The user manages branches through GitBulter
- **NEVER run git commit commands** - The user commits through GitBulter GUI
- **ALWAYS create pull requests** using `gh pr create` with the exact branch specified by the user
- **DO NOT switch branches** when creating pull requests

### Commit Workflow
When asked to commit changes:
1. **Generate a commit message** and provide it to the user (formatted without extra spaces)
2. **Save the commit message** to `.claude/tmp/commit-message.md` for easy copying
3. **List the files to be committed** (specify if not all files)
4. **Let the user commit through GitBulter GUI** - do not run git commit commands
5. Wait for user confirmation before proceeding with any PR creation

Example response when asked to commit:
```
Here's the commit message for you to use in GitBulter:

"Add feature X to improve Y

- Implemented new functionality
- Updated tests
- Fixed related issues"

Files to commit:
- src/feature.swift
- tests/feature_test.swift

(Saved to .claude/tmp/commit-message.md)
```

### Pull Request Workflow
1. Only create PR after user confirms the commit is done
2. Use `gh pr create` from the specified branch
3. Do not change HEAD or switch branches during PR creation

## Important Notes

- This project uses private Apple APIs and frameworks - NOT for App Store distribution
- SwiftUI compatibility is the primary goal - match Apple's API signatures exactly  
- The project requires Swift 6.1.2+ and specific platform versions
- Cross-platform support relies on custom implementations of Apple frameworks