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
            (
                "scale",
                CodableEffectAnimation(
                    base: DisplayList.ScaleAnimation(
                        from: _ScaleEffect(scale: CGSize(width: 1, height: 1), anchor: .center),
                        to: _ScaleEffect(scale: CGSize(width: 2, height: 2), anchor: .center),
                        animation: Animation(DefaultAnimation())
                    )
                ),
                "12140a00120c0a0a0d0000004015000000401a023a00"
            ),
            (
                "rotation",
                CodableEffectAnimation(
                    base: DisplayList.RotationAnimation(
                        from: _RotationEffect(angle: .zero, anchor: .center),
                        to: _RotationEffect(angle: .degrees(90), anchor: .center),
                        animation: Animation(DefaultAnimation())
                    )
                ),
                "1a110a00120909182d4454fb21f93f1a023a00"
            ),
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
        ] as [(String, CodableEffectAnimation, String)]
    )
    func pbMessage(label: String, value: CodableEffectAnimation, hexString: String) throws {
        try value.testPBEncoding(hexString: hexString)
        try value.testPBDecoding(hexString: hexString)
    }
}
