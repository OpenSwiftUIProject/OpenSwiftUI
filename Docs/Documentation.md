# Documentation

This document explains how OpenSwiftUI's documentation is built and hosted.

## Overview

OpenSwiftUI uses Swift-DocC to generate API documentation, which is hosted on GitHub Pages at:

**https://openswiftuiproject.github.io/OpenSwiftUI/documentation/openswiftui/**

The documentation is built from the `OpenSwiftUI` target and includes symbols from `OpenSwiftUICore` via `@_exported import`. System framework symbols (CoreFoundation, CoreGraphics, etc.) are filtered out to keep the documentation focused on OpenSwiftUI's own APIs.

## CI Deployment

Documentation is built and published by `.github/workflows/documentation.yml`.
The workflow deploys to GitHub Pages when a version tag like `0.18.3` is pushed,
or when the workflow is run manually from the Actions tab.

The workflow:

1. Checks out the repository on a macOS runner.
2. Selects the project Xcode version.
3. Runs `Scripts/CI/darwin_setup_build.sh` so local package dependencies match
   the rest of the macOS CI environment.
4. Shallow-clones `OpenSwiftUIProject/swift-docc-render-artifact` at
   `release/6.3-colorful` and exports its `dist/` directory as `DOCC_HTML_DIR`.
5. Builds the static DocC site with
   `Scripts/build-documentation.sh --clean --hosting-base-path /OpenSwiftUI`,
   with source links pointing at the triggering tag or manual workflow ref.
6. Uploads `.docs/build/docc-output` with `actions/upload-pages-artifact`.
7. Deploys the uploaded artifact with `actions/deploy-pages`.

**GitHub Pages settings:**
- **Source:** GitHub Actions
- **Environment:** `github-pages`

GitHub repository setup:

1. Open the repository on GitHub.
2. Go to **Settings > Pages**.
3. Under **Build and deployment**, set **Source** to **GitHub Actions**.
4. Go to **Settings > Environments > github-pages**.
5. Under **Deployment branches and tags**, either choose **No restriction**, or
   choose **Selected branches and tags** and add:
   - tag pattern `[0-9]*.[0-9]*.[0-9]*`
   - branch pattern `main` if you want manual `workflow_dispatch` deployments
     from the default branch

## Documentation Scripts

Two scripts are provided for documentation management:

### `Scripts/build-documentation.sh`

Builds documentation locally with optional preview server.

**Usage:**
```bash
# Build and preview documentation locally
./Scripts/build-documentation.sh --preview

# Build with internal symbols visible
./Scripts/build-documentation.sh --minimum-access-level internal

# Preview on a different port
./Scripts/build-documentation.sh --preview --port 8080

# Clean build (force regenerate symbol graphs)
./Scripts/build-documentation.sh --clean
```

**Options:**
- `--preview` - Start a local HTTP server to preview documentation
- `--port PORT` - Port for preview server (default: 8000)
- `--minimum-access-level LEVEL` - Symbol visibility: public, internal, private, fileprivate (default: public)
- `--target TARGET` - Documentation target (default: OpenSwiftUI)
- `--hosting-base-path PATH` - Base path for hosting (e.g., /OpenSwiftUI)
- `--source-service SERVICE` - Source service (github, gitlab, bitbucket)
- `--source-service-base-url URL` - Base URL for source links
- `--clean` - Clean build artifacts and force rebuild

Set `DOCC_HTML_DIR` to use a custom swift-docc-render `dist/` directory. CI
uses the renderer from
`OpenSwiftUIProject/swift-docc-render-artifact@release/6.3-colorful`. For local
preview with the same renderer, use a local checkout:

```bash
DOCC_HTML_DIR=/path/to/swift-docc-render-artifact/dist \
  ./Scripts/build-documentation.sh --preview
```

For local preview, omit `--hosting-base-path`; that option is only applied to
static builds for GitHub Pages.

**Example workflow:**
```bash
# Preview documentation locally before deploying
./Scripts/build-documentation.sh --preview

# Open http://localhost:8000/documentation/openswiftui in your browser
# Make changes to documentation comments in source code
# Re-run the script to see updates (uses incremental builds)
```

### `Scripts/update-gh-pages-documentation.sh`

