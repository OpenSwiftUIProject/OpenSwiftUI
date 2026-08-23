# UI Tests

Follow the nearest test under `Example/OpenSwiftUIUITests`.

## Coverage

- Exercise public API through rendered example content. Add or change shared
  example content only when the requested UI test needs an entry point.
- Use the existing snapshot helpers, suite traits, and platform guards instead of
  introducing a parallel harness.
- Make layout, state, and timing deterministic enough that the snapshot represents
  the behavior being tested rather than incidental runtime state.
- Use `withKnownIssue` only for a specific existing limitation; do not use it to
  hide a new regression.

## References and Verification

- Do not record, replace, or delete reference images unless the user explicitly
  requests snapshot recording.
- Run `git diff --check`. Run the relevant UI-test scheme or snapshot command only
  when requested and as directed by `AGENTS.md`.
