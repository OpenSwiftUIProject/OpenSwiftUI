//
//  FoundationProtobufMessageDualTests.swift
//  OpenSwiftUISymbolDualTests

#if canImport(SwiftUI, _underlyingVersion: 6.5.4)
import Foundation
import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

// MARK: - @_silgen_name declarations

extension URL {
    @_silgen_name("OpenSwiftUITestStub_URLEncode")
    func swiftUI_encode(to encoder: inout ProtobufEncoder) throws

    @_silgen_name("OpenSwiftUITestStub_URLDecode")
    init(swiftUI_from decoder: inout ProtobufDecoder) throws
}

extension UUID {
    @_silgen_name("OpenSwiftUITestStub_UUIDEncode")
    func swiftUI_encode(to encoder: inout ProtobufEncoder) throws

    @_silgen_name("OpenSwiftUITestStub_UUIDDecode")
    init(swiftUI_from decoder: inout ProtobufDecoder) throws
}

extension Data {
    @_silgen_name("OpenSwiftUITestStub_DataEncode")
    func swiftUI_encode(to encoder: inout ProtobufEncoder) throws

    @_silgen_name("OpenSwiftUITestStub_DataDecode")
    init(swiftUI_from decoder: inout ProtobufDecoder) throws
}

extension Locale {
    @_silgen_name("OpenSwiftUITestStub_LocaleEncode")
    func swiftUI_encode(to encoder: inout ProtobufEncoder) throws

    @_silgen_name("OpenSwiftUITestStub_LocaleDecode")
    init(swiftUI_from decoder: inout ProtobufDecoder) throws
}

// MARK: - Tests

@Suite
struct FoundationProtobufMessageDualTests {
    @Suite
    struct URLTests {
        @Test(
            arguments: [
                (
                    URL(string: "https://example.com")!,
                    "0a1368747470733a2f2f6578616d706c652e636f6d"
                ),
                (
                    URL(string: "path", relativeTo: URL(string: "https://example.com"))!,
                    "0a04706174681215 0a1368747470733a2f2f6578616d706c652e636f6d"
                        .replacingOccurrences(of: " ", with: "")
                ),
            ]
        )
        func pbMessage(url: URL, hexString: String) throws {
            try url.testPBEncoding(hexString: hexString)
            try url.testPBDecoding(hexString: hexString)
            try url.testPBEncoding(swiftUI_hexString: hexString)
            try url.testPBDecoding(swiftUI_hexString: hexString)
        }
    }

    @Suite
    struct UUIDTests {
        @Test(
            arguments: [
                (
                    UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
                    "0a10e621e1f8c36c495a93fc0c247a3e6e5f"
                ),
            ]
        )
        func pbMessage(uuid: UUID, hexString: String) throws {
            try uuid.testPBEncoding(hexString: hexString)
            try uuid.testPBDecoding(hexString: hexString)
            try uuid.testPBEncoding(swiftUI_hexString: hexString)
            try uuid.testPBDecoding(swiftUI_hexString: hexString)
        }
    }

    @Suite
    struct DataTests {
        @Test(
            arguments: [
                (Data(), ""),
                (Data([0x48, 0x65, 0x6c, 0x6c, 0x6f]), "120548656c6c6f"),
            ]
        )
        func pbMessage(data: Data, hexString: String) throws {
            try data.testPBEncoding(hexString: hexString)
            try data.testPBDecoding(hexString: hexString)
            try data.testPBEncoding(swiftUI_hexString: hexString)
            try data.testPBDecoding(swiftUI_hexString: hexString)
        }
    }

    @Suite
    struct LocaleTests {
        @Test(
            arguments: [
                (Locale(identifier: "en_US"), "0a05656e5f5553"),
            ]
        )
        func pbMessage(locale: Locale, hexString: String) throws {
            try locale.testPBEncoding(hexString: hexString)
            try locale.testPBDecoding(hexString: hexString)
            try locale.testPBEncoding(swiftUI_hexString: hexString)
            try locale.testPBDecoding(swiftUI_hexString: hexString)
        }
    }
}

// MARK: - SwiftUI Dual Test Helpers

extension URL {
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
        let decoded = try URL(swiftUI_from: &decoder)
        #expect(decoded == self)
    }
}

extension UUID {
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
        let decoded = try UUID(swiftUI_from: &decoder)
        #expect(decoded == self)
    }
}

extension Data {
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
        let decoded = try Data(swiftUI_from: &decoder)
        #expect(decoded == self)
    }
}

extension Locale {
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
        let decoded = try Locale(swiftUI_from: &decoder)
        #expect(decoded == self)
    }
}

#endif
