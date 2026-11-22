//
//  Data+ExtensionTests.swift
//  OpenSwiftUICoreTests

import CoreFoundation
import Foundation
@testable import OpenSwiftUICore
import Testing

struct Data_ExtensionTests {
    @Test
    func roundTripAcrossRepresentations() {
        let full = Data((0..<64).map { UInt8($0 + 10) })
        let cases: [Data] = [
            Data(),
            Data([1, 2, 3, 4]),
            Data((0..<128).map { UInt8($0) }),
            full[7..<39],
        ]

        for expected in cases {
            let cfData = expected.cfData
            #expect(CFGetTypeID(cfData) == CFDataGetTypeID())
            let length = CFDataGetLength(cfData)
            #expect(length == expected.count)

            var extracted = [UInt8](repeating: 0, count: length)
            if length > 0 {
                CFDataGetBytes(cfData, CFRange(location: 0, length: length), &extracted)
            }
            #expect(extracted == Array(expected))
            #expect(Data(cfData: cfData) == expected)
        }
    }

    @Test
    func initFromCFDataPreservesValueSemantics() throws {
        let bytes: [UInt8] = [10, 20, 30, 40]
        let immutable = try #require(CFDataCreate(nil, bytes, bytes.count))
        #expect(Array(Data(cfData: immutable)) == bytes)

        let mutable = try #require(CFDataCreateMutable(nil, 0))
        CFDataAppendBytes(mutable, bytes, bytes.count)
        let bridged = Data(cfData: mutable)
        if let mutablePtr = CFDataGetMutableBytePtr(mutable) {
            mutablePtr[0] = 99
        }
        #expect(Array(bridged) == bytes)
    }
}
