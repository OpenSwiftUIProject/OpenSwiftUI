//
//  ColorEffectUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ColorEffectUITests {
    @Test(
        arguments: [
            (.brightness, -0.25, "brightness_negative"),
            (.brightness, 0.25, "brightness_positive"),
            (.contrast, 0, "contrast_zero"),
            (.contrast, -1, "contrast_negative"),
            (.grayscale, 0.5, "grayscale_partial"),
            (.grayscale, 1, "grayscale_full"),
            (.hueRotation, 90, "hue_positive"),
            (.hueRotation, -90, "hue_negative"),
            (.saturation, 0, "saturation_zero"),
            (.saturation, 1.5, "saturation_increased"),
        ] as [(ColorEffectExample.Effect, Double, String)],
        [false, true]
    )
    func colorEffect(
        _ testCase: (ColorEffectExample.Effect, Double, String),
        usesVisualEffect: Bool
    ) {
        let (effect, amount, name) = testCase
        let path = usesVisualEffect ? "visual" : "view"
        openSwiftUIAssertSnapshot(
            of: ColorEffectExample(
                effect: effect,
                amount: amount,
                usesVisualEffect: usesVisualEffect
            ),
            drawHierarchyInKeyWindow: true,
            rasterizeOnMacOS: true,
            testName: "\(path)_\(name)"
        )
    }
}
