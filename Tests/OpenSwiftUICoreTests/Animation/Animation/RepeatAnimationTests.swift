//
//  RepeatAnimationTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Testing

struct RepeatAnimationTests {
    // NOTE: NO dual test since RepeatAnimation related symbols is t (Local text section symbol) which means it can't be located by SymbolLocator
    @Test(
        arguments: [
            (nil, false, "2a00"),
            (nil, true, "2a021001"),
            (Int.min, false, "2a00"),
            (Int.min, true, "2a021001"),
            (0, false, "2a020800"),
            (0, true, "2a0408001001"),
            (1, false, "2a020802"),
            (1, true, "2a0408021001"),
        ] as [(Int?, Bool, String)]
    )
    func pbEncodeMessage(repeatCount: Int?, autoreverses: Bool, hexString: String) throws {
        let animation = RepeatAnimation(repeatCount: repeatCount, autoreverses: autoreverses)
        try animation.testPBEncoding(hexString: hexString)
    }
}
