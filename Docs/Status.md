# Status Description

Implementation status uses a two-axis system to track both API coverage and verification level.

Unless specified:
- when the implementation is audited for 6.5.4 release the documentation is audited for Xcode 16.4 SDK.

## Axis 1: API Coverage

How much of the API surface is implemented?

| Status   | Description                                              |
|----------|----------------------------------------------------------|
| Empty    | Only namespace/placeholder, no API implementation        |
| Partial  | Some APIs implemented, some missing                      |
| Blocked  | Most implementation complete, some blocked by dependencies |
| Complete | All APIs implemented                                     |

## Axis 2: Verification Level

How was the implementation created and verified?

| Status    | Description                                              |
|-----------|----------------------------------------------------------|
| Verified  | Implementation confirmed against reference binary        |
| Generated | Auto-generated implementation, pending verification      |
| Stubbed   | Placeholder logic (returns default values or throws)     |

## Combined Status Format

Status can be expressed as: `[Coverage]` or `[Coverage]-[Verification]`

- `Complete` implies `Verified`, so the verification suffix is omitted
- For other coverage levels, append verification when not `Verified`

Examples:
- `Complete`: All APIs implemented and confirmed against reference
- `Complete-Generated`: All APIs implemented but pending verification
- `Partial-Stubbed`: Some APIs exist as placeholders only

## Legacy Status Mapping

| Legacy Status | New Status Equivalent |
|---------------|----------------------|
| Empty         | Empty-Stubbed        |
| WIP           | Partial-*            |
| Blocked       | Blocked-*            |
| Complete      | Complete             |
