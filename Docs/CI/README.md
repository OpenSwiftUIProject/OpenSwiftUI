# Optional CI workflows

UI tests, compatibility tests, and Stdout Renderer run only through manual dispatch or a trusted PR comment. Pushes and pull request updates do not run these workflows automatically.

## PR comments

Post one command in a new PR comment:

| Workflow | Command | Default selection |
| --- | --- | --- |
| [UI tests](UITest.md) | `/uitest [platform] [configuration] [update]` | iOS and macOS, default configurations |
| Compatibility tests | `/compatibilitytest [all\|ios\|macos]` | iOS and macOS |
| Stdout Renderer | `/stdout-renderer [all\|attributegraph\|compute]` | AttributeGraph and Compute on macOS |

Examples:

```text
/compatibilitytest
/compatibilitytest ios
/compatibilitytest macos
/stdout-renderer
/stdout-renderer compute
/stdout-renderer attributegraph
```

Only comments from repository owners, members, and collaborators are accepted. Ordinary issue comments and unsupported commands do not run the checks. The compatibility and Stdout Renderer commands require an open PR and accept at most one target. Their target names are case-insensitive.

The workflows check out the PR head commit resolved when the command is accepted. Same-repository PRs receive pending and final commit statuses for each selected target:

- `Compatibility tests / iOS`
- `Compatibility tests / macOS`
- `Stdout Renderer / macOS / AttributeGraph`
- `Stdout Renderer / macOS / Compute`

As with UI tests, fork PRs can run after a trusted comment, but do not receive commit statuses. Open the workflow run to see their results.

New comment commands become available after their workflow changes reach the default branch. See [GitHub's issue comment event documentation](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#issue_comment).

## Manual dispatch

Use the GitHub Actions **Run workflow** control or the GitHub CLI:

```shell
gh workflow run compatibility_tests.yml --ref main -f platform=all
gh workflow run compatibility_tests.yml --ref main -f platform=ios
gh workflow run stdout_renderer.yml --ref main -f backend=all
gh workflow run stdout_renderer.yml --ref main -f backend=Compute
```

Manual dispatch runs the selected branch or tag. See [UI Test CI](UITest.md) for its dispatch inputs and configuration aliases.
