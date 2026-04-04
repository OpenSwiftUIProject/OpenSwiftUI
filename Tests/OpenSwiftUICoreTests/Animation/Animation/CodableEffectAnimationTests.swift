//
//  CodableEffectAnimationTests.swift
//  OpenSwiftUICoreTests

import Foundation
@testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

// MARK: - CodableEffectAnimationTests

struct CodableEffectAnimationTests {
    @Test(
        arguments: [
            (
                "opacity",
                CodableEffectAnimation(
                    base: DisplayList.OpacityAnimation(
                        from: _OpacityEffect(opacity: 0.0),
                        to: _OpacityEffect(opacity: 1.0),
                        animation: Animation(DefaultAnimation())
                    )
                ),
                "220d0a050d0000000012001a023a00"
            ),
            (
                "offset",
                CodableEffectAnimation(
                    base: DisplayList.OffsetAnimation(
                        from: _OffsetEffect(offset: .zero),
                        to: _OffsetEffect(offset: CGSize(width: 10, height: 20)),
                        animation: Animation(DefaultAnimation())
                    )
                ),
                "0a140a00120c0a0a0d00002041150000a0411a023a00"
            ),
        ] as [(String, CodableEffectAnimation, String)]
    )
    func pbMessage(label: String, value: CodableEffectAnimation, hexString: String) throws {
        try value.testPBEncoding(hexString: hexString)
        try value.testPBDecoding(hexString: hexString)
    }
}
