<!-- Use this template for Tuist version upgrades. -->

## Tracking issue

Closes #

## Version

- Current:
- Target:
- Upstream release or pull request:

## Summary

<!-- Summarize the adopted upstream changes and why OpenSwiftUI needs them. -->

## Compatibility and generated-project changes

<!-- Describe observed manifest, build-setting, generated-project, or migration changes. -->

## Change checklist

- [ ] Update the Tuist pin in `mise.toml`.
- [ ] Update the Tuist pin in `mise.compute.toml`.
- [ ] Review scripts, workflows, and documentation for version-specific behavior.
- [ ] Remove superseded workarounds when the minimum supported Tuist version allows it.

## Validation

- [ ] Confirm `mise exec -- tuist version` reports the target version.
- [ ] Confirm `mise --env compute exec -- tuist version` reports the target version.
- [ ] Generate the default Example project with `Example/setup.sh`.
- [ ] Generate the Compute Example project with `Example/setup.sh --compute`.
- [ ] Build or test the generated projects affected by the upstream changes.

## Validation evidence

<!-- List the commands run and link or summarize relevant generated-project diffs and logs. -->
