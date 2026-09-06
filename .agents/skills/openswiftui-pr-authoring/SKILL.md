---
name: openswiftui-pr-authoring
description: Draft or review public OpenSwiftUI pull request titles and bodies. Use when proposing, creating, updating, or reviewing an OpenSwiftUI PR.
---

# OpenSwiftUI Pull Request Authoring

- Write PR titles and bodies in English and scope them to the committed diff.
- Use a concise Conventional Commits title that describes the outcome. Follow
  the [contributor guide](../../../CONTRIBUTING.md#commit-messages-and-pull-request-titles).
- Use `## Summary` for the main body. Start the first word of every summary
  bullet with a capital letter, and keep the bullets parallel and
  outcome-focused.
- Omit build commands, test invocations, contributor-workflow boilerplate,
  remaining TODOs, and unrelated follow-up work.
- Keep internal investigation methods out of public wording. Describe results
  in terms of compatibility, behavior, validation, or implementation.
- For stacked PRs, describe only the current layer. Add a `## Stack` section to
  a dependent PR and identify its direct dependency as `Depends on #<number>`.
- Drafting a PR does not authorize pushing branches or creating or updating a
  PR. Obtain the required approval before changing remote state.
