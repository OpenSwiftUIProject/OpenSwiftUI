---
name: openswiftui-test-authoring
description: Route OpenSwiftUI test authoring and review work to the appropriate test guide while applying shared test-file conventions. Use for unit, compatibility, symbol-dual, or UI tests.
---

# OpenSwiftUI Test Authoring

## Testing and Verification

- Do not write tests for reversible, low-impact changes that only mirror the
  implementation. Add tests when they provide meaningful and necessary
  verification of observable behavior, boundaries, failures, or regression risks.
- Run the narrowest relevant tests permitted by `AGENTS.md` and complete required
  checks. Once those pass, broaden or repeat testing only when new changes,
  failures, or unresolved concerns justify it; otherwise, continue toward
  completing the task.

## Shared Conventions

- Follow the organization and naming of the nearest tests in the same target.
- Sort unconditional imports and conditional import blocks alphabetically by
  imported module name, treating each block as one unit. Use the first import
  in the block's first branch as its sort key.
- Group mutually exclusive imports in one `#if` / `#elseif` / `#else` block.
  Never split the block or reorder its branches to alphabetize individual
  imports. Preserve its conditions, fallback behavior, and import attributes.
- Mark suites/tests that contain AI-generated Swift Testing tests with `.tags(.aigc)`
  on `@Suite` or `@Test`. Also add `import OpenSwiftUITestsSupport` if not imported yet.
- In Swift Testing, prefer `@Test(arguments:)` when cases share the same test
  body. Keep different behaviors in separate tests.
- Give argument collections explicit types when inference is ambiguous,
  especially tuple elements with integer literals or empty collections. A test
  parameter type does not necessarily constrain the macro's argument expression;
  use a typed fixture or values such as `UInt64(0b0011)` when needed.
- Start each new Swift test file with this header, substituting the actual file
  name and the actual test target name:

  ```swift
  //
  //  <FileName.swift>
  //  <TestTargetName>

  ```

  Leave one blank line after the target name. Do not add a closing decorative
  `//` line, and do not copy a target name from an unrelated example.

## Conditional Import Blocks

For example, the following blocks sort by `Darwin`, `OpenCombine`, and `UIKit`,
respectively, not by modules in their alternative branches. `Foundation` belongs
after the entire Darwin/Glibc block, never between its branches:

```swift
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#else
#error("Unsupported platform")
#endif
```

```swift
#if OPENSWIFTUI_OPENCOMBINE
import OpenCombine
#else
import Combine
#endif
```

```swift
#if os(iOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
```

## Test-Type Guides

Read only the guide that matches the requested test type:

- Unit tests: [unit-tests.md](references/unit-tests.md)
- Compatibility tests: [compatibility-tests.md](references/compatibility-tests.md)
- Symbol-dual tests: [symbol-dual-tests.md](references/symbol-dual-tests.md)
- UI tests: [ui-tests.md](references/ui-tests.md)
