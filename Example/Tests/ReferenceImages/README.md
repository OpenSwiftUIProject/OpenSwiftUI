# UI and Interaction Test Reference Images

This directory is the default local reference image store for OpenSwiftUI UI and interaction snapshot tests.

When tests run without `SNAPSHOT_REFERENCE_DIR`, the shared test helper resolves reference images under this directory and then appends the current platform and OS version, for example:

```text
Example/Tests/ReferenceImages/macOS/15.7.4
```

UI and interaction test jobs in GitHub Actions use a persistent machine-local reference image store instead:

```text
/Volumes/Workspace/OpenSwiftUI_CI/ReferenceImages/
```

The workflow passes that root to the test process with `TEST_RUNNER_SNAPSHOT_REFERENCE_DIR`. UI and interaction snapshots use separate test module directories below the platform and OS version. The generated snapshots remain ignored by git so local or CI recording does not add image churn to normal commits.

Interaction test jobs reuse these references by default. An explicit `update` request
records SwiftUI references before OpenSwiftUI verification, including for the
initial baseline. UI test jobs also record when their references are missing.
Both test families use the same recording lock. Failed runs upload reference
and failed images found in the test log, along with logs and result bundles.
