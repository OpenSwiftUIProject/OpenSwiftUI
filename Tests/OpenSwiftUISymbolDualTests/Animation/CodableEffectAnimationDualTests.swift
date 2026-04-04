//
//  CodableAnimationDualTests.swift
//  OpenSwiftUISymbolDualTests

#if canImport(SwiftUI, _underlyingVersion: 6.5.4)
import Foundation
@testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

// MARK: - @_silgen_name declarations

extension CodableEffectAnimation {
    @_silgen_name("OpenSwiftUITestStub_CodableEffectAnimationEncode")
    func swiftUI_encode(to encoder: inout ProtobufEncoder) throws

    @_silgen_name("OpenSwiftUITestStub_CodableEffectAnimationDecode")
    init(swiftUI_from decoder: inout ProtobufDecoder) throws
}

// MARK: - CodableEffectAnimation Dual Tests

@Suite
struct CodableEffectAnimationDualTests {
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
        try value.testPBEncoding(swiftUI_hexString: hexString)
        try value.testPBDecoding(swiftUI_hexString: hexString)
    }
}

// MARK: - SwiftUI Dual Test Helpers

extension CodableEffectAnimation {
    func testPBEncoding(swiftUI_hexString expectedHexString: String) throws {
        let data = try ProtobufEncoder.encoding { encoder in
            try swiftUI_encode(to: &encoder)
        }
        #expect(data.hexString == expectedHexString)
    }

    func testPBDecoding(swiftUI_hexString hexString: String) throws {
        guard let data = Data(hexString: hexString) else {
            throw ProtobufDecoder.DecodingError.failed
        }
        var decoder = ProtobufDecoder(data)
        let decoded = try CodableEffectAnimation(swiftUI_from: &decoder)
        let reEncoded = try ProtobufEncoder.encoding { encoder in
            try decoded.swiftUI_encode(to: &encoder)
        }
        #expect(reEncoded.hexString == hexString)
    }
}

#endif
