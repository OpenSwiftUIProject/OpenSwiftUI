# OpenSwiftUI Copilot Test Authoring Rules

This file documents precise rules and templates for writing Tests and DualTests used across the OpenSwiftUI repository. Follow these rules exactly when generating new test cases.

## General principles
- Use the `swift-testing` framework and the `#expect` macro for all assertions.
- Do NOT use XCTest unless explicitly required for compatibility.
- Keep test function bodies free of comments.
- Use descriptive test function names (do not prefix with `test`).
- Use `@Test` for each test function.
- Group related tests with `// MARK: -`.
- Keep tests small and focused.
- Use `package` / access-level rules only inside implementation files — tests import the target.

## File layout and naming
- Test filenames should end with `Tests.swift`.
- Put project-only tests in `Tests/*Tests`.
- Put dual tests that compare against SwiftUI in `Tests/*SymbolDualTests`.
- Use `struct <FeatureName>Tests { ... }` to group tests.

## Test file headers and conditions

Project-only tests (call OpenSwiftUI APIs):
- Use compile condition matching the implementation (example: `#if os(iOS) && canImport(QuartzCore)`).
- Required imports:
  - `import Testing`
  - `@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore` (if testing internal SPI)
  - platform framework imports (e.g., `import QuartzCore`)

DualTests (call into SwiftUI symbol via stub):
- Use a condition that ensures SwiftUI is available and matches the reference SDK:
  - Example: `#if os(iOS) && canImport(SwiftUI, _underlyingVersion: 6.5.4)`
- Required imports:
  - `import QuartzCore`
  - `import Testing`
- Provide a `@_silgen_name` initializer (or function) declaration on the type to call the SwiftUI symbol:
  - Example:
    extension CAFrameRateRange {
        @_silgen_name("OpenSwiftUITestStub_CAFrameRateRangeInitInterval")
        init(swiftUI_interval: Double)
    }
- Provide a C stub that publishes the SwiftUI symbol name for the test bundle (placed in SymbolDualTestsSupport target). The C file must define the same symbol name used in `@_silgen_name`.

## Test implementation rules
- Use `@Test(arguments: [...])` to run parameterized cases when appropriate.
- Argument arrays must be typed where necessary (e.g., `as [(Double, CAFrameRateRange)]`).
- In each `@Test` function:
  - Instantiate or call the API under test.
  - Use `#expect(...)` for every assertion.
  - Do not include comments inside the test function body.
- Use exact equality checks where types are Equatable (e.g., `#expect(range == expected)`).

## Small templates

Project test template:
```swift
// ... file header and #if condition ...
import Testing
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
import QuartzCore

struct <FeatureName>Tests {
    @Test(arguments: [
        // example tuples
    ] as [(/* types */)])
    func <scenario>(/* params */) {
        let result = /* call OpenSwiftUI API */
        #expect(result == expected)
    }
}
```

Dual test template:
```swift
// ... file header and #if condition ...
import QuartzCore
import Testing

extension <TypeUnderTest> {
    @_silgen_name("<C stub symbol name>")
    init(swiftUI_<param>: /* type */)
}

struct <FeatureName>DualTests {
    @Test(arguments: [
        // example tuples
    ] as [(/* types */)])
    func <scenario>(/* params */) {
        let result = <TypeUnderTest>(swiftUI_<param>: input)
        #expect(result == expected)
    }
}
```

C stub template (SymbolDualTestsSupport target):
```c
// Provide a C stub that resolves to the SwiftUI initializer/function
// Use the same symbol name used in @_silgen_name in the DualTest
#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_IOS

#import <SymbolLocator.h>

DEFINE_SL_STUB_SLF(<C stub symbol name>, SwiftUICore, <mangled SwiftUI symbol>);

#endif
```

## Examples and important notes
- Do not include test-comments in function bodies.
- Keep parameterized arguments typed explicitly when the compiler cannot infer them.
- Match the platform compile conditions to the implementation file being tested.
- When comparing framework-provided types (e.g., `CAFrameRateRange`) rely on their Equatable conformance using `==`.
- Ensure the C stub symbol name and the `@_silgen_name` string are identical.

## Checklist before committing test code
- [ ] Uses `Testing` and `#expect` exclusively.
- [ ] No comments inside `@Test` function bodies.
- [ ] Proper compile-time conditions are present.
- [ ] DualTests have matching C stubs in the SymbolDualTestsSupport target.
- [ ] Test file and struct names follow repository conventions.
