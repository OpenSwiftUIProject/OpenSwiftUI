//
//  AnyHashable2Tests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

struct AnyHashable2Tests {
    @Test
    func value() {
        struct ValueA: Hashable {
            var value: Int
        }
        
        struct ValueB: Hashable {
            var value: Int
        }
        
        let valueA = ValueA(value: 1)
        let valueB = ValueB(value: 1)
        
        let anyHashableA = AnyHashable(valueA)
        let anyHashableB = AnyHashable(valueB)
        
        let anyHashable2A = AnyHashable2(valueA)
        let anyHashable2B = AnyHashable2(valueB)
        
        #expect(anyHashableA.hashValue == anyHashableB.hashValue)
        #expect(anyHashableA != anyHashableB)

        #expect(anyHashable2A.hashValue != anyHashable2B.hashValue)
        #expect(anyHashable2A != anyHashable2B)
    }
}
