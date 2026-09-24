# Optional CI workflows

UI tests, UX tests, compatibility tests, and Stdout Renderer run through manual dispatch, a trusted PR comment, or the shared pre-release workflow. Pushes and pull request updates do not run these workflows automatically.

## PR comments

Post one command in a new PR comment:

| Workflow | Command | Default selection |
| --- | --- | --- |
| [UI tests](UITest.md) | `/uitest [platform] [configuration] [update]` | iOS and macOS, default configurations |
| UX tests | `/uxtest [all\|ios\|macos]` | iOS and macOS |
| Compatibility tests | `/compatibilitytest [all\|ios\|macos]` | iOS and macOS |
| Stdout Renderer | `/stdout-renderer [all\|attributegraph\|compute]` | AttributeGraph and Compute on macOS, Compute on Linux |

Examples:

```text
/uxtest
/uxtest ios
/uxtest macos
/compatibilitytest
/compatibilitytest ios
/compatibilitytest macos
/stdout-renderer
/stdout-renderer compute
/stdout-renderer attributegraph
```

Only comments from repository owners, members, and collaborators are accepted. Ordinary issue comments and unsupported commands do not run the checks. The UX, compatibility, and Stdout Renderer commands require an open PR and accept at most one target. Their target names are case-insensitive.

The workflows check out the PR head commit resolved when the command is accepted. Same-repository PRs receive pending and final commit statuses for each selected target:

- `UX Tests / iOS`
- `UX Tests / macOS`
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
gh workflow run uxtests.yml --ref main -f platform=all
gh workflow run uxtests.yml --ref main -f platform=ios
gh workflow run compatibility_tests.yml --ref main -f platform=all
gh workflow run compatibility_tests.yml --ref main -f platform=ios
gh workflow run stdout_renderer.yml --ref main -f backend=all
gh workflow run stdout_renderer.yml --ref main -f backend=Compute
```

Manual dispatch runs the selected branch or tag. See [UI Test CI](UITest.md) for its dispatch inputs and configuration aliases.

## UX tests

Each selected platform runs `SUI_UXTests` first, then `OSUI_UXTests`. Both use
the same interaction tests in `OpenSwiftUIUXTests`. The OpenSwiftUI configuration
uses the OpenSwiftUI renderer with Compute (IAG), pinned by `mise.compute.toml`.
UX tests do not record snapshot reference images or offer renderer selection.

Both schemes run even if the first fails. A test failure or zero executed tests
in either scheme fails the platform check. Test execution is serial, and each
scheme has a separate DerivedData directory. Logs and `.xcresult` bundles are
uploaded for seven days after successful and failed runs.

Other workflows can call `.github/workflows/uxtests.yml` with a full commit SHA
in `ref` and `platform: all`, `ios`, or `macos`. The `verified-sha` output is set
only when both platforms pass on the same commit.

## Pre-release checks

Run all regular and optional checks on one commit with:

```shell
gh workflow run release_checks.yml --ref main
```

This runs macOS, iOS, Ubuntu, all UI test configurations on both platforms,
UX and compatibility tests on both platforms, both Stdout Renderer backends on macOS,
and the Compute Stdout Renderer on Linux.
The standalone workflow creates no tag or release. Version tag pushes start
the release entry, which calls the same checks before building signed artifacts
and publishing. Manual release requests run these checks by default and can
create the version tag after the signed build succeeds.
See [Releases](../Release.md) for setup, publication, and retry instructions.
