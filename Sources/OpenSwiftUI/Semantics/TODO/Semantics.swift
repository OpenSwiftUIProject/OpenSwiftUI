//
//  Semantics.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/23.
//  Lastest Version: iOS 15.5
//  Status: WIP

import Foundation

struct Semantics: CustomStringConvertible, Comparable, Hashable {
    var description: String {
        "\(hashValue)\(value)"
    }

    static func < (lhs: Semantics, rhs: Semantics) -> Bool {
        lhs.value < rhs.value
    }
    
    var value: UInt32

    // FIXME: Unimplemented
    static let forced: Semantics? = nil

    static let firstRelease: Semantics = .v1
    static let v1: Semantics = .init(value: UInt32(openSwiftUI_v1_os_versions) >> 32)
    static let v2: Semantics = .init(value: UInt32(openSwiftUI_v2_os_versions) >> 32)
    static let v2_1: Semantics = .init(value: UInt32(openSwiftUI_v2_1_os_versions) >> 32)
    static let v2_3: Semantics = .init(value: UInt32(openSwiftUI_v2_3_os_versions) >> 32)
    static let v3: Semantics = .init(value: UInt32(openSwiftUI_v3_0_os_versions) >> 32)
    static let v3_2: Semantics = .init(value: UInt32(openSwiftUI_v3_2_os_versions) >> 32)
}

// ```cxx
// typedef uint32_t dyld_platform_t;
// typedef struct {
//    dyld_platform_t platform;
//    uint32_t version;
// } dyld_build_version_t;
// ```
let openSwiftUI_v1_os_versions: UInt64 = 0x07E3_0901_FFFF_FFFF
let openSwiftUI_autumn_2019_os_versions: UInt64 = 0x07E3_0902_FFFF_FFFF
let openSwiftUI_late_fall_2019_os_versions: UInt64 = 0x07E3_1015_FFFF_FFFF
let openSwiftUI_v1_3_1_os_versions: UInt64 = 0x07E3_1201_FFFF_FFFF
let openSwiftUI_v1_4_os_versions: UInt64 = 0x07E4_0301_FFFF_FFFF
let openSwiftUI_late_spring_2020_os_versions: UInt64 = 0x07E4_0415_FFFF_FFFF
let openSwiftUI_summer_2020_os_versions: UInt64 = 0x07E4_0601_FFFF_FFFF
let openSwiftUI_v2_os_versions: UInt64 = 0x07E4_0901_FFFF_FFFF
let openSwiftUI_v2_1_os_versions: UInt64 = 0x07E4_1015_FFFF_FFFF
let openSwiftUI_v2_3_os_versions: UInt64 = 0x07E5_0301_FFFF_FFFF
let openSwiftUI_v3_0_os_versions: UInt64 = 0x07E5_0901_FFFF_FFFF
let openSwiftUI_v3_2_os_versions: UInt64 = 0x07E5_1201_FFFF_FFFF
let openSwiftUI_v3_4_os_versions: UInt64 = 0x07E6_0301_FFFF_FFFF
