//
//  CodableAnimationTests.swift
//  OpenSwiftUICoreTests

import Foundation
@testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

// MARK: - CodableAnimationTests

struct CodableAnimationTests {
    @Test(
        arguments: [
            ("default", CodableAnimation(base: Animation(DefaultAnimation())), "3a00"),
            (
                "bezier",
                CodableAnimation(
                    base: Animation(BezierAnimation(
                        curve: .init(
                            startControlPoint: UnitPoint(x: 0.42, y: 0.0),
                            endControlPoint: UnitPoint(x: 0.58, y: 1.0)
                        ),
                        duration: 0.3
                    ))
                ),
                "0a2609333333333333d33f121b09e17a14ae47e1da3f198fc2f5285c8fe23f21000000000000f03f"
            ),
            (
                "spring",
                CodableAnimation(base: Animation(SpringAnimation(mass: 1.0, stiffness: 100.0, damping: 10.0))),
                "1209190000000000002440"
            ),
            (
                "fluidSpring",
                CodableAnimation(
                    base: Animation(FluidSpringAnimation(response: 0.5, dampingFraction: 0.8, blendDuration: 0.0))
                ),
                "1a1209000000000000e03f119a9999999999e93f"
            ),
            (
                "delay",
                CodableAnimation(base: Animation(DefaultAnimation()).delay(0.5)),
                "3a0021000000000000e03f"
            ),
            (
                "repeatCount",
                CodableAnimation(base: Animation(DefaultAnimation()).repeatCount(3, autoreverses: true)),
                "3a002a0408061001"
            ),
            (
                "repeatForever",
                CodableAnimation(base: Animation(DefaultAnimation()).repeatForever(autoreverses: false)),
                "3a002a00"
            ),
            (
                "speed",
                CodableAnimation(base: Animation(DefaultAnimation()).speed(2.0)),
                "3a00310000000000000040"
            ),
        ] as [(String, CodableAnimation, String)]
    )
    func pbMessage(label: String, animation: CodableAnimation, hexString: String) throws {
        try animation.testPBEncoding(hexString: hexString)
        try animation.testPBDecoding(hexString: hexString)
    }
}
