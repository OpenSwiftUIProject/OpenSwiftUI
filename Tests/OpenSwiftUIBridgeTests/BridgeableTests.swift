//
//  BridgeableTests.swift
//  OpenSwiftUIBridgeTests

import Testing
import OpenSwiftUIBridge

struct BridgeableTests {
    @Test
    func example() throws {
        struct A1: Bridgeable, Equatable {
            typealias Counterpart = A2
            var value: Int
            
            init(value: Int) {
                self.value = value
            }
            
            init(_ counterpart: A2) {
                self.value = counterpart.value
            }
        }
        
        struct A2: Bridgeable, Equatable {
            typealias Counterpart = A1
            var value: Int
            
            init(value: Int) {
                self.value = value
            }
            
            init(_ counterpart: A1) {
                self.value = counterpart.value
            }
        }
        let a1 = A1(value: 3)
        let a2 = A2(value: 3)
        
        #expect(a1.counterpart == a2)
        #expect(a2.counterpart == a1)
    }
}
