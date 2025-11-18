//
//  Semantics.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

import dyldPrivate

/// Determines if the current SDK version is equal to or newer than the specified semantic version.
///
/// This function checks if the application was built with an SDK that satisfies the provided semantic version requirement.
/// For example, checking against `.v6` would return true if the application was built with iOS 18.0 SDK or newer.
///
/// - Parameter semantics: The semantic version to check against.
/// - Returns: `true` if the current SDK version is equal to or newer than the specified version, `false` otherwise.
@inline(__always)
package func isLinkedOnOrAfter(_ semantics: Semantics) -> Bool {
    if let sdk = Semantics.forced.sdk {
        sdk >= semantics
    } else {
        dyld_program_sdk_at_least(dyld_build_version_t(semantics: semantics))
    }
}

/// Determines if the current deployment target is equal to or newer than the specified semantic version.
///
/// This function checks if the application's minimum OS version (deployment target) satisfies the 
/// provided semantic version requirement. For example, checking against `.v5` would return true if the 
/// application is built to run on iOS 17.0 or newer.
///
/// - Parameter semantics: The semantic version to check against.
/// - Returns: `true` if the current deployment target is equal to or newer than the specified version, `false` otherwise.
@inline(__always)
package func isDeployedOnOrAfter(_ semantics: Semantics) -> Bool {
    if let deploymentTarget = Semantics.forced.deploymentTarget {
        deploymentTarget >= semantics
    } else {
        dyld_program_minos_at_least(dyld_build_version_t(semantics: semantics))
    }
}

/// A type representing OpenSwiftUI's semantic versioning system.
///
/// The `Semantics` struct maps various Apple OS version combinations to OpenSwiftUI's internal
/// versioning scheme. This allows feature checks to be done against semantic versions rather than
/// individual OS versions, providing a consistent API across all platforms.
///
/// For example, `.v6` represents the Fall 2024 release which corresponds to iOS 18.0, macOS 15.0, watchOS 11.0, etc.
package struct Semantics: Hashable, Comparable, CustomStringConvertible {
    package static func < (lhs: Semantics, rhs: Semantics) -> Bool {
        lhs.value < rhs.value
    }
    
    package var description: String {
        let x = Int(value >> 16)
        let y = (value >> 8) & 0xFF
        let z = value & 0xFF
        return "\(x)-\(String(y, radix: 16))-\(String(z, radix: 16))"
    }
    
    var value: UInt32
}

/// Defines the type of version check to perform.
///
/// - `linkedOnOrAfter`: Checks against the SDK version the application was built with
/// - `deployedOnOrAfter`: Checks against the minimum OS version the application is designed to run on
package enum SemanticRequirement {
    case linkedOnOrAfter
    case deployedOnOrAfter
}

extension Semantics {
    /// Provides a way to override semantic version checking for testing purposes.
    package static var forced: Forced = Forced()

    /// Temporarily sets a specific semantic version for testing.
    ///
    /// This method allows forcing a specific semantic version for testing purposes,
    /// then restores the original value after the test completes.
    ///
    /// - Parameters:
    ///   - keyPath: The keyPath to modify, defaulting to `\.sdk`
    ///   - body: The code to execute with the modified semantic version
    /// - Returns: The result of executing the body closure
    package func test<R>(as keyPath: WritableKeyPath<Forced, Semantics?> = \.sdk, _ body: () throws -> R) rethrows -> R {
        let value = Semantics.forced[keyPath: keyPath]
        Semantics.forced[keyPath: keyPath] = self
        defer { Semantics.forced[keyPath: keyPath] = value }
        return try body()
    }
}
extension Semantics {
    /// Container for forced semantic version overrides.
    ///
    /// This struct provides a way to override the semantic version checking
    /// behavior for testing purposes. When the forced values are nil, the system
    /// uses runtime checks against the actual SDK and deployment target.
    package struct Forced {
        /// The forced SDK version to use, or nil to use runtime detection
        package var sdk: Semantics?

        /// The forced deployment target to use, or nil to use runtime detection
        package var deploymentTarget: Semantics?

        package init() {
            if dyld_program_sdk_at_least(dyld_build_version_t(semantics: firstRelease)) {
                sdk = nil
                deploymentTarget = nil
            } else {
                sdk = .latest
                deploymentTarget = .latest
            }
        }
    }
}

extension Semantics {
    /// The first official release version of OpenSwiftUI.
    ///
    /// Corresponds to iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0
    package static let firstRelease = Semantics(version: openSwiftUI_v1_os_versions)

    /// The latest known version in this build of OpenSwiftUI.
    package static let latest = Semantics(value: 0xFFFF_FFFE)

    /// The theoretical maximum version, used for special cases.
    package static let maximal = Semantics(value: 0xFFFF_FFFF)

    /// Fall 2019 (iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0)
    package static let v1 = Semantics(version: openSwiftUI_v1_os_versions)

    /// Winter 2019 (iOS 13.3, macOS 10.15.1, watchOS 6.1, tvOS 13.3)
    package static let v1_3_1 = Semantics(version: openSwiftUI_v1_3_1_os_versions)

