# Symbol-Dual Tests

Follow `Tests/OpenSwiftUISymbolDualTests/README.md` and the nearest stub/test pair.

## Stub Pair

- Add the Swift test under `Tests/OpenSwiftUISymbolDualTests` and its C symbol stub
  under `Sources/OpenSwiftUISymbolDualTestsSupport`, preserving the corresponding
  feature path when practical.
- Confirm the exact mangled symbol and whether it belongs to `SwiftUI` or
  `SwiftUICore` before declaring the `DEFINE_SL_STUB_SLF` entry.
- Give the C stub a unique `OpenSwiftUITestStub_` name and use that exact name in
  the Swift `@_silgen_name` declaration. Keep the Swift wrapper's ABI signature
  identical to the located symbol.

## Comparison

- Exercise the OpenSwiftUI implementation and the SwiftUI stub with the same
  fixture, then compare their observable results. Comparing two computed values is
  intentional in a symbol-dual test because behavioral parity is the subject.
- Guard symbols with the narrowest framework-version or availability condition
  required by that symbol. Do not call a missing symbol and treat the resulting
  lookup failure as a behavioral mismatch.
- Keep unrelated fixed-value unit coverage in the owning unit-test target.

## Verification

- Run `git diff --check` and the narrowest relevant
  `swift test --filter OpenSwiftUISymbolDualTests` command permitted by
  `AGENTS.md`.
