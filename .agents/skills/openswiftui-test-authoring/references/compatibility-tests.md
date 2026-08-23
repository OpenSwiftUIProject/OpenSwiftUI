# Compatibility Tests

Follow `Tests/OpenSwiftUICompatibilityTests/README.md` and nearby tests.

## Coverage

- Test public API behavior shared by OpenSwiftUI and SwiftUI. Do not use private
  SPI, `@testable`, or symbol-location stubs in this target.
- Let the target's exported imports select OpenSwiftUI or SwiftUI. Keep the test
  body common to both configurations instead of importing either framework in
  each test file.
- State the shared expected behavior directly. Avoid framework-specific branches
  unless availability or a documented platform constraint requires one.
- Add availability guards only as narrowly as the public API requires.

## Verification

- Run `git diff --check`.
- When verification is requested, run the narrowest relevant test in both the
  default OpenSwiftUI configuration and the `OPENSWIFTUI_COMPATIBILITY_TEST=1`
  configuration, following `AGENTS.md`.
