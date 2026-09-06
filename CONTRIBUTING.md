# Contributing to OpenSwiftUI

Thank you for your interest in OpenSwiftUI. Contributions of code, tests,
documentation, examples, and issue reports are welcome.

OpenSwiftUI is under active development. Some APIs are incomplete, behavior
can vary by platform, and internal structure may change as implementation work
continues.

## Before you start

- Search the existing issues and pull requests before starting work.
- Small, focused fixes can be submitted directly as pull requests.
- For large API additions, architectural changes, or new platform work, open an
  issue or discussion first so the approach can be agreed on before substantial
  implementation work begins.

## Development setup

Use the Swift and Xcode versions listed in the
[README](README.md#build). After cloning the repository, build the package with:

```shell
./Scripts/build.sh
```

The default package configuration resolves dependencies from their remote
repositories. To work on OpenSwiftUI and its dependencies together, clone the
relevant repositories from the
[OpenSwiftUIProject organization](https://github.com/OpenSwiftUIProject) as
siblings of this repository and set `OPENSWIFTUI_USE_LOCAL_DEPS=1`.

The package supports additional environment variables for selecting platform
integrations and optional dependencies. Follow the configuration used by the
nearest CI workflow when working on a platform-specific change.

## Making a change

1. Create a branch from the latest `main` branch.
2. Keep the change focused on one problem or feature.
3. Follow the style and organization of the surrounding code.
4. Add or update tests when behavior changes.
5. Add DocC comments for new public APIs and update related guides when needed.

When adding or changing public API, preserve SwiftUI-compatible naming,
signatures, availability, and documentation style where applicable. Avoid
unrelated formatting or mechanical changes in the same pull request.

## Testing

Run the narrowest relevant test suite while developing. Common examples are:

```shell
swift test --filter OpenSwiftUITests
swift test --filter OpenSwiftUICoreTests
swift test --filter OpenSwiftUICompatibilityTests
```

Run the full SwiftPM test suite when the scope of the change warrants it:

```shell
./Scripts/test.sh
```

Some integration and compatibility tests require a specific host platform,
SDK, environment configuration, or local dependency checkout. If a test cannot
run in your environment, explain that limitation in the pull request.

Do not add temporary probe files to `Tests/`. Keep one-off diagnostics outside
the repository and commit only lasting regression coverage.

## Reporting issues

A useful issue report includes:

- the platform and OS version;
- the Swift and Xcode versions, when applicable;
- a minimal reproducible example;
- the expected and actual behavior; and
- relevant logs, backtraces, or screenshots with sensitive information removed.

For crashes or platform-specific behavior, note whether the issue occurs with
OpenSwiftUI, SwiftUI, or both.

## Commit messages and pull request titles

All new commit messages and pull request titles must follow
[Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).
Use this format for the commit subject or pull request title:

```text
<type>[optional scope][!]: <description>
```

Use `feat` for new features and `fix` for bug fixes. Other common types include
`docs`, `refactor`, `perf`, `test`, `build`, `ci`, `style`, and `chore`.
Keep the description concise. Add a scope when it helps identify the affected
component. Commit bodies and footers are optional and follow a blank line.

Mark breaking changes with `!` before `:` in the subject or pull request title.
A commit message can use a `BREAKING CHANGE: <description>` footer instead.

Examples:

```text
feat(text): add text alignment support
fix(layout): preserve child spacing
docs: require Conventional Commits
```

## Pull requests

Pull requests should:

- explain the problem and the chosen approach;
- link related issues or discussions;
- describe the user-visible or API impact;
- include relevant tests or other validation; and
- include screenshots for visual changes when they help reviewers.

Keep commits understandable and the final diff free of generated build output,
local configuration, and unrelated cleanup. Draft pull requests are welcome
for early feedback on work in progress.

## Documentation

Use DocC syntax for documentation. Match the tone and structure of existing
SwiftUI-style documentation, and place comments on the primary public
declaration rather than duplicating them across equivalent declarations.

## License and conduct

By submitting a contribution, you agree that it may be distributed under the
repository's [MIT License](LICENSE).

Be respectful, constructive, and patient in issues, reviews, and discussions.
Focus feedback on the work and help keep the project welcoming to contributors
with different backgrounds and experience levels.
