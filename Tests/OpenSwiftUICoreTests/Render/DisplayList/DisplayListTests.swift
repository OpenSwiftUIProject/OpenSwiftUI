//
//  DisplayListTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenSwiftUICore
import Testing

@MainActor
struct DisplayListTests {
    @Test
    func version() {
        typealias Version = DisplayList.Version
        let v0 = Version()
        let v1 = Version(decodedValue: 999)
        let v2 = Version(forUpdate: ())
        #expect(v0.value == 0)
        #expect(v1.value == 999)
        #expect(v2.value == 1000)
        #expect(v1 < v2)
        
        var combineVersion = v0
        #expect(combineVersion.value == 0)
        combineVersion.combine(with: v1)
        #expect(combineVersion.value == 999)        
    }
}
