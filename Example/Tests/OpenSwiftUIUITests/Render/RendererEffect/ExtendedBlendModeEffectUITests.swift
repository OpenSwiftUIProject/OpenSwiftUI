//
//  ExtendedBlendModeEffectUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ExtendedBlendModeEffectUITests {
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
            (.clear, "clear"),
            (.copy, "copy"),
            (.sourceIn, "sourceIn"),
            (.sourceOut, "sourceOut"),
            (.sourceAtop, "sourceAtop"),
            (.destinationOver, "destinationOver"),
            (.destinationIn, "destinationIn"),
            (.destinationOut, "destinationOut"),
            (.destinationAtop, "destinationAtop"),
            (.xor, "xor"),
            (.plusDarker, "plusDarker"),
            (.plusLighter, "plusLighter"),
        ] as [(GraphicsContext.BlendMode, String)]
    )
    func extendedBlendMode(_ blendMode: GraphicsContext.BlendMode, name: String) {
        openSwiftUIAssertSnapshot(
            of: ExtendedBlendModeRectanglesExample(blendMode: blendMode),
            drawHierarchyInKeyWindow: true,
            testName: "extended_blend_mode_\(name)"
        )
    }
}
