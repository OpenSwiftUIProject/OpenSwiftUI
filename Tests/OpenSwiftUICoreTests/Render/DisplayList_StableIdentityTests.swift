//
//  DisplayList_StableIdentityTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

@_spi(Debug) import OpenGraphShims

struct DisplayList_StableIdentityTests {
    @Test
    func formUnion() {        
        var m1 = _DisplayList_StableIdentityMap()
        var m2 = _DisplayList_StableIdentityMap()

        let identity = _DisplayList_Identity(decodedValue: 1)
        m1[identity] = .init(hash: .init(of: 1), serial: 1)
        m2[identity] = .init(hash: .init(of: 2), serial: 2)

        m1.formUnion(m2)
        
        #expect(m1[identity] == .init(hash: .init(of: 1), serial: 1))
    }
}
