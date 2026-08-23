# Unit Tests

## Scope

- Put the test in the existing target that owns the API or behavior, mirroring the
  nearby source and test organization.
- Follow the nearest target's test framework, imports, availability guards, and
  SPI or `@testable` usage. Import internal access only when the behavior under
  test requires it.
- Keep each test focused on one behavior or a closely related boundary set.

## Assertions

- Put the value produced by the behavior under test on the left side of an
  assertion. Prefer a fixed, immediately readable expected value on the right,
  such as a literal, enum case, collection, `nil`, or Boolean.
- Do not calculate the expected value through another implementation of the same
  behavior. A small transparent operation on a fixed value is acceptable when it
  expresses a boundary directly.
- For round-trip or algebraic properties, assert the property and also check the
  important observable result against fixed values.
- Table-driven tests are appropriate when expected columns contain explicit
  values and only the actual-value path exercises the implementation.

## Fixtures and Verification

- Use the smallest fixtures that make the behavior clear. Control only sources of
  nondeterminism that can affect the result.
- Run `git diff --check` and the narrowest relevant
  `swift test --filter <SuiteName>` permitted by `AGENTS.md`.
