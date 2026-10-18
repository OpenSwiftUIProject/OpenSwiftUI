# UI Test CI

The UI test workflow is defined in `.github/workflows/uitests.yml` and uses the shared action in `.github/actions/uitests/action.yml`.

UI and interaction tests share command parsing in `.github/workflows/prepare_snapshot_tests.yml` and the same test action. interaction tests expose these parameters through `/interactiontest` and `interaction_tests.yml`, but require an explicit update to record references, including the first run.

UI tests run only through manual dispatch or a trusted PR comment. Pushes and pull request updates do not run them automatically. See [Optional CI workflows](README.md) for the other optional checks.

The workflow uses the same Example setup entry point as local development. Non-Compute configurations run `Example/setup.sh`, and Compute configurations run `Example/setup.sh --compute`.

Each iOS recording or verification invocation creates a new simulator with the
requested device type and OS version. The action passes its UDID to Xcode without
booting it first. UI tests retain parallel testing, so Xcode can clone a source
that has no Spotlight index protected by the host's locked keybag. Recording and
verification use separate source devices, even when they run in the same job.
Interaction tests keep their existing serial execution setting.

An `always()` step removes the source devices and their named parallel workers
from the default and testing device sets. It does not reset shared simulators or
change data protection. If cleanup fails, the action retains the temporary test
directory and simulator ownership files for diagnosis. A stopped runner or a
force-terminated job can prevent cleanup from running.

## Default Matrix

Requests without a platform or configuration selection run the default matrix on both iOS Simulator and macOS:

| Configuration | Renderer | Attribute graph backend |
| --- | --- | --- |
| `swiftui-renderer-ag` | SwiftUI | AttributeGraph |
| `openswiftui-renderer-iag` | OpenSwiftUI | Compute |

## Reference Recording

An `update` request records SwiftUI reference images once per selected platform. The `Record SwiftUI references on iOS` and `Record SwiftUI references on macOS` jobs run `SUI_UITests` with the default SwiftUI renderer and AttributeGraph setup, because reference images do not depend on the renderer or attribute graph configuration. Each platform's configuration matrix waits for its record job and then runs `OSUI_UITests` only. The recording job has no commit status of its own; if recording fails, each configuration status reports the failure and its tests do not run.

Without `update`, the configuration jobs reuse existing references and record only when the platform reference directory is empty.

## Manual Dispatch

Manual workflow dispatch supports these inputs:

- `platform`: `all`, `ios`, or `macos`.
- `configuration`: `default`, `all`, `swiftui-renderer-ag`, `swiftui-renderer-iag`, `openswiftui-renderer-ag`, or `openswiftui-renderer-iag`.
- `update_reference`: update CI reference images before running tests.
- `only-testing`: optional `xcodebuild -only-testing` identifier. Leave it empty to run all UI tests.

From the GitHub CLI:

```shell
gh workflow run uitests.yml \
  --ref main \
  -f platform=all \
  -f configuration=default \
  -f update_reference=false
```

Examples:

```shell
gh workflow run uitests.yml --ref main -f platform=ios -f configuration=openswiftui-renderer-iag -f update_reference=false
gh workflow run uitests.yml --ref main -f platform=macos -f configuration=all -f update_reference=false
gh workflow run uitests.yml --ref main -f platform=all -f configuration=default -f update_reference=true
gh workflow run uitests.yml --ref main -f platform=ios -f configuration=openswiftui-renderer-iag -f 'only-testing=OpenSwiftUIUITests/TextUITests/dateFormatStyleExample()'
gh workflow run uitests.yml --ref main -f platform=ios -f configuration=openswiftui-renderer-iag -f 'only-testing=OpenSwiftUIUITests/TextUITests/dateFormatStyleExample()' -f update_reference=true
```

The same test filter applies to SwiftUI reference recording and OpenSwiftUI verification. With `update_reference=true`, only the selected tests record reference images. Without it, the workflow uses existing references, or records them if the platform reference directory is empty.

Use the full identifier `OpenSwiftUIUITests/<Suite>/<test>()` for a single Swift Testing test. Keep its case and the trailing `()`. A suite identifier such as `OpenSwiftUIUITests/TextUITests` is also supported. Selection does not enable disabled tests. A selected run fails if no tests execute, including when all selected tests are skipped.

## Pull Request Comments

Trusted PR commenters can request UI tests with:

```text
/uitest [platform] [configuration] [update] [only-testing=<identifier>]
```

Examples:

```text
/uitest
/uitest ios
/uitest macos osui-iag
/uitest all all-configs
/uitest ios config=openswiftui-renderer-iag
/uitest macos update osui-ag
/uitest ios osui-iag only-testing=OpenSwiftUIUITests/TextUITests/dateFormatStyleExample()
/uitest ios osui-iag update only-testing=OpenSwiftUIUITests/TextUITests/dateFormatStyleExample()
```

The comment command accepts `all`, `ios`, or `macos` as the platform. For configurations, it accepts the workflow configuration names above plus these aliases:

| Alias | Configuration |
| --- | --- |
| `all-configs` | `all` |
| `sui-ag` | `swiftui-renderer-ag` |
| `sui-iag` | `swiftui-renderer-iag` |
| `osui-ag` | `openswiftui-renderer-ag` |
| `osui-iag` | `openswiftui-renderer-iag` |

When the command is accepted on a same-repository PR, the workflow creates commit statuses named `UI Tests / iOS / <configuration>` and `UI Tests / macOS / <configuration>` for the requested matrix.

Selected runs append ` / Selected` to the status context so they do not replace full-suite results.
