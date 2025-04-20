# AvailabilityVersions

This folder contains information regarding availability versions used by the Semantics system in OpenSwiftUI.

## Overview

The OpenSwiftUI project uses a semantic versioning system defined in `Semantics.swift` to determine feature availability across different OS versions. This system allows code to conditionally execute based on the SDK version and deployment target.

## Source

The version information used in `Semantics.swift` is derived from Apple's official availability definitions:

- Current implementation is based on [AvailabilityVersions-143.7](https://github.com/apple-oss-distributions/AvailabilityVersions/blob/AvailabilityVersions-143.7/availability.dsl)
- The availability DSL file defines the relationships between OS versions and their corresponding version sets

## Versioning Structure

The versioning follows Apple's SDK release pattern using a hexadecimal format:

```swift
let openSwiftUI_v5_0_os_versions = dyld_build_version_t(version: 0x07E7_0901)
```

This represents Fall 2023 (2023.9.1) which corresponds to:
- iOS 17.0
- macOS 14.0
- tvOS 17.0
- watchOS 10.0
- bridgeOS 8.0
- driverKit 23.0

## Maintenance

When updating the project to support new OS versions:

1. Update the constants in `Semantics.swift` with new availability information
2. Add corresponding semantic version identifiers
3. Document the correlation between OpenSwiftUI semantic versions and Apple OS releases

## References

- [The Apple Wiki Timeline](https://theapplewiki.com/wiki/Timeline)
- [Apple OSS Distributions](https://github.com/apple-oss-distributions/AvailabilityVersions)
