//
//  AccessibilityTextDualTests.swift
//  OpenSwiftUISymbolDualTests

#if canImport(SwiftUI, _underlyingVersion: 6.5.4)
import Foundation
@testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

// MARK: - @_silgen_name declarations

extension AccessibilityText {
    @_silgen_name("OpenSwiftUITestStub_AccessibilityTextEncode")
    func swiftUI_encode(to encoder: inout ProtobufEncoder) throws

    @_silgen_name("OpenSwiftUITestStub_AccessibilityTextDecode")
    init(swiftUI_from decoder: inout ProtobufDecoder) throws
}

// MARK: - AccessibilityText Dual Tests

@Suite
struct AccessibilityTextDualTests {
    @Test(
        arguments: [
            // Both fields hold their default value, so nothing is emitted.
            ("empty", AccessibilityText(storage: .plain(""), optional: false), "", nil),
            // 0a = (1 << 3) | .lengthDelimited, 02 = length, 6869 = "hi"
            ("plain", AccessibilityText(storage: .plain("hi"), optional: false), "0a026869", nil),
            // 18 = (3 << 3) | .varint
            ("optional", AccessibilityText(storage: .plain(""), optional: true), "1801", nil),
            ("plainOptional", AccessibilityText(storage: .plain("hi"), optional: true), "0a0268691801", nil),
            // 20 = (4 << 3) | .varint, an unknown field that must be skipped.
            ("unknownField", AccessibilityText(storage: .plain("hi"), optional: false), "0a026869", "0a0268692001"),
        ] as [(String, AccessibilityText, String, String?)]
    )
    func pbMessage(
        label: String,
        value: AccessibilityText,
        hexString: String,
        decodingHexString: String?
    ) throws {
        try value.testPBEncoding(hexString: hexString)
        try value.testPBEncoding(swiftUI_hexString: hexString)
        try value.testPBDecoding(hexString: decodingHexString ?? hexString)
        try value.testPBDecoding(swiftUI_hexString: decodingHexString ?? hexString)
    }
}

// MARK: - SwiftUI Dual Test Helpers

extension AccessibilityText {
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
        let decoded = try AccessibilityText(swiftUI_from: &decoder)
        #expect(decoded == self)
    }
}

#endif
