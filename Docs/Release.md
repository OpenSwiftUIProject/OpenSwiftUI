# Releases

OpenSwiftUI releases are published from immutable semantic-version tags. A tag
push matching `[0-9]*.[0-9]*.[0-9]*` starts both the `Release` workflow and the
`Documentation` workflow.

## Branch and Tag Model

- `main` contains ongoing development.
- `release/<major>.<minor>` preserves a release line when it must be maintained
  independently from `main`.
- Multiple release branches can coexist. Apply a maintenance fix to the oldest
  supported branch that needs it, validate that branch, and create a new tag at
  the reviewed commit.
- Published release tags are immutable. Never move an existing remote tag; use
  a new patch version instead.

Create a release branch from an exact reviewed commit rather than from an
unresolved branch name:

```bash
RELEASE_BRANCH=release/0.20
RELEASE_COMMIT=<reviewed-commit>

git fetch origin main --tags
git branch "$RELEASE_BRANCH" "$RELEASE_COMMIT"
git show --no-patch "$RELEASE_BRANCH"
```

For a historical line, anchor the branch at the last published tag in that
line unless a later maintenance commit was explicitly selected.

## Documentation Version Policy

The published documentation contains `main` and the highest patch from each of
the two newest `major.minor` release series. Patch releases replace the earlier
patch from the same series in the selector. A new release series moves the
two-series window forward automatically.

This changes only the assembled GitHub Pages site. Previously published OCI
documentation caches remain immutable in GHCR, so a superseded patch does not
need to be rebuilt or deleted.

The Documentation workflow always checks out `main` before assembling the site,
even when the triggering tag points to a maintenance branch. The new tag is
discovered from the complete fetched tag history and built from its own exact
source commit.

## Preflight

Before publishing a tag:

1. Confirm the release branch and reviewed commit are exact and the worktree is
   clean.
2. Confirm the version is absent locally and on the remote.
3. Run the required macOS, iOS, compatibility, Ubuntu, and renderer checks.
4. Create the candidate tag locally at the reviewed commit.
5. Run the VersionedDocC release preflight from a clean `main` checkout as
   described in [Documentation.md](Documentation.md#release-preflight).
6. Confirm the signing and binary-repository secrets required by
   `.github/workflows/release.yml` are available.

Check that the tag does not already exist:

```bash
RELEASE_VERSION=0.20.2

git tag --list "$RELEASE_VERSION"
git ls-remote --tags origin "refs/tags/$RELEASE_VERSION"
```

Both commands must produce no matching tag. Then create the local candidate
tag and verify its target:

```bash
RELEASE_VERSION=0.20.2
RELEASE_COMMIT=<reviewed-commit>

git tag "$RELEASE_VERSION" "$RELEASE_COMMIT"
test "$(git rev-parse "$RELEASE_VERSION^{commit}")" = \
    "$(git rev-parse "$RELEASE_COMMIT^{commit}")"
git show --no-patch "$RELEASE_VERSION"
```

Do not push until every preflight check succeeds. If the candidate belongs to
one of the two newest release series, confirm that it appears in
`.docs/build/versioned-site/OpenSwiftUI/versions.json` and that the API Changes
page contains the expected adjacent comparison.

## Publish

Push the release branch first when it is new. The local tag should already be
the exact candidate validated by preflight:

```bash
RELEASE_BRANCH=release/0.20
RELEASE_VERSION=0.20.2
RELEASE_COMMIT=<reviewed-commit>

test "$(git rev-parse "$RELEASE_VERSION^{commit}")" = \
    "$(git rev-parse "$RELEASE_COMMIT^{commit}")"
git push origin "$RELEASE_BRANCH"
git push origin "refs/tags/$RELEASE_VERSION"
```

The tag starts two independent workflows:

- `Release` builds and signs XCFrameworks, creates the GitHub release, updates
  `OpenSwiftUI-spm`, and generates release notes.
- `Documentation` restores existing version caches, builds only cache misses,
  publishes eligible immutable release caches to GHCR, assembles the versioned
  site, and deploys it to GitHub Pages.

Monitor both workflows. A release is complete only after all of the following
succeed:

- signed release assets and release notes;
- the matching `OpenSwiftUI-spm` tag and binary Example CI;
- the Documentation workflow and Pages deployment;
- the expected version selector and API Changes comparison when the release is
  inside the two-series documentation window; and
- publication or confirmed reuse of the release's OCI documentation cache.

## Maintenance Releases

Make fixes on the applicable release branch without merging unrelated `main`
changes. Validate the resulting commit and publish a new semantic-version tag.

A maintenance release in either of the two newest release series replaces the
previous patch from that series in the documentation selector. A release from
an older series still produces normal release assets, but is not added to the
documentation selector unless the checked-in VersionedDocC policy is
intentionally changed.

If a workflow fails because of infrastructure, retry the failed job first.
Deleting or recreating a remote tag is a last resort and requires explicit
approval after confirming that consumers have not resolved it.