Legacy manual deployment script. Prefer the GitHub Actions workflow for normal
publishing; this script is kept as an emergency/manual fallback.

**Usage:**
```bash
# Build and deploy documentation to the legacy gh-pages branch
./Scripts/update-gh-pages-documentation.sh

# Test deployment without pushing (dry-run)
./Scripts/update-gh-pages-documentation.sh --echo-without-push

# Deploy using existing build (skip building)
./Scripts/update-gh-pages-documentation.sh --no-build

# Deploy with internal symbols
./Scripts/update-gh-pages-documentation.sh --minimum-access-level internal
```

The script defaults to `--hosting-base-path /OpenSwiftUI` because the site is served from a subdirectory. Without this setting, CSS/JS resources will fail to load.

**Options:**
- `--hosting-base-path PATH` - Base path for GitHub Pages deployment (default: `/OpenSwiftUI`)
- `--no-build` - Skip building, use existing documentation output
- `--echo-without-push` - Show push command without executing (for testing)
- `--minimum-access-level LEVEL` - Symbol visibility (default: public)
- `--clean` - Clean build artifacts and force rebuild
- `--no-force` - Don't force push (preserves gh-pages history, increases repo size)

**How it works:**
1. Builds documentation using `build-documentation.sh`
2. Creates or updates the `gh-pages` branch as a git worktree at `gh-pages/`
3. Copies documentation files to `gh-pages/docs/`
4. Commits and force-pushes to `origin/gh-pages`
5. Cleans up the worktree

**Note:** Force push is used by default to keep the repository size small by avoiding accumulation of large binary files (CSS, JS, images) in git history. Each deployment completely replaces the previous one.

## Legacy GitHub Pages Branch Layout

The legacy manual script deploys to the `gh-pages` branch with the following structure:

```
gh-pages/
├── .nojekyll          # Prevents Jekyll processing
└── docs/              # Documentation root (configured in GitHub Pages settings)
    ├── index.html
    ├── css/
    ├── js/
    ├── data/
    ├── documentation/
    └── ...
```

## Why Self-Hosted Instead of Swift Package Index?

