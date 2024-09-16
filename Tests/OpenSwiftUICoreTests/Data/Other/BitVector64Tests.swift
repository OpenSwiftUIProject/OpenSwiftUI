//
//  BitVector64Tests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
import Testing

struct BitVector64Tests {
    @Test
    func testInit() {
        let bitVector = BitVector64()
        #expect(bitVector.rawValue == 0)
    }

    @Test(arguments: [
        (rawValue: 0x1, index: 0),
        (rawValue: 0x2, index: 1),
        (rawValue: 0x4, index: 2),
        (rawValue: 0x8, index: 3),
        (rawValue: 0x10, index: 4),
        (rawValue: 0x20, index: 5),
        (rawValue: 0x40, index: 6),
        (rawValue: 0x80, index: 7),
        (rawValue: 0x100, index: 8),
        (rawValue: 0x200, index: 9),
    ])
    func testSubscriptGetter(rawValue: UInt64, index: Int) {
        let bitVector = BitVector64(rawValue: rawValue)
        for i in 0..<64 {
            if i == index {
                #expect(bitVector[i] == true)
            } else {
                #expect(bitVector[i] == false)
            }
        }
    }

    @Test
    func testSubscriptSetter() {
        var bitVector = BitVector64(rawValue: 0)
        bitVector.rawValue = 4
        #expect(bitVector[0] == false)
        #expect(bitVector[1] == false)
        #expect(bitVector[2] == true)

        bitVector[0] = true
        #expect(bitVector[0] == true)
        #expect(bitVector[1] == false)
        #expect(bitVector[2] == true)
        #expect(bitVector.rawValue == 5)

        bitVector[1] = true
        #expect(bitVector[0] == true)
        #expect(bitVector[1] == true)
        #expect(bitVector[2] == true)
        #expect(bitVector.rawValue == 7)

        bitVector[2] = false
        #expect(bitVector[0] == true)
        #expect(bitVector[1] == true)
        #expect(bitVector[2] == false)
        #expect(bitVector.rawValue == 3)
    }
    
    @Test
    func testMapBool() {
        let array = [Bool.random(), Bool.random(), Bool.random(), Bool.random()]
        let bitVector = array.mapBool { $0 }
        for i in 0..<array.count {
            #expect(bitVector[i] == array[i])
        }
    }
}