    /// Spring 2020 (iOS 13.4, macOS 10.15.4, watchOS 6.2, tvOS 13.4)
    package static let v1_4 = Semantics(version: openSwiftUI_v1_4_os_versions)

    /// Fall 2020 (iOS 14.0, macOS 10.16, watchOS 7.0, tvOS 14.0)
    package static let v2 = Semantics(version: openSwiftUI_v2_os_versions)

    /// Late Fall 2020 (iOS 14.2, macOS 10.16, watchOS 7.1, tvOS 14.1)
    package static let v2_1 = Semantics(version: openSwiftUI_v2_1_os_versions)

    /// Spring 2021 (iOS 14.5, macOS 11.3, watchOS 7.4, tvOS 14.5)
    package static let v2_3 = Semantics(version: openSwiftUI_v2_3_os_versions)

    /// Fall 2021 (iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0)
    package static let v3 = Semantics(version: openSwiftUI_v3_0_os_versions)

    /// Winter 2021 (iOS 15.2, macOS 12.1, watchOS 8.3, tvOS 15.2)
    package static let v3_2 = Semantics(version: openSwiftUI_v3_2_os_versions)

    /// Spring 2022 (iOS 15.4, macOS 12.3, watchOS 8.5, tvOS 15.4)
    package static let v3_4 = Semantics(version: openSwiftUI_v3_4_os_versions)

    /// Fall 2022 (iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0)
    package static let v4 = Semantics(version: openSwiftUI_v4_0_os_versions)

    /// 2022 SU E (iOS 16.4, macOS 13.3, watchOS 9.4, tvOS 16.4)
    package static let v4_4 = Semantics(version: openSwiftUI_v4_4_os_versions)

    /// Fall 2023 (iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0)
    package static let v5 = Semantics(version: openSwiftUI_v5_0_os_versions)

    /// 2023 SU C (iOS 17.2, macOS 14.2, watchOS 10.2, tvOS 17.2, visionOS 1.0)
    package static let v5_2 = Semantics(version: openSwiftUI_v5_2_os_versions)

    /// Fall 2024 (iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0)
    package static let v6 = Semantics(version: openSwiftUI_v6_0_os_versions)

    /// 2024 (2024.2.0) SDK version set
    package static let v6_1 = Semantics(version: openSwiftUI_v6_1_os_versions)

    /// 2024 (2024.2.0) SDK version set
    package static let v6_2 = Semantics(version: openSwiftUI_v6_2_os_versions)

    /// 2024 (2024.4.0) SDK version set
    package static let v6_4 = Semantics(version: openSwiftUI_v6_4_os_versions)

    /// Fall 2025 (future release)
    package static let v7 = Semantics(version: openSwiftUI_v7_0_os_versions)
}

extension Semantics {
    /// Returns a semantic version one unit prior to the current version.
    package var prior: Semantics {
        Semantics(value: value - 1)
    }
}

extension SemanticFeature {
    /// Determines if this semantic feature is enabled in the current environment.
    @inline(__always)
    package static var isEnabled: Bool {
        switch requirement {
        case .linkedOnOrAfter:
            isLinkedOnOrAfter(introduced)
        case .deployedOnOrAfter:
            isDeployedOnOrAfter(introduced)
        }
    }
}

extension dyld_build_version_t {
    @inline(__always)
    init(_ value: UInt64) {
        self.init(
            platform: dyld_platform_t(value & 0xFFFF_FFFF),
            version: UInt32((value >> 32) & 0xFFFF_FFFF)
        )
    }

    @inline(__always)
    init(version: UInt32) {
        self.init(platform: .max, version: version)
    }
    
    @inline(__always)
    init(semantics: Semantics) {
        self.init(version: semantics.value)
    }
}

extension Semantics {
    @inline(__always)
    init(version: dyld_build_version_t) {
        value = version.version
    }
}

// NOTE: See ./Docs/AvailabilityVersions/README.md for more information

/// Fall 2019 (2019.9.1) SDK version set
///
/// macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, bridgeOS 4.0, driverKit 19.0
let openSwiftUI_v1_os_versions = dyld_build_version_t(version: 0x07E3_0901)

/// Autumn 2019 (2019.9.2) SDK version set
///
/// macOS 10.15, iOS 13.1, watchOS 6.0, tvOS 13.0, bridgeOS 4.0, driverKit 19.0
let openSwiftUI_autumn_2019_os_versions = dyld_build_version_t(version: 0x07E3_0902)

/// Late Fall 2019 (2019.16.21) SDK version set
///
/// macOS 10.15.1, iOS 13.2, watchOS 6.1, tvOS 13.2, bridgeOS 4.1, driverKit 19.0
let openSwiftUI_late_fall_2019_os_versions = dyld_build_version_t(version: 0x07E3_1015)

/// Winter 2019 (2019.18.1) SDK version set
///
/// macOS 10.15.1, iOS 13.3, watchOS 6.1, tvOS 13.3, bridgeOS 4.1, driverKit 19.0
let openSwiftUI_v1_3_1_os_versions = dyld_build_version_t(version: 0x07E3_1201)