We initially used [Swift Package Index (SPI)](https://swiftpackageindex.com) for documentation hosting, which worked well and provided excellent features like multi-version documentation picker. However, we encountered several limitations that led us to switch to self-hosted GitHub Pages:

### Limitations of SPI Documentation

SPI's documentation system is built on `swift-docc-plugin` and SwiftPM, which currently has some constraints:

1. **Binary Target Limitations** - SwiftPM has issues with binary targets in documentation builds ([swiftlang/swift-package-manager#7580](https://github.com/swiftlang/swift-package-manager/issues/7580)). We had to add `isSPIDocGenerationBuild` workarounds in `Package.swift` to exclude certain dependencies during SPI builds.

2. **Exported Symbol Handling** - SwiftPM's symbol graph generation doesn't properly handle `@_exported import` declarations ([swiftlang/swift-package-manager#9101](https://github.com/swiftlang/swift-package-manager/issues/9101)), which is essential for OpenSwiftUI's re-export architecture where `OpenSwiftUI` re-exports `OpenSwiftUICore`.

3. **Limited Customization** - The plugin-based approach doesn't provide fine-grained control over symbol filtering, documentation generation parameters, or output customization that we need for a complex project like OpenSwiftUI.

### Benefits of Self-Hosted Documentation

By self-hosting, we gain:

- **Full Control** - Direct access to Swift-DocC compiler flags and symbol graph filtering
- **Flexible Deployment** - Custom scripts tailored to OpenSwiftUI's specific needs
- **Faster Iteration** - No dependency on external service processing times
- **Symbol Filtering** - Ability to filter out re-exported system framework symbols (CoreFoundation, CoreGraphics) that would otherwise clutter the documentation
- **Custom Build Workflow** - Support for local preview, incremental builds, and testing before deployment

We appreciate the Swift Package Index team's efforts in providing documentation hosting for the Swift community. The decision to self-host is purely technical, driven by OpenSwiftUI's specific requirements and architectural constraints rather than any shortcomings of SPI itself.

## Updating Documentation

### For regular updates:

```bash
# 1. Make changes to documentation comments in source code

# 2. Preview locally
./Scripts/build-documentation.sh --preview

# 3. Verify changes at http://localhost:8000/documentation/openswiftui

# 4. Merge the documentation changes

# 5. Push a version tag such as 0.18.3, or run the Documentation workflow manually
# 6. Verify at https://openswiftuiproject.github.io/OpenSwiftUI/documentation/openswiftui/
```

### For major API changes:

The CI workflow already uses `--clean` to force symbol graph regeneration. For
local verification after adding new public APIs or changing module structure,
run:

```bash
./Scripts/build-documentation.sh --clean --preview
```

## Troubleshooting

### CSS/JS files not loading (404 errors)

**Symptom:** Documentation page loads but appears unstyled, browser console shows 404 errors for CSS/JS files.

**Cause:** Documentation was built without `--hosting-base-path /OpenSwiftUI` flag.

**Solution:** The CI workflow already passes the correct base path. For manual
local checks, rebuild with:
```bash
./Scripts/build-documentation.sh --hosting-base-path /OpenSwiftUI
```

If you use the legacy manual deployment script, keep its default
`/OpenSwiftUI` base path or pass an explicit equivalent.

### Symbol graphs are stale

**Symptom:** New APIs don't appear in documentation.

**Cause:** Symbol graphs weren't regenerated.

**Solution:** Use `--clean` flag to force regeneration:
```bash
./Scripts/build-documentation.sh --clean
```

### Documentation includes system framework symbols

**Symptom:** Documentation shows CoreFoundation, CoreGraphics symbols.

**Cause:** Symbol filtering failed or was disabled.

**Solution:** The filtering is automatic. If you see system symbols, check the build output for filtering errors and ensure the Python JSON filtering step completed successfully.

### Port already in use (preview)

**Symptom:** `Address already in use` error when running preview.

**Solution:** The script will detect this and prompt you to kill the existing process, or use a different port:
```bash
./Scripts/build-documentation.sh --preview --port 8001
```

## Advanced Usage

### Building documentation for OpenSwiftUICore

```bash
./Scripts/build-documentation.sh --target OpenSwiftUICore --preview
```

### Internal documentation for contributors

```bash
./Scripts/build-documentation.sh \
  --minimum-access-level internal \
  --preview
```

### Testing legacy deployment without pushing

```bash
./Scripts/update-gh-pages-documentation.sh \
  --echo-without-push
```

This creates the gh-pages branch locally and shows what would be pushed without actually pushing to the remote.

## Technical Details

### Symbol Graph Filtering

The build process filters symbol graphs to remove re-exported system framework symbols:

1. Swift compiler generates symbol graphs with `-emit-symbol-graph`
2. Symbol graphs include all accessible symbols, including re-exports from CoreFoundation, CoreGraphics, etc.
3. Python script parses Swift mangled identifiers (format: `s:MODULE_LEN+MODULE_NAME...`) to extract module names
4. Only symbols from `OpenSwiftUI` and `OpenSwiftUICore` modules are kept
5. Typical reduction: ~10,000 → ~4,300 symbols

### Legacy Git Worktree Approach

The deployment script uses git worktree to manage the gh-pages branch:

- Main working tree: feature branch with source code
- Worktree at `gh-pages/`: checked out to gh-pages branch
- This allows deploying documentation without switching branches in the main working tree
- Worktree is automatically cleaned up after deployment

### Force Push Strategy

By default, deployments use `git push --force` to prevent repository size growth:

- Documentation includes large binary files (CSS, JS, images, data)
- Preserving history would accumulate these files with each deployment
- Force push keeps only the latest version in git history
- Trade-off: No documentation version history in git (use git tags on main branch for versioning instead)

To preserve history: `./Scripts/update-gh-pages-documentation.sh --no-force`

## Future Improvements

The following improvements are planned for the documentation system:

- [ ] **Remove default implementation** - Currently, the documentation includes default implementations from protocol extensions. These can clutter the documentation and make it harder to find the primary API declarations. Future work will add filtering to hide default implementations while keeping protocol requirements visible.

- [x] **Migrate to GitHub Actions** - Documentation deployment now runs through
  `.github/workflows/documentation.yml`, with publication from version tags and
  manual workflow runs.
