# Toolchain Bump Changelog

This page records OpenSwiftUI toolchain bump PRs and the compatibility issues
found while validating CI, package dependencies, and platform-specific tests.

| Date | OpenSwiftUI PR | Toolchain move | Notes |
| --- | --- | --- | --- |
| 2026-06-07 | [#899](https://github.com/OpenSwiftUIProject/OpenSwiftUI/pull/899) | Xcode 16.4 / Swift 6.1 to Xcode 26.3 / Swift 6.2.4 | Kept `macos-15` and iOS 18.5 while documenting the Linux compiler crash, index store, and prebuilt package workarounds. |
| 2025-11-18 | [#634](https://github.com/OpenSwiftUIProject/OpenSwiftUI/pull/634) | Initial Xcode 26 SDK support | Added SDK 26 compatibility without moving CI to iOS 26 or macOS 26 destinations. |
| 2025-05-11 | [#276](https://github.com/OpenSwiftUIProject/OpenSwiftUI/pull/276) | Swift 6.0 / Xcode 16.0 to Swift 6.1 / Xcode 16.3 | Added the temporary Linux SDK header patch for swift-corelibs-foundation#5211. |
| 2025-04-05 | [#241](https://github.com/OpenSwiftUIProject/OpenSwiftUI/pull/241) | Xcode version selector cleanup | `16.0` resolved to Xcode 16.3 in setup tooling, so CI was changed to use a precise Xcode version. |
| 2024-09-17 | [#118](https://github.com/OpenSwiftUIProject/OpenSwiftUI/pull/118) | Add Xcode 16 and Swift 6 support on macOS | Closed [#117](https://github.com/OpenSwiftUIProject/OpenSwiftUI/issues/117). Also updated Linux/Wasm Swift 6 nightly jobs and fixed several Swift 6 warnings and iOS 18 test issues. |

## Swift 6.2

OpenSwiftUI PR: [#899](https://github.com/OpenSwiftUIProject/OpenSwiftUI/pull/899)

Tracking issue: [OpenSwiftUI#869](https://github.com/OpenSwiftUIProject/OpenSwiftUI/issues/869)

Dependency PRs:

- [OpenSwiftUIProject/DarwinPrivateFrameworks#66](https://github.com/OpenSwiftUIProject/DarwinPrivateFrameworks/pull/66)
- [OpenSwiftUIProject/OpenAttributeGraph#227](https://github.com/OpenSwiftUIProject/OpenAttributeGraph/pull/227)
- [OpenSwiftUIProject/OpenRenderBox#27](https://github.com/OpenSwiftUIProject/OpenRenderBox/pull/27)

Use the following dependency section in the OpenSwiftUI PR body:

```markdown
## Dependency

- OpenSwiftUIProject/DarwinPrivateFrameworks#66
- OpenSwiftUIProject/OpenAttributeGraph#227
- OpenSwiftUIProject/OpenRenderBox#27
```

### Version Targets

- Apple platforms: Xcode 26.3 / Swift 6.2.4.
- Runner and destinations: keep the macOS runner on `macos-15`, iOS simulator
  tests on iOS 18.5, and macOS tests on macOS 15-era runners unless a workflow
  explicitly needs the newer OS.
- Linux: Swift 6.2.4 was the intended target, but OpenAttributeGraph C++ interop
  tests crash under Swift 6.2.4 on Linux. Use Swift 6.3.2 for Linux jobs that
  compile that path until the compiler bug is fixed or a smaller workaround is
  found.

### Linux Compiler Crash

OpenAttributeGraph's Ubuntu CI reproduced a Swift 6.2.4 compiler crash:

- Run: [OpenAttributeGraph job 79953619561](https://github.com/OpenSwiftUIProject/OpenAttributeGraph/actions/runs/27090679993/job/79953619561?pr=227)
- Toolchain: Swift 6.2.4 on Ubuntu 22.04.
- Symptom: `swift-frontend` failed with signal 11 while importing
  `util::InlineHeap` from `Sources/Utilities/include/Utilities/Heap.hpp`.
- No upstream Swift issue was found for this exact crash during the
  2026-06-07 audit.
- Local validation showed Swift 6.2.4 reproduces the crash and Swift 6.3.2
  builds the same path successfully.

Resolution: use Swift 6.3.2 for Linux jobs that compile OpenAttributeGraph C++
interop tests.

### Apple-Platform Index Store Crash

Swift 6.2.4 also crashes while indexing C++ interop test targets on
Apple-platform CI. The build and tests can proceed if index store generation is
disabled.

SwiftPM workaround:

```sh
swift test --disable-index-store
```

xcodebuild workaround:

```sh
xcodebuild test ... COMPILER_INDEX_STORE_ENABLE=NO
```

OpenAttributeGraph PR #227 applies both workarounds:

- `--disable-index-store` for macOS SwiftPM test jobs.
- `COMPILER_INDEX_STORE_ENABLE=NO` for iOS xcodebuild build/test jobs and the
  Example workspace setup.

### Package Prebuilts

Swift 6.2 enables SwiftPM prebuilts by default. iOS test jobs can fail when
Xcode or SwiftPM tries to resolve or use those prebuilt artifacts.

Xcode user default workaround:

```sh
defaults write com.apple.dt.Xcode IDEPackageEnablePrebuilts -bool NO
```

xcodebuild per-invocation workaround:

```sh
xcodebuild -IDEPackageEnablePrebuilts=NO ...
```

SwiftPM workaround:

```sh
swift build --disable-experimental-prebuilts
```

Force prebuilts off globally by creating the SwiftPM sentinel file:

```sh
mkdir -p ~/.swiftpm/cache/prebuilts
touch ~/.swiftpm/cache/prebuilts/noprebuilts
```

Prefer per-invocation flags in CI when the workflow owns the command line. Use
the global sentinel only when the command path is hard to thread through, such
as nested package or generated workspace invocations.

## Swift 6.1

OpenSwiftUI PR: [#276](https://github.com/OpenSwiftUIProject/OpenSwiftUI/pull/276)

Tracking issue: [OpenSwiftUI#232](https://github.com/OpenSwiftUIProject/OpenSwiftUI/issues/232)

The CI bump moved Apple-platform jobs from Xcode 16.0 to Xcode 16.3 and the
Ubuntu container from Swift 6.0.1 to Swift 6.1.0.

### Linux CoreFoundation Header Failure

Swift 6.1 exposed a Linux CoreFoundation header problem after LLVM made
`ptrauth.h` a Clang module. The Swift SDK imported `ptrauth.h` inside the
`CF_EXTERN_C_BEGIN` / `CF_EXTERN_C_END` region in `CFBase.h`, which caused the
compiler to reject the module import under C linkage:

```text
import of C++ module 'ptrauth' appears within extern "C" language linkage specification
```

Upstream context:

- Issue: [swift-corelibs-foundation#5211](https://github.com/swiftlang/swift-corelibs-foundation/issues/5211)
- Fix PR: [swift-corelibs-foundation#5212](https://github.com/swiftlang/swift-corelibs-foundation/pull/5212)

OpenSwiftUI worked around this in PR #276 by adding
`.github/scripts/fix-toolchain.sh`. The script patched the Swift SDK in the CI
container by commenting out `#include <ptrauth.h>` in `CFBase.h` before running
Linux tests.

Current status: the upstream fix is available in newer toolchains, so the
workaround was removed in the Swift 6.2 bump. Keep the removal separate from
toolchain-version changes when possible, because this makes future audits much
easier.
