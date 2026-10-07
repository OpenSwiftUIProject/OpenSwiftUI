//
//  BlendModeEffectUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct BlendModeEffectUITests {
    @Test(
        arguments: [
            (.normal, "normal"),
            (.multiply, "multiply"),
            (.screen, "screen"),
            (.overlay, "overlay"),
            (.darken, "darken"),
            (.lighten, "lighten"),
            (.colorDodge, "colorDodge"),
            (.colorBurn, "colorBurn"),
            (.softLight, "softLight"),
            (.hardLight, "hardLight"),
            (.difference, "difference"),
            (.exclusion, "exclusion"),
            (.hue, "hue"),
            (.saturation, "saturation"),
            (.color, "color"),
            (.luminosity, "luminosity"),
            (.sourceAtop, "sourceAtop"),
            (.destinationOver, "destinationOver"),
            (.destinationOut, "destinationOut"),
            (.plusDarker, "plusDarker"),
            (.plusLighter, "plusLighter"),
        ] as [(BlendMode, String)]
    )
    func blendMode(_ blendMode: BlendMode, name: String) {
        openSwiftUIAssertSnapshot(
            of: BlendModeRectanglesExample(blendMode: blendMode),
            drawHierarchyInKeyWindow: true,
            testName: "blend_mode_\(name)"
        )
    }
}
