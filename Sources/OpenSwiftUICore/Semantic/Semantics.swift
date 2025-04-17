//
//  Semantics.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

import OpenSwiftUI_SPI

@inline(__always)
package func isLinkedOnOrAfter(_ semantics: Semantics) -> Bool {
    if let sdk = Semantics.forced.sdk {
        sdk >= semantics
    } else {
        dyld_program_sdk_at_least(dyld_build_version_t(semantics: semantics))
    }
}

@inline(__always)
package func isDeployedOnOrAfter(_ semantics: Semantics) -> Bool {
    if let deploymentTarget = Semantics.forced.deploymentTarget {
        deploymentTarget >= semantics
    } else {
        dyld_program_sdk_at_least(dyld_build_version_t(semantics: semantics))
    }
}

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

package enum SemanticRequirement {
    case linkedOnOrAfter
    case deployedOnOrAfter
}

extension Semantics {
    package static var forced: Forced = Forced()

    package func test<R>(as keyPath: WritableKeyPath<Forced, Semantics?> = \.sdk, _ body: () throws -> R) rethrows -> R {
        let value = Semantics.forced[keyPath: keyPath]
        Semantics.forced[keyPath: keyPath] = self
        defer { Semantics.forced[keyPath: keyPath] = value }
        return try body()
    }
}
extension Semantics {
    package struct Forced {
        package var sdk: Semantics?

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
    package static let firstRelease = Semantics(version: openSwiftUI_v1_os_versions)
    package static let latest = Semantics(value: 0xFFFF_FFFE)
    package static let maximal = Semantics(value: 0xFFFF_FFFF)
    package static let v1 = Semantics(version: openSwiftUI_v1_os_versions)
    package static let v1_3_1 = Semantics(version: openSwiftUI_v1_3_1_os_versions)
    package static let v1_4 = Semantics(version: openSwiftUI_v1_os_versions)
    package static let v2 = Semantics(version: openSwiftUI_v2_os_versions)
    package static let v2_1 = Semantics(version: openSwiftUI_v2_1_os_versions)
    package static let v2_3 = Semantics(version: openSwiftUI_v2_3_os_versions)
    package static let v3 = Semantics(version: openSwiftUI_v3_0_os_versions)
    package static let v3_2 = Semantics(version: openSwiftUI_v3_2_os_versions)
    package static let v3_4 = Semantics(version: openSwiftUI_v3_4_os_versions)
    package static let v4 = Semantics(version: openSwiftUI_v4_0_os_versions)
    package static let v4_4 = Semantics(version: openSwiftUI_v4_4_os_versions)
    package static let v5 = Semantics(version: openSwiftUI_v5_0_os_versions)
    package static let v5_2 = Semantics(version: openSwiftUI_v5_2_os_versions)
    package static let v6 = Semantics(version: openSwiftUI_v6_0_os_versions)
}

extension Semantics {
    package var prior: Semantics {
        Semantics(value: value - 1)
    }
}

extension SemanticFeature {
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

// NOTE: Source: https://theapplewiki.com/wiki/Timeline

/// Fall 2019 OS version - iOS 13.0
let openSwiftUI_v1_os_versions = dyld_build_version_t(version: 0x07E3_0901)

/// iOS 13.1
let openSwiftUI_autumn_2019_os_versions = dyld_build_version_t(version: 0x07E3_0902)

/// iOS 13.2
let openSwiftUI_late_fall_2019_os_versions = dyld_build_version_t(version: 0x07E3_1015)

/// 2020.12.01 - iOS 13.3.1
let openSwiftUI_v1_3_1_os_versions = dyld_build_version_t(version: 0x07E3_1201)

/// Spring 2020 OS version - iOS 13.4
let openSwiftUI_v1_4_os_versions = dyld_build_version_t(version: 0x07E4_0301)

let openSwiftUI_late_spring_2020_os_versions = dyld_build_version_t(version: 0x07E4_0415)

let openSwiftUI_summer_2020_os_versions = dyld_build_version_t(version: 0x07E4_0601)

/// Fall 2020 - 2020.09.01 - iOS 14.0
let openSwiftUI_v2_os_versions = dyld_build_version_t(version: 0x07E4_0901)

/// Late Fall 2020 - 2020.10.15 - iOS 14.1
let openSwiftUI_v2_1_os_versions = dyld_build_version_t(version: 0x07E4_1015)

/// Spring 2021 - 2021.03.01 - iOS 14.3
let openSwiftUI_v2_3_os_versions = dyld_build_version_t(version: 0x07E5_0301)

/// Fall 2021 - 2021.09.01 - iOS 15.0
let openSwiftUI_v3_0_os_versions = dyld_build_version_t(version: 0x07E5_0901)

/// Winter 2021 - 2021.12.01 - iOS 15.2
let openSwiftUI_v3_2_os_versions = dyld_build_version_t(version: 0x07E5_1201)

/// Spring 2022 - 2022.03.01 - iOS 15.4
let openSwiftUI_v3_4_os_versions = dyld_build_version_t(version: 0x07E6_0301)

// MARK: - 2022.9.1 OS release (iOS 16)

/// Fall 2022 - 2022.09.01 - iOS 16.0
let openSwiftUI_v4_0_os_versions = dyld_build_version_t(version: 0x07E6_0901)

/// Late Fall 2022 - 2022.10.15 - iOS 16.4
let openSwiftUI_v4_4_os_versions = dyld_build_version_t(version: 0x07E6_2300)

// MARK: - 2023.9.1 OS release (iOS 17)

/// Fall 2023 OS version - iOS 18.0
let openSwiftUI_v5_0_os_versions = dyld_build_version_t(version: 0x07E7_0901)

let openSwiftUI_v5_2_os_versions = dyld_build_version_t(version: 0x07E7_0d01)

// MARK: - 2024 OS release (iOS 18)

/// Fall 2024 OS version - iOS 18.0
let openSwiftUI_v6_0_os_versions = dyld_build_version_t(version: 0x07E8_0000)

///
let openSwiftUI_v6_1_os_versions = dyld_build_version_t(version: 0x07E8_0100)

let openSwiftUI_v6_2_os_versions = dyld_build_version_t(version: 0x07E8_0200)

let openSwiftUI_v6_4_os_versions = dyld_build_version_t(version: 0x07E8_0400)

// MARK: - 2025 OS release (iOS 19)

let openSwiftUI_v7_0_os_versions = dyld_build_version_t(version: 0x07E9_0000)
