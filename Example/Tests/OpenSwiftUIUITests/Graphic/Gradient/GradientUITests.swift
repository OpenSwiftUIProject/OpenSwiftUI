//
//  GradientUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct GradientUITests {
    @Test(arguments: GradientExample.Kind.allCases)
    func concreteStyles(kind: GradientExample.Kind) {
        openSwiftUIAssertSnapshot(
            of: GradientExample(kind: kind),
            testName: "concrete_\(kind.rawValue)"
        )
    }

    @Test(
        arguments: GradientExample.Kind.allCases,
        [(Gradient.ColorSpace.device, "device"), (.perceptual, "perceptual")]
    )
    func erasedStyles(kind: GradientExample.Kind, space: (Gradient.ColorSpace, String)) {
        openSwiftUIAssertSnapshot(
            of: GradientExample(kind: kind, usesAnyGradient: true, colorSpace: space.0),
            testName: "erased_\(kind.rawValue)_\(space.1)"
        )
    }

    @Test(arguments: [GradientExample.Palette.stops, .transparent, .single, .empty])
    func stopLayouts(palette: GradientExample.Palette) {
        openSwiftUIAssertSnapshot(
            of: GradientExample(palette: palette),
            testName: "stops_\(palette.rawValue)"
        )
    }

    @Test
    func gradientAsShapeStyle() {
        openSwiftUIAssertSnapshot(
            of: Rectangle().fill(Gradient(colors: [.red, .green, .blue]))
                .frame(width: 160, height: 120)
        )
    }

    @Test
    func anyGradientAsShapeStyle() {
        openSwiftUIAssertSnapshot(
            of: Rectangle().fill(AnyGradient(Gradient(colors: [.red, .green, .blue])))
                .frame(width: 160, height: 120)
        )
    }

    @Test(arguments: [GradientExample.Kind.linear, .radial, .elliptical, .angular])
    func animation(kind: GradientExample.Kind) {
        openSwiftUIAssertAnimationSnapshot(
            of: AnimatedGradient(kind: kind),
            testName: "animation_\(kind.rawValue)"
        )
    }

    private struct AnimatedGradient: AnimationTestView {
        nonisolated static var model: AnimationTestModel {
            AnimationTestModel(duration: 1, count: 4)
        }

        var kind: GradientExample.Kind
        @State private var alternate = false

        var body: some View {
            GradientExample(kind: kind, alternate: alternate)
                .animation(.linear(duration: Self.model.duration), value: alternate)
                .onAppear { alternate = true }
        }
    }
}
