//
//  BitVectorTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Testing

struct BitVectorTests {
    @Test(arguments: [0, 1, 60, 64])
    func testInlineKind(count: Int) {
        var bitVector = BitVector(count: count)
        #expect(bitVector.count == count)
        #expect(bitVector.vector.rawValue == 0)
        #expect(bitVector.array == [])
        
        for (index, value) in bitVector.enumerated() {
            #expect(value == false)
            bitVector[index] = true
        }
        for value in bitVector {
            #expect(value == true)
        }
        
        if count == 0 {
            #expect(bitVector.vector.rawValue == 0)
        } else {
            #expect(bitVector.vector.rawValue > 0)
        }
        #expect(bitVector.array == [])
    }
    
    @Test(arguments: [
        (count: 65, arrayCount: 2),
        (count: 128, arrayCount: 2),
        (count: 129, arrayCount: 3),
    ])
    func testArrayKind(count: Int, arrayCount: Int) {
        var bitVector = BitVector(count: count)
        #expect(bitVector.count == count)
        #expect(bitVector.vector.rawValue == 0)
        #expect(bitVector.array.count == arrayCount)
        for (index, value) in bitVector.enumerated() {
            #expect(value == false)
            bitVector[index] = true
        }
        for value in bitVector {
            #expect(value == true)
        }
        
        #expect(bitVector.vector.rawValue == 0)
        #expect(bitVector.array.map(\.rawValue).allSatisfy { $0 > 0 })
    }
}
