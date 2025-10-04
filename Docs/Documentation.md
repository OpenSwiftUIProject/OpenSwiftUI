# Documentation

This document explains how OpenSwiftUI's documentation is built and hosted.

## Overview

OpenSwiftUI uses Swift-DocC to generate API documentation, which is hosted on GitHub Pages at:

**https://openswiftuiproject.github.io/OpenSwiftUI/documentation/openswiftui/**

The documentation is built from the `OpenSwiftUI` target and includes symbols from `OpenSwiftUICore` via `@_exported import`. System framework symbols (CoreFoundation, CoreGraphics, etc.) are filtered out to keep the documentation focused on OpenSwiftUI's own APIs.

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

**Example workflow:**
```bash
# Preview documentation locally before deploying
./Scripts/build-documentation.sh --preview

# Open http://localhost:8000/documentation/openswiftui in your browser
# Make changes to documentation comments in source code
# Re-run the script to see updates (uses incremental builds)
```

### `Scripts/update-gh-pages-documentation.sh`

Builds and deploys documentation to GitHub Pages.

**Usage:**
```bash
# Build and deploy documentation to GitHub Pages
./Scripts/update-gh-pages-documentation.sh --hosting-base-path /OpenSwiftUI

# Test deployment without pushing (dry-run)
./Scripts/update-gh-pages-documentation.sh --hosting-base-path /OpenSwiftUI --echo-without-push

# Deploy using existing build (skip building)
./Scripts/update-gh-pages-documentation.sh --no-build --hosting-base-path /OpenSwiftUI

# Deploy with internal symbols
./Scripts/update-gh-pages-documentation.sh --minimum-access-level internal --hosting-base-path /OpenSwiftUI
```

**Important:** Always use `--hosting-base-path /OpenSwiftUI` when deploying to GitHub Pages, as the site is served from a subdirectory. Without this flag, CSS/JS resources will fail to load.

**Options:**
- `--hosting-base-path PATH` - **Required** for GitHub Pages deployment (use `/OpenSwiftUI`)
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

## GitHub Pages Configuration

The documentation is deployed to the `gh-pages` branch with the following structure:

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

**GitHub Pages settings:**
- **Source:** Deploy from branch
- **Branch:** `gh-pages`
- **Folder:** `/docs`

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

# 4. Deploy to GitHub Pages
./Scripts/update-gh-pages-documentation.sh --hosting-base-path /OpenSwiftUI

# 5. Wait 1-2 minutes for GitHub Pages to rebuild
# 6. Verify at https://openswiftuiproject.github.io/OpenSwiftUI/documentation/openswiftui/
```

### For major API changes:

If you've added new public APIs or significantly changed the module structure, use `--clean` to force regeneration of symbol graphs:

```bash
./Scripts/update-gh-pages-documentation.sh --clean --hosting-base-path /OpenSwiftUI
```

## Troubleshooting

### CSS/JS files not loading (404 errors)

**Symptom:** Documentation page loads but appears unstyled, browser console shows 404 errors for CSS/JS files.

**Cause:** Documentation was built without `--hosting-base-path /OpenSwiftUI` flag.

**Solution:** Rebuild and redeploy with the correct flag:
```bash
./Scripts/update-gh-pages-documentation.sh --hosting-base-path /OpenSwiftUI
```

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

### Testing deployment without pushing

```bash
./Scripts/update-gh-pages-documentation.sh \
  --hosting-base-path /OpenSwiftUI \
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

### Git Worktree Approach

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

To preserve history: `./Scripts/update-gh-pages-documentation.sh --no-force --hosting-base-path /OpenSwiftUI`
