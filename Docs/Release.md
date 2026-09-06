# Releases

Use **Release / Create** to publish a stable `major.minor.patch` version. It pins
the selected branch or pushed tag's commit, runs all required checks by default,
builds and signs the XCFrameworks, then publishes those same artifacts.
It accepts versions such as `0.22.0`, without a `v` prefix or prerelease suffix.

Push a version tag to start `release_create.yml` automatically, or dispatch it
manually to create the tag after checks and the signed build succeed. Both
entries use the same pipeline and concurrency group for the version.

## Workflow Design

| Workflow | Responsibility |
| --- | --- |
| `release_checks.yml` | Run every required test workflow at one commit. Can also run independently. |
| `release_create.yml` | Handle version tag pushes and manual requests; coordinate checks and build, then verify or create the tag. |
| `release_build.yml` | Build and sign seven XCFramework archives; store them with their version, source SHA, and SHA-256 digests. |
| `release_publish.yml` | Verify stored artifacts, prepare a draft, add assets and notes, publish it, then update `OpenSwiftUI-spm`. |
| `release_notes.yml` | Update notes for an existing release. Cannot create a release or tag. |
| `documentation.yml` | Assemble and deploy versioned documentation after publication. Also supports manual dispatch. |

By default, the release gate requires all of these checks:

| Check | Coverage |
| --- | --- |
| macOS tests | Existing macOS test matrix |
| iOS tests | Existing iOS test matrix |
| Ubuntu tests | Existing Linux test matrix |
| UI tests | iOS and macOS; all four renderer and attribute graph configurations |
| Compatibility tests | iOS and macOS |
| Stdout Renderer | AttributeGraph and Compute on macOS |

Each workflow returns its checked-out commit SHA. In the default mode, a
failed, cancelled, skipped, or missing check cannot pass the gate. UI checks do
not request reference image updates. The signed build starts after the checks
pass, or when an operator explicitly skips them as described below. The tag job
always requires stored artifacts to name the candidate SHA. It also requires
matching check results unless `skip_checks` is enabled.

The publisher downloads the original build by artifact ID and verifies all
seven archive digests. It uploads only missing assets to a draft and publishes
after notes and assets are ready. `release-manifest.json` is included in the
release. The binary package uses this manifest's checksums and macros from the
same source commit. Its `main` update and version tag are pushed atomically.

The source tag is created before publication, so a publication failure can
leave a tag and a draft. For a tag push, a failed check or build also leaves the
existing tag, but no release is created. An SPM or documentation failure can
occur after the GitHub release becomes public. Resume the original run as
described below.

## Repository Setup

Tag creation and publication use the automatically provided `GITHUB_TOKEN`.
Their jobs request `contents: write`; the preparation and build jobs retain
read access. No dedicated GitHub App, `release` environment, or tag ruleset is
required.

Provide the following secrets through repository settings or organization
secrets that grant access to this repository. Keep existing credentials when
they are already configured.

| Type | Name | Purpose |
| --- | --- | --- |
| Secret | `SIGNING_CERTIFICATE_BASE_64` | Base64-encoded signing certificate in `.p12` format |
| Secret | `SIGNING_CERTIFICATE_PASSWORD` | Signing certificate password |
| Secret | `BINARY_REPO_PAT` | Token with Contents read/write access to `OpenSwiftUIProject/OpenSwiftUI-spm` |
| Optional secret | `CODECOV_TOKEN` | Coverage upload |
| Optional secret | `COPILOT_GITHUB_TOKEN` | Release note highlights |

The release entry can run as soon as the workflows are merged and the required
secrets are available. No activation variable is required. This setup does not
restrict users from creating tags or releases manually. The workflow itself
never moves or deletes an existing tag.