/// Spring 2020 (2020.3.1) SDK version set
///
/// macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, bridgeOS 4.1, driverKit 19.0
let openSwiftUI_v1_4_os_versions = dyld_build_version_t(version: 0x07E4_0301)

/// Late Spring 2020 (2020.4.21) SDK version set
///
/// macOS 10.15.4, iOS 13.5, watchOS 6.2, tvOS 13.4, bridgeOS 4.1, driverKit 19.0
let openSwiftUI_late_spring_2020_os_versions = dyld_build_version_t(version: 0x07E4_0415)

/// Summer 2020 (2020.6.1) SDK version set
///
/// macOS 10.15.4, iOS 13.6, watchOS 6.2, tvOS 13.4, bridgeOS 4.1, driverKit 19.0
let openSwiftUI_summer_2020_os_versions = dyld_build_version_t(version: 0x07E4_0601)

/// Fall 2020 (2020.9.1) SDK version set
///
/// macOS 10.16, iOS 14.0, watchOS 7.0, tvOS 14.0, bridgeOS 5.0, driverKit 20.0
let openSwiftUI_v2_os_versions = dyld_build_version_t(version: 0x07E4_0901)

/// Late Fall 2020 (2020.16.21) SDK version set
///
/// macOS 10.16, iOS 14.2, watchOS 7.1, tvOS 14.1, bridgeOS 5.0, driverKit 20.0
let openSwiftUI_v2_1_os_versions = dyld_build_version_t(version: 0x07E4_1015)

/// Spring 2021 (2021.3.1) SDK version set
///
/// macOS 11.3, iOS 14.5, watchOS 7.4, tvOS 14.5, bridgeOS 5.3, driverKit 20.0
let openSwiftUI_v2_3_os_versions = dyld_build_version_t(version: 0x07E5_0301)

/// Fall 2021 (2021.9.1) SDK version set
///
/// macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, bridgeOS 6.0, driverKit 21.0
let openSwiftUI_v3_0_os_versions = dyld_build_version_t(version: 0x07E5_0901)

/// Winter 2021 (2021.18.01) SDK version set
///
/// macOS 12.1, iOS 15.2, watchOS 8.3, tvOS 15.2, bridgeOS 6.2, driverKit 21.0
let openSwiftUI_v3_2_os_versions = dyld_build_version_t(version: 0x07E5_1201)

/// Spring 2022 (2022.3.1) SDK version set
///
/// macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, bridgeOS 6.4, driverKit 21.0
let openSwiftUI_v3_4_os_versions = dyld_build_version_t(version: 0x07E6_0301)

/// Fall 2022 (2022.9.1) SDK version set
///
/// macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, bridgeOS 7.0, driverKit 22.0
let openSwiftUI_v4_0_os_versions = dyld_build_version_t(version: 0x07E6_0901)

/// 2022 SU E (2022.35.0) SDK version set
///
/// macOS 13.3, iOS 16.4, watchOS 9.4, tvOS 16.4, bridgeOS 7.3, driverKit 22.4
let openSwiftUI_v4_4_os_versions = dyld_build_version_t(version: 0x07E6_2300)

/// Fall 2023 (2023.9.1) SDK version set
///
/// macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, bridgeOS 8.0, driverKit 23.0
let openSwiftUI_v5_0_os_versions = dyld_build_version_t(version: 0x07E7_0901)

/// 2023 SU C (2023.13.1) SDK version set
///
/// macOS 14.2, iOS 17.2, watchOS 10.2, tvOS 17.2, bridgeOS 8.2, driverKit 23.2, visionOS 1.0
let openSwiftUI_v5_2_os_versions = dyld_build_version_t(version: 0x07E7_0d01)

/// Fall 2024 (2024.0.0) SDK version set
///
/// macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, bridgeOS 9.0, driverKit 24.0, visionOS 2.0
let openSwiftUI_v6_0_os_versions = dyld_build_version_t(version: 0x07E8_0000)

/// 2024 SU B (2024.1.0) SDK version set
///
/// macOS 15.1, iOS 18.1, watchOS 11.1, tvOS 18.1, bridgeOS 9.1, driverKit 24.1, visionOS 2.1
let openSwiftUI_v6_1_os_versions = dyld_build_version_t(version: 0x07E8_0100)

/// 2024 (2024.2.0) SDK version set
///
/// macOS 15.2, iOS 18.2, watchOS 11.2, tvOS 18.2, bridgeOS 9.2, driverKit 24.2, visionOS 2.2
let openSwiftUI_v6_2_os_versions = dyld_build_version_t(version: 0x07E8_0200)

/// 2024 (2024.4.0) SDK version set
///
/// macOS 15.4, iOS 18.4, watchOS 11.4, tvOS 18.4, bridgeOS 9.4, driverKit 24.4, visionOS 2.4
let openSwiftUI_v6_4_os_versions = dyld_build_version_t(version: 0x07E8_0400)

/// Fall 2025 (2025.0.0) SDK version set
///
/// macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, bridgeOS 26.0, driverKit 26.0, visionOS 26.0
let openSwiftUI_v7_0_os_versions = dyld_build_version_t(version: 0x07E9_0000)
