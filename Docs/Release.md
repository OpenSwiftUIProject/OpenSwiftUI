# Releases

Use **Create release** to publish a stable `major.minor.patch` version. It pins
the selected branch's commit, runs all required checks, builds and signs the
XCFrameworks, then creates the tag and publishes those same artifacts.
It accepts versions such as `0.22.0`, without a `v` prefix or prerelease suffix.

The new entry remains disabled until the repository setup below is complete.
While `RELEASE_PIPELINE_ENABLED` is unset or not `true`, the existing tag-push
release and documentation entries remain active. Setting it to `true` enables
the new entry and disables both legacy entries.

## Workflow Design

| Workflow | Responsibility |
| --- | --- |
| `pre_release.yml` | Run every required test workflow at one commit. Can also run independently. |
| `create_release.yml` | Validate the request, coordinate checks and build, and create the tag with the release App. |
| `build_release.yml` | Build and sign seven XCFramework archives; store them with their version, source SHA, and SHA-256 digests. |
| `publish_release.yml` | Verify stored artifacts, prepare a draft, add assets and notes, publish it, then update `OpenSwiftUI-spm`. |
| `release_notes.yml` | Update notes for an existing release. Cannot create a release or tag. |
| `documentation.yml` | Assemble and deploy versioned documentation after publication. Also supports manual dispatch. |
| `release.yml` | Preserve tag-push publication during the transition, using the shared build and publication workflows. |

The release gate requires all of these checks:

| Check | Coverage |
| --- | --- |
| macOS tests | Existing macOS test matrix |
| iOS tests | Existing iOS test matrix |
| Ubuntu tests | Existing Linux test matrix |
| UI tests | iOS and macOS; all four renderer and attribute graph configurations |
| Compatibility tests | iOS and macOS |
| Stdout Renderer | AttributeGraph and Compute on macOS |

Each workflow returns its checked-out commit SHA. A failed, cancelled, skipped,
or missing check cannot pass the gate. UI checks do not request reference image
updates. The signed build starts only after the checks pass. The tag job
requires the checks and stored artifacts to name the same candidate SHA.

The publisher downloads the original build by artifact ID and verifies all
seven archive digests. It uploads only missing assets to a draft and publishes
after notes and assets are ready. `release-manifest.json` is included in the
release. The binary package uses this manifest's checksums and macros from the
same source commit. Its `main` update and version tag are pushed atomically.

The source tag is created before publication, so a publication failure can
leave a checked tag and a draft. An SPM or documentation failure can occur after
the GitHub release becomes public. Resume the original run as described below.

## Repository Setup

Complete these steps once, after merging the workflows. Keep
`RELEASE_PIPELINE_ENABLED` unset until the final step.

1. Create a dedicated GitHub App with repository **Contents: Read and write**.
   Install it on `OpenSwiftUIProject/OpenSwiftUI`. The tag job requests a token
   scoped to this repository and permission.
2. Create an environment named `release`. Allow deployments from `main` and
   the maintenance branch pattern `release/*`. Store the App's private key as
   the environment secret `RELEASE_APP_PRIVATE_KEY`. Keep this key out of
   repository secrets so unrelated jobs cannot access it.
3. Configure the following repository variables and secrets.

| Type | Name | Purpose |
| --- | --- | --- |
| Variable | `RELEASE_APP_ID` | GitHub App ID, not the installation ID |
| Secret | `SIGNING_CERTIFICATE_BASE_64` | Base64-encoded signing certificate in `.p12` format |
| Secret | `SIGNING_CERTIFICATE_PASSWORD` | Signing certificate password |
| Secret | `BINARY_REPO_PAT` | Token with Contents read/write access to `OpenSwiftUIProject/OpenSwiftUI-spm` |
| Optional secret | `CODECOV_TOKEN` | Coverage upload |
| Optional secret | `COPILOT_GITHUB_TOKEN` | Release note highlights |