A tag created with `GITHUB_TOKEN` does not start tag-push workflows. The release
entry calls publication and documentation directly, so both continue in the
same run. The binary repository update uses `BINARY_REPO_PAT` because the
automatic token is limited to this repository. See GitHub's
[token event behavior](https://docs.github.com/en/actions/concepts/security/github_token).

The selected branch or tagged commit must contain these workflow definitions.
Pushing a tag on an older commit uses that commit's workflows.

## Run Pre-release Checks

For a full check without a tag, release, or signed XCFramework build:

```shell
gh workflow run release_checks.yml \
  --repo OpenSwiftUIProject/OpenSwiftUI --ref main
```

The selected branch resolves to one commit for the entire run. The summary
records the verified SHA. This checks readiness; a release request runs the
shared checks again on its own candidate commit.

## Publish a Release

To publish an exact reviewed commit, create and push its version tag:

```shell
git tag 0.22.0 COMMIT_SHA
git push origin refs/tags/0.22.0
```

Replace `COMMIT_SHA` and the example version. Lightweight and annotated tags
are supported. The push starts **Release / Create**, derives the version from the
tag name, and runs the full checks. The workflow checks the tag's commit before
tests and again before publication. It does not recreate a deleted tag or move
an existing tag. Tag deletion does not start a release. A local tag alone does
not trigger the workflow.

Tag-triggered runs cannot skip checks. After a failure, use **Re-run failed
jobs** on that run. The manual bypass below remains available when needed.

To create the tag only after validation, use manual dispatch instead.
Make sure the intended changes are on `main`, then submit the new version:

```shell
gh workflow run release_create.yml \
  --repo OpenSwiftUIProject/OpenSwiftUI --ref main -f version=0.22.0
gh run list --repo OpenSwiftUIProject/OpenSwiftUI --workflow release_create.yml
gh run watch RUN_ID --repo OpenSwiftUIProject/OpenSwiftUI
```

Replace the example version and `RUN_ID`. The Actions UI provides the same
operation through **Release / Create > Run workflow**. The branch head at
dispatch time is the candidate; later branch updates do not change it.
The workflow creates the tag with `GITHUB_TOKEN`, which does not start another
tag-push run. Publication and documentation continue in the current run.

A successful run includes the checked tag, signed assets, release notes,
matching binary package tag, and documentation deployment. Also inspect the
binary repository's Example CI, which is triggered by its own push and is
outside this workflow, and the published documentation selector.

## Skip Pre-release Checks

Set `skip_checks=true` to bypass all six pre-release test workflows for one
release request. Use this for a known failure that is accepted for the release,
or after a workflow failure has been fixed and verified separately. A nonempty
`skip_checks_reason` is required and is recorded with the requester in the run
summary. The run title also identifies releases with skipped checks.

```shell
gh workflow run release_create.yml --ref main -f version=0.22.0 \
  -f skip_checks=true \
  -f skip_checks_reason='Known UI test failure accepted for this release.'
```

For a separately verified fix, record the verification in the reason, for
example `CI fix verified in run 123456; remaining checks passed previously.`
The workflow proceeds without requiring a previous successful check run.
Signed builds, source and artifact validation, existing tag checks, publication,
the binary package update, and documentation still run.

This option is off by default. A failed check never enables it automatically.
To change a failed release request to this mode, start a new dispatch with
these inputs; rerunning an existing run keeps its original inputs. If a tag-push
run failed during checks, dispatch from `main` or the matching maintenance
branch while its head still matches the tag's commit. A different SHA is
rejected. Once signed artifacts have been stored, resume the original run to
retain those artifacts as described under retry instructions below.

## Maintenance Releases

Keep fixes for a supported series on `release/<major>.<minor>`. Create that
branch from an exact reviewed commit, or from the series' last published tag,
and ensure it contains the release workflows. Use the same entry:

```shell
gh workflow run release_create.yml \
  --repo OpenSwiftUIProject/OpenSwiftUI --ref release/0.21 -f version=0.21.1
```

For manual dispatch, the version's major and minor must match the maintenance
branch. Other branch names and tag refs are rejected. Alternatively, push the
version tag at the reviewed maintenance commit to use the automatic entry.
Existing remote tags are never moved or deleted; use a new patch version for
changed code or artifacts.

## Retry a Failed Run

Use **Re-run failed jobs** on the original run, or:

```shell
gh run rerun RUN_ID --repo OpenSwiftUIProject/OpenSwiftUI --failed
```

This retains the original source SHA and reuses successful checks and stored
build outputs. For manual dispatch without an existing tag, a failed check or
build leaves no tag. For a tag push, the tag remains and must still name the
original commit when the run resumes. A retry accepts an existing tag only if
it names that same SHA. Matching uploaded assets are reused; a digest conflict
fails without replacing them. An existing binary tag is accepted only if its
package and macros match.

Use the original run rather than a new dispatch or **Re-run all jobs** after
signed artifacts have been stored. Rebuilding signed archives can produce
different bytes and SwiftPM checksums. Build artifacts are retained for 14 days.
If they expire before publication completes, recover the original archives or
use a new version; do not replace assets or move the old tag.

If only documentation fails, rerun that job or dispatch `documentation.yml`
from `main`. The release and binary package do not need rebuilding.

## Documentation Version Policy

The public site contains `main` and the highest patch from each of the two
newest `major.minor` release series. A new patch replaces the earlier patch in
that series in the selector. Older series still produce assets but do not enter
the selector unless the version policy changes.

Documentation always checks out `main` with complete tag history, including
for maintenance releases. Each selected release is built from its tag's exact
source commit. Immutable release caches remain in GHCR when a newer patch
replaces them in the selector. See [Documentation.md](Documentation.md) for
local previews, version selection, and cache behavior.

## Validate Workflow Changes

Local checks use Node.js, Ruby, Git, actionlint, and ShellCheck. They do not
build OpenSwiftUI or contact GitHub:

```shell
node --test Scripts/CI/Tests/*.js Scripts/CI/Tests/*.mjs
shellcheck Scripts/CI/update_binary_package.sh
```

Run actionlint on changed workflows with the self-hosted runner labels allowed.
The tests cover comment dispatch, candidate checks, tag and asset conflicts,
partial publication retries, and atomic binary package pushes.
