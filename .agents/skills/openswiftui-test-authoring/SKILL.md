---
name: openswiftui-test-authoring
description: Route OpenSwiftUI test authoring and review work to the appropriate test guide while applying shared test-file conventions. Use for unit, compatibility, symbol-dual, or UI tests.
---

# OpenSwiftUI Test Authoring

## Shared Conventions

- Follow the organization and naming of the nearest tests in the same target.
- Sort import declarations alphabetically by imported module name, preserving any
  attributes attached to each declaration.
- Start each new Swift test file with this header, substituting the actual file
  name and the actual test target name:

  ```swift
  //
  //  <FileName.swift>
  //  <TestTargetName>

  ```

  Leave one blank line after the target name. Do not add a closing decorative
  `//` line, and do not copy a target name from an unrelated example.

## Test-Type Guides

Read only the guide that matches the requested test type:

- Unit tests: [unit-tests.md](references/unit-tests.md)
- Compatibility tests: [compatibility-tests.md](references/compatibility-tests.md)
- Symbol-dual tests: [symbol-dual-tests.md](references/symbol-dual-tests.md)
- UI tests: [ui-tests.md](references/ui-tests.md)