4. Under **Settings > Rules > Rulesets**, create two active **tag rulesets**.
   Both target `[0-9]*.[0-9]*.[0-9]*` with no exclusions:
   - **Release tag creation**: enable **Restrict creations**. Add only the
     dedicated release App to the bypass list, with **Always allow**.
   - **Immutable release tags**: enable **Restrict updates** and
     **Restrict deletions**. Leave the bypass list empty, including the App.

   Separate rulesets let the App create tags without permission to change or
   delete them. Do not add a role or human account to the creation bypass list.
   Administrators who can edit rulesets remain responsible for these settings.
   See GitHub's
   [ruleset setup](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/creating-rulesets-for-a-repository)
   and [available rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets).
5. Enable the new entry:

```shell
gh variable set RELEASE_PIPELINE_ENABLED \
  --repo OpenSwiftUIProject/OpenSwiftUI --body true
```

From this point, request a release through the workflow. Human tag pushes and
GitHub release creation that would create a new version tag are blocked by the
creation ruleset. The flag controls workflow routing; it does not protect tags
without the rulesets. The App token creates the tag, and publication uses the
workflow's `GITHUB_TOKEN` directly. Publication does not depend on another
workflow starting from that token's events. See GitHub's
[token event behavior](https://docs.github.com/en/actions/concepts/security/github_token).

The legacy definitions remain during rollout. An App tag push can still
produce skipped legacy runs. A maintenance branch must contain the new
workflow definitions before it can use this entry.

## Run Pre-release Checks

For a full check without a tag, release, or signed XCFramework build:

```shell
gh workflow run pre_release.yml \
  --repo OpenSwiftUIProject/OpenSwiftUI --ref main
```

The selected branch resolves to one commit for the entire run. The summary
records the verified SHA. This checks readiness; a release request runs the
shared checks again on its own candidate commit.

## Publish a Release

Make sure the intended changes are on `main`, then submit the new version:

```shell
gh workflow run create_release.yml \
  --repo OpenSwiftUIProject/OpenSwiftUI --ref main -f version=0.22.0
gh run list --repo OpenSwiftUIProject/OpenSwiftUI --workflow create_release.yml
gh run watch RUN_ID --repo OpenSwiftUIProject/OpenSwiftUI
```

Replace the example version and `RUN_ID`. The Actions UI provides the same
operation through **Create release > Run workflow**. The branch head at
dispatch time is the candidate; later branch updates do not change it.
Do not create or push the version tag yourself.

A successful run includes the checked tag, signed assets, release notes,
matching binary package tag, and documentation deployment. Also inspect the
binary repository's Example CI, which is triggered by its own push and is
outside this workflow, and the published documentation selector.

## Maintenance Releases

Keep fixes for a supported series on `release/<major>.<minor>`. Create that
branch from an exact reviewed commit, or from the series' last published tag,
and ensure it contains the release workflows. Use the same entry:

```shell
gh workflow run create_release.yml \
  --repo OpenSwiftUIProject/OpenSwiftUI --ref release/0.21 -f version=0.21.1
```

The version's major and minor must match the maintenance branch. Other branch
names and tag refs are rejected. Existing remote tags are never moved or
deleted; use a new patch version for changed code or artifacts.

## Retry a Failed Run

Use **Re-run failed jobs** on the original run, or:

```shell
gh run rerun RUN_ID --repo OpenSwiftUIProject/OpenSwiftUI --failed
```

This retains the original source SHA and reuses successful checks and stored
build outputs. Before the tag exists, a failed check or build leaves no tag.
After tagging, a retry accepts the existing tag only if it names that same SHA.
Matching uploaded assets are reused; a digest conflict fails without replacing
them. An existing binary tag is accepted only if its package and macros match.

Use the original run rather than a new dispatch or **Re-run all jobs** after
tagging. Rebuilding signed archives can produce different bytes and SwiftPM
checksums. Build artifacts are retained for 14 days. If they expire before
publication completes, recover the original archives or use a new version;
do not replace assets or move the old tag.

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
