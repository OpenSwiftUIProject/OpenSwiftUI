//
//  RepeatAnimationDualTests.swift
//  OpenSwiftUISymbolDualTests

#if canImport(SwiftUI, _underlyingVersion: 6.5.4)
import Testing
@_spi(ForOpenSwiftUIOnly)
@testable
import OpenSwiftUICore

extension CustomAnimationModifiedContent {
    @_silgen_name("OpenSwiftUITestStub_CustomAnimationModifiedContentProtobufEncode")
    func swiftUI_encode(to encoder: inout ProtobufEncoder) throws
}

struct RepeatAnimationDualTests {
    @Test(
        arguments: [
            (RepeatAnimation(autoreverses: false), "3a00"),
            (RepeatAnimation(autoreverses: true), "3a00"),
            (RepeatAnimation(repeatCount: .min, autoreverses: false), "3a00"),
            (RepeatAnimation(repeatCount: 0, autoreverses: false), "3a00"),
            (RepeatAnimation(repeatCount: 1, autoreverses: false), "3a00"),
        ]
    )
    func pbEncodeMessage(r: RepeatAnimation, hexString: String) throws {
        let animation = CustomAnimationModifiedContent(base: DefaultAnimation(), modifier: r)
        try animation.testPBEncoding(hexString: hexString)
        try animation.testPBEncoding(swiftUI_hexString: hexString)
    }
}


extension CustomAnimationModifiedContent {
    func testPBEncoding(swiftUI_hexString expectedHexString: String) throws {
        let data = try ProtobufEncoder.encoding { encoder in
            try swiftUI_encode(to: &encoder)
        }
        #expect(data.hexString == expectedHexString)
    }
}
#endif
