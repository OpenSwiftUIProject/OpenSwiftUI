//
//  VisualRendererEffectUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct VisualRendererEffectUITests {
    @Test(arguments: [false, true])
    func blur(opaque: Bool) {
        openSwiftUIAssertSnapshot(
            of: VisualRendererEffectExample(effect: .blur(opaque: opaque)),
            drawHierarchyInKeyWindow: true,
            testName: opaque ? "blur_opaque" : "blur_transparent"
        )
    }

    @Test(arguments: [(.multiply, "multiply"), (.screen, "screen")] as [(BlendMode, String)])
    func blendMode(_ mode: BlendMode, name: String) {
        openSwiftUIAssertSnapshot(
            of: VisualRendererEffectExample(effect: .blendMode(mode)),
            drawHierarchyInKeyWindow: true,
            testName: "blend_mode_\(name)"
        )
    }

    @Test(
        arguments: [
            (.brightnessThenContrast, "brightness_then_contrast"),
            (.contrastThenBrightness, "contrast_then_brightness"),
        ] as [(VisualRendererEffectExample.Effect, String)]
    )
    func effectOrder(_ effect: VisualRendererEffectExample.Effect, name: String) {
        openSwiftUIAssertSnapshot(
            of: VisualRendererEffectExample(effect: effect),
            drawHierarchyInKeyWindow: true,
            testName: name
        )
    }
}
