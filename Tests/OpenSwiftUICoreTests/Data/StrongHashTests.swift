//
//  StrongHashTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing
import Foundation
import OpenBoxShims

struct StrongHashTests {
    @Test(
        .serialized, // Workaround for Xcode 16.0 Bug. See swiftlang/swift-testing#749
        arguments: [
            ("", "#0907d8af90186095efbf55320d4b6b5eeea339da"),
            ("\n", "#fd61379f4f400f8059b2c6679b8b786bf08fb200"),
            ("测试", "#c0a5b9b6a2e6d6f6d704b050e17aa19eb63854a7"),
            (Data(), "#0907d8af90186095efbf55320d4b6b5eeea339da"),
            (Data([0x1, 0x2, 0x3, 0x4, 0x5, 0x6]), "#61d91e4a34fc38a843d3c7160ee74e8fad1b215d"),
            (Data(repeating: 0x1, count: 10), "#07911a602ff898e8fe5c51d292bfaf12b6e95a19"),
            ("{\"key_1\":1,\"key_2\":2}".data(using: .utf8)!, "#bbbe24fa5e9ae52d2bedfebeb4aeb3503aa9f879"),
            (false, "#4f78a2edf6430e42d721b5523ff9cfb09d3ca95b"),
            (true, "#f7df4179a1bb7134a153ac74dd46d2d830458bbf"),
        ] as [(any StronglyHashable, String)]
    )
    func stronglyHashableTypeConformance(value: any StronglyHashable, expected: String) {
        #expect(StrongHash(of: value).description == expected)
    }
    
    @Test(
        .serialized, // Workaround for Xcode 16.0 Bug. See swiftlang/swift-testing#749
        arguments: [
            (Int.zero, "#e9c707f1548655acc9e75955126f16535740fe05"),
            (UInt.zero, "#e9c707f1548655acc9e75955126f16535740fe05"),
            (Int8.zero, "#4f78a2edf6430e42d721b5523ff9cfb09d3ca95b"),
            (UInt8.zero, "#4f78a2edf6430e42d721b5523ff9cfb09d3ca95b"),
            (Int16.zero, "#29dfddd850854533323e8b1729a7dcc423f98914"),
            (UInt16.zero, "#29dfddd850854533323e8b1729a7dcc423f98914"),
            (Int32.zero, "#73e49952c2c5523e1b437351280a45e778ca6990"),
            (UInt32.zero, "#73e49952c2c5523e1b437351280a45e778ca6990"),
            (Int64.zero, "#e9c707f1548655acc9e75955126f16535740fe05"),
            (UInt64.zero, "#e9c707f1548655acc9e75955126f16535740fe05"),
            (Double.zero, "#e9c707f1548655acc9e75955126f16535740fe05"),
            (Double.infinity, "#9505e13fc84d63efeab1555b1e3dff2759d55e8b"),
            (UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, "#ff6650440d165ea1f0cd4bc45cbc03517cf229e1"),
        ] as [(any StronglyHashableByBitPattern, String)]
    )
    func stronglyHashableByBitPatternTypeConformance(value: any StronglyHashableByBitPattern, expected: String) {
        #expect(StrongHash(of: value).description == expected)
    }
    
    @Test
    func optionalAndRawRepresentableStronglyHashable() {
        struct R: RawRepresentable {
            let rawValue: Int
        }
        
        struct S: StronglyHashable {
            var optional: Int?
            var raw: R
            
            func hash(into hasher: inout StrongHasher) {
                optional.hash(into: &hasher)
                raw.hash(into: &hasher)
            }
        }
        
        let s1 = S(optional: nil, raw: R(rawValue: 0))
        #expect(StrongHash(of: s1).description == "#e9c707f1548655acc9e75955126f16535740fe05")

        let s2 = S(optional: 1, raw: R(rawValue: 0))
        #expect(StrongHash(of: s2).description == "#ac8406e346c41cd0b2d92058f277fa7725448841")
        
        let s3 = S(optional: 0, raw: R(rawValue: 1))
        #expect(StrongHash(of: s3).description == "#3f54ce362ece07da20aac0fd5fc3451507e81e03")
    }
    
    @Test
    func codable() throws {
        let src = StrongHash(of: 1)
        let encoded = try JSONEncoder().encode(src)
        let decoded = try JSONDecoder().decode(StrongHash.self, from: encoded)
        #expect(src == decoded)
    }
    
    @Test
    func hashable() {
        let s1 = StrongHash(of: 1)
        let s2 = StrongHash(of: 2)
        #expect(s1 != s2)
        #expect(s1 == StrongHash(of: 1))
    }
    
    @Test
    func encodableInit() throws {
        let data = "{\"key_1\":1,\"key_2\":2}".data(using: .utf8)!
        let s = StrongHash(of: data)        
        let d1 = ["key_1": 1, "key_2": 2]
        let d2 = ["key_2": 2, "key_1": 1]
        let s1 = try StrongHash(encodable: d1)
        let s2 = try StrongHash(encodable: d2)
        #expect(s1 == s)
        #expect(s2 == s)
    }
    
    @Test(
        arguments: [
            (StrongHash(), (0x00, 0x50, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80)),
            (StrongHash(of: 1), (0x3D, 0x58, 0x9E, 0xE2, 0x73, 0xBE, 0x13, 0x43, 0x7E, 0x7E, 0xCF, 0x76, 0x0F, 0x3F, 0xBD, 0x8D)),
        ]
    )
    func obUUID(hash: StrongHash, expectedBytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)) {
        let uuid = OBUUID(hash: hash)
        #expect(uuid.bytes.0 == expectedBytes.0)
        #expect(uuid.bytes.1 == expectedBytes.1)
        #expect(uuid.bytes.2 == expectedBytes.2)
        #expect(uuid.bytes.3 == expectedBytes.3)
        #expect(uuid.bytes.4 == expectedBytes.4)
        #expect(uuid.bytes.5 == expectedBytes.5)
        #expect(uuid.bytes.6 == expectedBytes.6)
        #expect(uuid.bytes.7 == expectedBytes.7)
        #expect(uuid.bytes.8 == expectedBytes.8)
        #expect(uuid.bytes.9 == expectedBytes.9)
        #expect(uuid.bytes.10 == expectedBytes.10)
        #expect(uuid.bytes.11 == expectedBytes.11)
        #expect(uuid.bytes.12 == expectedBytes.12)
        #expect(uuid.bytes.13 == expectedBytes.13)
        #expect(uuid.bytes.14 == expectedBytes.14)
        #expect(uuid.bytes.15 == expectedBytes.15)
    }
    
    @Test(
        arguments: [
            (StrongHash(), "0a140000000000000000000000000000000000000000"),
            (StrongHash(of: 1), "0a143da89ee273be13437e7ecf760f3fbd4dc0e8d1fe"),
        ]
    )
    func pbMessage(hash: StrongHash, hexString: String) throws {
        try hash.testPBEncoding(hexString: hexString)
        try hash.testPBDecoding(hexString: hexString)
    }
}
