//
//  Semantics.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
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

let openSwiftUI_v1_os_versions = dyld_build_version_t(version: 0x07E3_0901)
let openSwiftUI_autumn_2019_os_versions = dyld_build_version_t(version: 0x07E3_0902)
let openSwiftUI_late_fall_2019_os_versions = dyld_build_version_t(version: 0x07E3_1015)
let openSwiftUI_v1_3_1_os_versions = dyld_build_version_t(version: 0x07E3_1201)
let openSwiftUI_v1_4_os_versions = dyld_build_version_t(version: 0x07E4_0301)
let openSwiftUI_late_spring_2020_os_versions = dyld_build_version_t(version: 0x07E4_0415)
let openSwiftUI_summer_2020_os_versions = dyld_build_version_t(version: 0x07E4_0601)
let openSwiftUI_v2_os_versions = dyld_build_version_t(version: 0x07E4_0901)
let openSwiftUI_v2_1_os_versions = dyld_build_version_t(version: 0x07E4_1015)
let openSwiftUI_v2_3_os_versions = dyld_build_version_t(version: 0x07E5_0301)
let openSwiftUI_v3_0_os_versions = dyld_build_version_t(version: 0x07E5_0901)
let openSwiftUI_v3_2_os_versions = dyld_build_version_t(version: 0x07E5_1201)
let openSwiftUI_v3_4_os_versions = dyld_build_version_t(version: 0x07E6_0301)
let openSwiftUI_v4_0_os_versions = dyld_build_version_t(version: 0x07E6_0901)
let openSwiftUI_v4_4_os_versions = dyld_build_version_t(version: 0x07E6_2300)
let openSwiftUI_v5_0_os_versions = dyld_build_version_t(version: 0x07E7_0901)
let openSwiftUI_v5_2_os_versions = dyld_build_version_t(version: 0x07E7_0d01)
let openSwiftUI_v6_0_os_versions = dyld_build_version_t(version: 0x07E8_0000)
let openSwiftUI_v6_1_os_versions = dyld_build_version_t(version: 0x07E8_0100)
let openSwiftUI_v6_2_os_versions = dyld_build_version_t(version: 0x07E8_0200)
let openSwiftUI_v6_4_os_versions = dyld_build_version_t(version: 0x07E8_0400)
let openSwiftUI_v7_0_os_versions = dyld_build_version_t(version: 0x07E9_0000)
