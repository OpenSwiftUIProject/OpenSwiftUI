# UI Test CI

The UI test workflow is defined in `.github/workflows/uitests.yml` and uses the shared action in `.github/actions/uitests/action.yml`.

The workflow uses the same Example setup entry point as local development. Non-Compute configurations run `Example/setup.sh`, and Compute configurations run `Example/setup.sh --compute`.

## Default Matrix

Pushes to `main` run the default matrix on both iOS Simulator and macOS:

| Configuration | Renderer | Attribute graph backend |
| --- | --- | --- |
| `swiftui-renderer-ag` | SwiftUI | AttributeGraph |
| `openswiftui-renderer-iag` | OpenSwiftUI | Compute |

## Manual Dispatch

Manual workflow dispatch supports these inputs:

- `platform`: `all`, `ios`, or `macos`.
- `configuration`: `default`, `all`, `swiftui-renderer-ag`, `swiftui-renderer-iag`, `openswiftui-renderer-ag`, or `openswiftui-renderer-iag`.
- `update_reference`: update CI reference images before running tests.

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
```

## Pull Request Comments

Trusted PR commenters can request UI tests with:

```text
/uitest [platform] [configuration] [update]
```

Examples:

```text
/uitest
/uitest ios
/uitest macos osui-iag
/uitest all all-configs
/uitest ios config=openswiftui-renderer-iag
/uitest macos update osui-ag
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
