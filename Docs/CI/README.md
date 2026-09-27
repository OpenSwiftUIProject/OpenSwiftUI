# Optional CI workflows

UI tests, interaction tests, compatibility tests, and Stdout Renderer run through manual dispatch, a trusted PR comment, or the shared pre-release workflow. Pushes and pull request updates do not run these workflows automatically.

## PR comments

Post one command in a new PR comment:

| Workflow | Command | Default selection |
| --- | --- | --- |
| [UI tests](UITest.md) | `/uitest [platform] [configuration] [update]` | iOS and macOS, default configurations |
| interaction tests | `/interactiontest [platform] [configuration] [update] [only-testing=<identifier>]` | iOS and macOS, default configurations |
| Compatibility tests | `/compatibilitytest [all\|ios\|macos]` | iOS and macOS |
| Stdout Renderer | `/stdout-renderer [all\|attributegraph\|compute]` | AttributeGraph and Compute on macOS, Compute on Linux |

Examples:

```text
/interactiontest
/interactiontest ios
/interactiontest macos
/interactiontest ios osui-iag update
/interactiontest macos all-configs only-testing=OpenSwiftUIInteractionTests/TapGestureInteractionTests
/compatibilitytest
/compatibilitytest ios
/compatibilitytest macos
/stdout-renderer
/stdout-renderer compute
/stdout-renderer attributegraph
```

Only comments from repository owners, members, and collaborators are accepted. Ordinary issue comments and unsupported commands do not run the checks. All commands require an open PR. Compatibility and Stdout Renderer commands accept at most one target. Platform, target, and configuration names are case-insensitive; test identifiers retain their case.

The workflows check out the PR head commit resolved when the command is accepted. Same-repository PRs receive pending and final commit statuses for each selected target:

- `Interaction Tests / iOS / <configuration>`
- `Interaction Tests / macOS / <configuration>`
- `Compatibility tests / iOS`
- `Compatibility tests / macOS`
- `Stdout Renderer / macOS / AttributeGraph`
- `Stdout Renderer / macOS / Compute`
- `Stdout Renderer / Linux / Compute`

The `compute` and `all` selections include the Linux stdout example. Linux uses
the source Compute package in the official Swift 6.3.3 container.

As with UI tests, fork PRs can run after a trusted comment, but do not receive commit statuses. Open the workflow run to see their results.

New comment commands become available after their workflow changes reach the default branch. See [GitHub's issue comment event documentation](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#issue_comment).

## Manual dispatch

Use the GitHub Actions **Run workflow** control or the GitHub CLI:

```shell
gh workflow run interaction_tests.yml --ref main -f platform=all
gh workflow run interaction_tests.yml --ref main -f platform=ios
gh workflow run interaction_tests.yml --ref main -f platform=ios -f configuration=openswiftui-renderer-iag -f update_reference=true -f 'only-testing=OpenSwiftUIInteractionTests/TapGestureInteractionTests'
gh workflow run compatibility_tests.yml --ref main -f platform=all
gh workflow run compatibility_tests.yml --ref main -f platform=ios
gh workflow run stdout_renderer.yml --ref main -f backend=all
gh workflow run stdout_renderer.yml --ref main -f backend=Compute
```

Manual dispatch runs the selected branch or tag. UI and interaction tests use the same dispatch inputs and configuration aliases described in [UI Test CI](UITest.md).

## interaction tests

Each selected platform runs `OSUI_InteractionTests` against persistent SnapshotTesting
reference images. Only `update` or `update_reference=true` runs `SUI_InteractionTests`
first to record references. Use update for the first run and when expected
images change. Missing references fail verification without starting SwiftUI.

interaction tests share UI test command parsing, configuration matrices, reference
storage, recording locks, and failure collection. The default configurations
are `swiftui-renderer-ag` and `openswiftui-renderer-iag`; `all-configs` selects
all four renderer and graph combinations. Compute uses `mise.compute.toml`.
The same `only-testing` identifier applies to recording and verification.
Selected runs append ` / Selected` to their commit status context and cannot
report a full-suite `verified-sha`.

SnapshotTesting reports recording issues as test failures. CI accepts exit
status 65 from SwiftUI only when every failure is a recording issue and
reference images exist. A successful interaction test without snapshots does
not need to produce images. Other recording failures stop verification.
Missing results, zero executed tests, and skipped-only selections fail the
check. Test execution is serial. Failed runs upload logs, snapshot differences,
and zipped `.xcresult` bundles for seven days; temporary build files are removed.

Other workflows can call `.github/workflows/interaction_tests.yml` with a full commit SHA
in `ref`, plus `platform`, `configuration`, `update_reference`, and
`only-testing`. The `verified-sha` output is set only when full suites pass on
both platforms at the same commit.

## Pre-release checks

Run all regular and optional checks on one commit with:

```shell
gh workflow run release_checks.yml --ref main
```

This runs macOS, iOS, Ubuntu, all UI and interaction test configurations on both platforms,
compatibility tests on both platforms, both Stdout Renderer backends on macOS,
and the Compute Stdout Renderer on Linux.
The standalone workflow creates no tag or release. Version tag pushes start
the release entry, which calls the same checks before building signed artifacts
and publishing. Manual release requests run these checks by default and can
create the version tag after the signed build succeeds.
See [Releases](../Release.md) for setup, publication, and retry instructions.
