//
//  BezierAnimationTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing
import Numerics

// MARK: - BezierAnimationTests

struct BezierAnimationTests {
    @Test(
        .bug(
            "https://github.com/OpenSwiftUIProject/OpenSwiftUI/issues/459",
            id: "459",
            "BezierAnimation's fraction is behavior like a fixed 1 time duration animation"
        )
    )
    func fraction() throws {
        let animation = BezierAnimation(
            curve: .init(
                startControlPoint: .topLeading,
                endControlPoint: .bottomTrailing
            ),
            duration: 100
        )
        let f1 = try #require(animation.fraction(for: 10.0))
        let f2 = try #require(animation.fraction(for: 50.0))
        #expect(f1.isApproximatelyEqual(to: 0.1, absoluteTolerance: 0.01))
        #expect(f2.isApproximatelyEqual(to: 0.5, absoluteTolerance: 0.01))
    }
}
