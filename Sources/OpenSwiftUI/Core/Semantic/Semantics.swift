//
//  Semantics.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

internal import COpenSwiftUI

struct Semantics: CustomStringConvertible, Comparable, Hashable {
    var description: String {
        "\(hashValue)\(value)"
    }

    static func < (lhs: Semantics, rhs: Semantics) -> Bool {
        lhs.value < rhs.value
    }
    
    var value: UInt32

    static let forced: Semantics? = {
        if dyld_program_sdk_at_least(.init(semantics: firstRelease)) {
            return nil
        } else {
            return Semantics(value: 0xFFFF_FFFE)
        }
    }()

    static let firstRelease: Semantics = .v1
    static let v1: Semantics = .init(version: openSwiftUI_v1_os_versions)
    static let v2: Semantics = .init(version: openSwiftUI_v2_os_versions)
    static let v2_1: Semantics = .init(version: openSwiftUI_v2_1_os_versions)
    static let v2_3: Semantics = .init(version: openSwiftUI_v2_3_os_versions)
    static let v3: Semantics = .init(version: openSwiftUI_v3_0_os_versions)
    static let v3_2: Semantics = .init(version: openSwiftUI_v3_2_os_versions)
}

extension dyld_build_version_t {
    @inline(__always)
    init(_ value: UInt64) {
        self.init(platform: dyld_platform_t(value), version: UInt32(value >> 32))
    }

    @inline(__always)
    init(semantics: Semantics) {
        self.init(platform: .max, version: semantics.value)
    }
}

extension Semantics {
    @inline(__always)
    init(version: dyld_build_version_t) {
        value = version.version
    }
}

let openSwiftUI_v1_os_versions = dyld_build_version_t(0x07E3_0901_FFFF_FFFF)
let openSwiftUI_autumn_2019_os_versions = dyld_build_version_t(0x07E3_0902_FFFF_FFFF)
let openSwiftUI_late_fall_2019_os_versions = dyld_build_version_t(0x07E3_1015_FFFF_FFFF)
let openSwiftUI_v1_3_1_os_versions = dyld_build_version_t(0x07E3_1201_FFFF_FFFF)
let openSwiftUI_v1_4_os_versions = dyld_build_version_t(0x07E4_0301_FFFF_FFFF)
let openSwiftUI_late_spring_2020_os_versions = dyld_build_version_t(0x07E4_0415_FFFF_FFFF)
let openSwiftUI_summer_2020_os_versions = dyld_build_version_t(0x07E4_0601_FFFF_FFFF)
let openSwiftUI_v2_os_versions = dyld_build_version_t(0x07E4_0901_FFFF_FFFF)
let openSwiftUI_v2_1_os_versions = dyld_build_version_t(0x07E4_1015_FFFF_FFFF)
let openSwiftUI_v2_3_os_versions = dyld_build_version_t(0x07E5_0301_FFFF_FFFF)
let openSwiftUI_v3_0_os_versions = dyld_build_version_t(0x07E5_0901_FFFF_FFFF)
let openSwiftUI_v3_2_os_versions = dyld_build_version_t(0x07E5_1201_FFFF_FFFF)
let openSwiftUI_v3_4_os_versions = dyld_build_version_t(0x07E6_0301_FFFF_FFFF)
