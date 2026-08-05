# Documentation

OpenSwiftUI publishes versioned Swift-DocC documentation with
[VersionedDocC](https://github.com/DocCLab/VersionedDocC).

- Development documentation:
  <https://openswiftuiproject.github.io/OpenSwiftUI/main/documentation/openswiftui/>
- API changes:
  <https://openswiftuiproject.github.io/OpenSwiftUI/main/changes/>

The legacy unversioned `/OpenSwiftUI/documentation/...` routes remain usable and
redirect in the browser to the matching `main` route.

## Version Policy

The checked-in [`.vdc.json`](../.vdc.json) publishes:

- `main`, built from the current development branch;
- the highest patch tag from the newest `major.minor` release series; and
- the highest patch tag from the preceding `major.minor` release series.

For example, tags `0.19.0`, `0.19.2`, `0.20.0`, and `0.20.1` produce the
selector `main`, `0.20.1`, and `0.19.2`. A later `0.20.2` replaces `0.20.1`
in the published site. A new `0.21.0` moves the window to `0.21.0` and
`0.20.2` without requiring a configuration edit.

Only the selected versions are assembled into GitHub Pages. Superseded release
caches remain immutable and may still exist locally or in GHCR.

## CI Deployment

The [Documentation workflow](../.github/workflows/documentation.yml) runs for a
semantic-version tag push or an explicit `workflow_dispatch` invocation. It
always checks out `main` with complete tag history. This is intentional: the
site's `main` entry must represent the development branch even when a tag was
created from a maintenance branch.

The workflow:

1. Selects the configured Xcode version on the self-hosted macOS runner.
2. Runs `Scripts/CI/darwin_setup_build.sh` to prepare sibling dependencies.
3. Checks out the custom DocC renderer from
   `OpenSwiftUIProject/swift-docc-render-artifact@release/6.3-colorful`.
4. Restores `.docs/cache/versioned-docc` from GitHub Actions cache.
5. Authenticates ORAS with GHCR.
6. Runs `DocCLab/VersionedDocC@0.0.10`, restoring immutable release
   artifacts from GHCR, building cache misses, publishing new release artifacts,
   and assembling the versioned site.
7. Uploads `.docs/build/versioned-site/OpenSwiftUI` and deploys it with GitHub
   Pages Actions.

The repository's Pages source must be **GitHub Actions**. The `github-pages`
environment must allow semantic-version tags and `main` for manual deployments,
or have no branch and tag restriction.

## Local Versioned Preview

`Scripts/preview-documentation.sh` is the canonical local entry point. It
enables the opt-in VersionedDocC SwiftPM command plugin, builds cache misses,
assembles the site, and starts the VersionedDocC static preview server:

```bash
Scripts/preview-documentation.sh
```

The default is independent of ORAS and registry credentials. Useful variants
include:

```bash
# Serve an already assembled site without building
Scripts/preview-documentation.sh --no-build

# Restore configured release caches from GHCR before building misses
Scripts/preview-documentation.sh --use-oci-cache

# Reassemble an existing complete cache without invoking Swift or DocC
Scripts/preview-documentation.sh --assemble-only

# Intentionally rebuild every selected version and use another port
Scripts/preview-documentation.sh --rebuild --port 8767
```

The script also accepts `--output` and `--cache` overrides for an existing
artifact or cache location. `--no-build` requires an already assembled output;
`--assemble-only` requires a complete cache for every selected version.

To match CI precisely, use an isolated checkout, select the workflow's Xcode
and renderer, and export the renderer before invoking the script:

```bash
git fetch origin main --tags
Scripts/CI/darwin_setup_build.sh
export DOCC_HTML_DIR=/path/to/swift-docc-render-artifact/dist
Scripts/preview-documentation.sh --use-oci-cache
```

`Scripts/CI/darwin_setup_build.sh` may check out pinned revisions in sibling
dependency repositories. Do not run it from a checkout containing unrelated
dependency work.

Open
<http://127.0.0.1:8766/OpenSwiftUI/main/documentation/openswiftui/> or
<http://127.0.0.1:8766/OpenSwiftUI/main/changes/>.

VersionedDocC preview serves the assembled multi-version static site; it is not
`docc preview` and does not watch source files. Re-run the script after changing
documentation source. Publishing an OCI cache remains an explicit CI operation.

## Release Preflight

VersionedDocC discovers releases from Git tags. Before pushing a release, create
the candidate tag locally at the reviewed commit, then run the versioned build
from a clean checkout of `main`. The tag may point to a maintenance branch; the
documentation checkout itself should remain on `main` so it matches CI.

```bash
RELEASE_VERSION=0.20.2
RELEASE_COMMIT=<reviewed-commit>

git tag "$RELEASE_VERSION" "$RELEASE_COMMIT"
git show --no-patch "$RELEASE_VERSION"

Scripts/CI/darwin_setup_build.sh
export DOCC_HTML_DIR=/path/to/swift-docc-render-artifact/dist

OPENSWIFTUI_VERSIONED_DOCC_PLUGIN=1 \
swift package --disable-sandbox \
    --allow-writing-to-package-directory \
    --allow-network-connections all \
    versioned-documentation build \
    --config .vdc.json \
    --no-oci-cache
```

Verify the assembled site:

```bash
SITE_ROOT=.docs/build/versioned-site/OpenSwiftUI

test -s "$SITE_ROOT/versions.json"
test -s "$SITE_ROOT/main/index.html"
test -s "$SITE_ROOT/main/changes/index.html"
jq -e --arg version "$RELEASE_VERSION" \
    'any(.versions[]; .name == $version)' \
    "$SITE_ROOT/versions.json"
```

The final `jq` assertion applies when the candidate belongs to one of the two
newest release series. A maintenance release outside that window is valid but
is not added to the selector unless the release policy is intentionally
changed.

Warnings for unresolved documentation links do not currently fail the build.
Treat compiler errors, missing symbol graphs, DocC conversion failures, an
unexpected version list, or a missing static output as release blockers. See
[Release.md](Release.md) for the complete branch, tag, and publication process.

## Cache Model

VersionedDocC uses two complementary cache layers:

- GitHub Actions cache preserves the mutable `main` cache and release caches
  between workflow runs.
- GHCR stores independent immutable release artifacts at
  `ghcr.io/openswiftuiproject/openswiftui-docc-cache`.

A version cache is accepted only when its exact source commit and build
fingerprint match. The fingerprint covers the toolchain, renderer, package
resolution, symbol-graph policy, build environment, and other inputs that
affect the generated documentation. A new `main` commit therefore rebuilds
`main`, while unchanged release artifacts are restored instead of rebuilt.

Development documentation is not published to GHCR by default. Superseding a
patch in the selector does not delete the previous patch artifact.

## Symbol Graph Policy

The public site retains only `OpenSwiftUI` and `OpenSwiftUICore` symbols.
Re-exported system and dependency modules are removed during assembly.

VersionedDocC passes `-skip-protocol-implementations` through the Swift
frontend. Protocol-extension APIs are represented once on their declaring
protocol instead of being repeated for every conforming type. This behavior is
part of the cache fingerprint.

API Changes pages compare immutable public symbol-graph snapshots. They show
adjacent selected versions, restore Compare/Show/Search state from the URL, and
display ten changes per page as configured by `apiChanges.pageSize`.

## Low-Level and Legacy Scripts

`Scripts/build-documentation.sh` remains useful for a quick single-version
DocC build, custom target, or non-public access level. It is no longer the CI
publishing path. Common examples are:

```bash
./Scripts/build-documentation.sh --preview
./Scripts/build-documentation.sh --target OpenSwiftUICore --preview
./Scripts/build-documentation.sh --minimum-access-level internal --preview
```

`Scripts/update-gh-pages-documentation.sh` is the legacy `gh-pages` branch
deployment mechanism. Keep it only as an emergency/manual fallback; normal
publication uses the VersionedDocC GitHub Actions workflow and Pages artifact.

## Troubleshooting

### A release is missing from the selector

Confirm that complete tag history is present and the tag matches
`<major>.<minor>.<patch>`. Only the highest patch from each of the two newest
release series is selected.

### A new API is missing

Check the VersionedDocC log for the source commit and cache decision. A changed
`main` commit should invalidate its cache automatically. Use `--rebuild` only to
diagnose a suspected fingerprint or cache-validation problem.

### Documentation contains dependency symbols

Confirm `.vdc.json` still lists only `OpenSwiftUI` and `OpenSwiftUICore` under
`allowedModules`, then inspect the pruning summary in the VersionedDocC log.

### CSS or JavaScript returns 404

The publishing base path comes from `hostingBasePath: /OpenSwiftUI` in
`.vdc.json`. Do not override the artifact root: Pages must upload
`.docs/build/versioned-site/OpenSwiftUI`.

### OCI restore or publish fails

Confirm ORAS is installed and authenticated to `ghcr.io`, and that the workflow
has `packages: write`. Use `--no-oci-cache` for a deliberately offline local
build.

### Preview port is occupied

Pass another port, for example
`Scripts/preview-documentation.sh --no-build --port 8767`.

## Why GitHub Pages Instead of Swift Package Index?

Swift Package Index documentation uses `swift-docc-plugin`, which does not
provide the symbol filtering, release-cache orchestration, custom rendering,
and version comparison required by OpenSwiftUI. VersionedDocC is a separate
orchestration plugin around the Swift toolchain and DocC; it preserves that
control while publishing a conventional static GitHub Pages artifact.
