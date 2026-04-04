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
        ] as [(String, CodableAnimation, String)]
    )
    func pbMessage(label: String, animation: CodableAnimation, hexString: String) throws {
        try animation.testPBEncoding(hexString: hexString)
        try animation.testPBDecoding(hexString: hexString)
    }
}
