//
//  CACompositingFilterTests.swift
//  OpenSwiftUI_SPITests

import Foundation
#if canImport(QuartzCore)
import QuartzCore_Private
#endif
import Testing

#if canImport(QuartzCore)
struct CACompositingFilterTests {
    @Test(arguments: [
        (1, "multiplyBlendMode"),
        (2, "screenBlendMode"),
        (3, "overlayBlendMode"),
        (4, "darkenBlendMode"),
        (5, "lightenBlendMode"),
        (6, "colorDodgeBlendMode"),
        (7, "colorBurnBlendMode"),
        (8, "softLightBlendMode"),
        (9, "hardLightBlendMode"),
        (10, "differenceBlendMode"),
        (11, "exclusionBlendMode"),
        (12, "hueBlendMode"),
        (13, "saturationBlendMode"),
        (14, "colorBlendMode"),
        (15, "luminosityBlendMode"),
        (16, "clear"),
        (17, "copy"),
        (18, "sourceIn"),
        (19, "sourceOut"),
        (20, "sourceAtop"),
        (21, "destOver"),
        (22, "destIn"),
        (23, "destOut"),
        (24, "destAtop"),
        (25, "xor"),
        (26, "plusD"),
        (27, "plusL"),
        (1000, "linearDodgeBlendMode"),
        (1001, "linearBurnBlendMode"),
        (1002, "linearLightBlendMode"),
        (1003, "pinLightBlendMode"),
        (1004, "subtractBlendMode"),
        (1005, "divideBlendMode"),
        (1006, "maximum"),
        (1010, "darkenSourceOver"),
        (1011, "lightenSourceOver"),
    ] as [(Int32, String)], [false, true])
    func knownModes(_ value: (Int32, String), compositingGroup: Bool) {
        let filter = ORBBlendModeGetCompositingFilter(.init(rawValue: value.0), compositingGroup: compositingGroup)
        #expect(filter as? String == value.1)
        #expect(CACompositingFilterGetORBBlendMode(value.1).rawValue == value.0)
        #expect(CACompositingFilterGetORBBlendMode(NSMutableString(string: value.1)).rawValue == value.0)
    }

    @Test(arguments: [
        Int32.min, -1, 0, 28, 999, 1007, 1008, 1009, 1012, 1013, 2000, Int32.max,
    ], [false, true])
    func unmappedModes(_ mode: Int32, compositingGroup: Bool) {
        #expect(ORBBlendModeGetCompositingFilter(.init(rawValue: mode), compositingGroup: compositingGroup) == nil)
    }

    @Test
    func absentFilter() {
        #expect(CACompositingFilterGetORBBlendMode(nil).rawValue == 0)
    }

    @Test(arguments: [
        "", "normal", "sourceOver", "colorBurn", "ColorBurnBlendMode",
        "colorBurnBlendMode ", "colorBurnBlendMode\0", "gaussianBlur",
        "minimum", "passThrough", "unknown",
    ])
    func unrecognizedFilters(_ name: String) {
        #expect(CACompositingFilterGetORBBlendMode(name).rawValue == -1)
    }
}
#endif
