<!-- Use this template for Compute-backed IAG upgrades. -->

## Tracking issue

Closes #

## Versions

| Pin | Current | Target |
| --- | --- | --- |
| Compute binary |  |  |
| Compute source |  |  |

- Upstream release or revision:

## Summary

<!-- Summarize the adopted Compute changes and why OpenSwiftUI needs them. -->

## Behavior and compatibility changes

<!-- Describe observed ABI, deployment-target, toolchain, graph-behavior, or snapshot changes. -->

## Change checklist

- [ ] Update the Compute binary and source versions in `mise.compute.toml`.
- [ ] Update the fallback revision in `Scripts/CI/compute_setup.sh`.
- [ ] Update Compute versions pinned directly by CI workflows.
- [ ] Regenerate `Example/Tuist/Package.resolved`.
- [ ] Update documentation that names the current Compute versions or known limitations.

## Validation

- [ ] Resolve and generate the Example project with `Example/setup.sh --compute`.
- [ ] Build the affected Compute-backed OpenSwiftUI targets or XCFramework slices.
- [ ] Run the `swiftui-renderer-iag` UI test configuration on the affected platforms.
- [ ] Run the `openswiftui-renderer-iag` UI test configuration on the affected platforms.
- [ ] Review newly passing, failing, skipped, or expected-failure IAG snapshots.

## Validation evidence

<!-- List the commands run and link or summarize relevant logs, benchmarks, and snapshot comparisons. -->
