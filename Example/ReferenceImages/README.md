# UI Test Reference Images

This directory is the default local reference image store for OpenSwiftUI UI snapshot tests.

When the UI tests run locally without `SNAPSHOT_REFERENCE_DIR`, the test helper resolves reference images under this directory and then appends the current platform and OS version, for example:

```text
Example/ReferenceImages/macOS/15.7.4
```

GitHub Actions uses a persistent machine-local reference image store instead:

```text
/Volumes/Workspace/OpenSwiftUI_CI/ReferenceImages/
```

The workflow injects that absolute path into the generated test schemes only while running UI tests in CI. The generated snapshots remain ignored by git so local or CI recording does not add image churn to normal commits.
