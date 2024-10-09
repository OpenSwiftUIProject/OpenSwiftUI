//
//  ProtobufDecoderTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing
import Foundation

struct ProtobufDecoderTests {
    @Test
    func boolDecode() throws {
        #expect(try "".decodePBHexString(BoolMessage.self) == BoolMessage(value: false))
        #expect(try "0800".decodePBHexString(BoolMessage.self) == BoolMessage(value: false))
        #expect(try "0801".decodePBHexString(BoolMessage.self) == BoolMessage(value: true))
    }
    
    @Test
    func enumEncode() throws {
        #expect(try "0800".decodePBHexString(EnumMessage.self).value == .a)
        #expect(try "0801".decodePBHexString(EnumMessage.self).value == .b)
        
        #expect(try "".decodePBHexString(EnumEquatableMessage.self).value == .a)
        #expect(try "0800".decodePBHexString(EnumEquatableMessage.self).value == .a)
        #expect(try "0801".decodePBHexString(EnumEquatableMessage.self).value == .b)
    }
    
    @Test
    func intDecode() throws {
        #expect(try "".decodePBHexString(IntegerMessage.self) == IntegerMessage())
        #expect(try "0801".decodePBHexString(IntegerMessage.self) == IntegerMessage(intValue: -1))
        #expect(try "0802".decodePBHexString(IntegerMessage.self) == IntegerMessage(intValue: 1))
        #expect(try "1002".decodePBHexString(IntegerMessage.self) == IntegerMessage(unsignedIntValue: 2))
        #expect(try "1806".decodePBHexString(IntegerMessage.self) == IntegerMessage(int64Value: 3))
        #expect(try "2004".decodePBHexString(IntegerMessage.self) == IntegerMessage(unsignedInt64Value: 4))
        #expect(try "2d05000000".decodePBHexString(IntegerMessage.self) == IntegerMessage(int32Value: 5))
        #expect(try "3506000000".decodePBHexString(IntegerMessage.self) == IntegerMessage(unsignedInt32Value: 6))
        #expect(try "08021002180620042d050000003506000000".decodePBHexString(IntegerMessage.self) == IntegerMessage(intValue: 1, unsignedIntValue: 2, int64Value: 3, unsignedInt64Value: 4, int32Value: 5, unsignedInt32Value: 6))
        #expect(try "0890a204".decodePBHexString(IntegerMessage.self) == IntegerMessage(intValue: 0x8888))
    }
    
    @Test
    func skipInvalidTagDecode() throws {
        #expect(try "38000801".decodePBHexString(IntegerMessage.self) == IntegerMessage(intValue: -1))
        #expect(try "40000801".decodePBHexString(IntegerMessage.self) == IntegerMessage(intValue: -1))
        #expect(try "48000801".decodePBHexString(IntegerMessage.self) == IntegerMessage(intValue: -1))
        #expect(try "50000801".decodePBHexString(IntegerMessage.self) == IntegerMessage(intValue: -1))
        #expect(try "58000801".decodePBHexString(IntegerMessage.self) == IntegerMessage(intValue: -1))
        #expect(try "60000801".decodePBHexString(IntegerMessage.self) == IntegerMessage(intValue: -1))
        #expect(try "68000801".decodePBHexString(IntegerMessage.self) == IntegerMessage(intValue: -1))
        #expect(try "70000801".decodePBHexString(IntegerMessage.self) == IntegerMessage(intValue: -1))
        #expect(try "78000801".decodePBHexString(IntegerMessage.self) == IntegerMessage(intValue: -1))
        #expect(try "8001000801".decodePBHexString(IntegerMessage.self) == IntegerMessage(intValue: -1))
    }
    
    @Test
    func floatDecode() throws {
        #expect(try "".decodePBHexString(FloatPointMessage.self) == FloatPointMessage())
        #expect(try "0d00ff7f47".decodePBHexString(FloatPointMessage.self) == FloatPointMessage(float: 65536.0 - 1))
        #expect(try "1d00ff7f47".decodePBHexString(FloatPointMessage.self) == FloatPointMessage(cgFloat: 65536.0 - 1))
        
        #expect(try "0d80008047".decodePBHexString(FloatPointMessage.self) == FloatPointMessage(float: 65536.0 + 1))
        #expect(try "11000000001000f040".decodePBHexString(FloatPointMessage.self) == FloatPointMessage(double: 65536.0 + 1))
        #expect(try "19000000001000f040".decodePBHexString(FloatPointMessage.self) == FloatPointMessage(cgFloat: 65536.0 + 1))
    }
    
    @Test
    func dataDecode() throws {
        #expect(try "".decodePBHexString(DataMessage.self) == DataMessage())
        #expect(try "0a04ffffffff".decodePBHexString(DataMessage.self) == DataMessage(data: .init(repeating: UInt8(0xFF), count: 4)))
        #expect(try "0a028888".decodePBHexString(DataMessage.self) == DataMessage(data: .init(repeating: UInt8(0x88), count: 2)))
    }
    
    @Test
    func packedDecode() throws {
        #expect(try "".decodePBHexString(PackedIntMessage.self).values == [])
        #expect(try "0a0400108002".decodePBHexString(PackedIntMessage.self).values == [0, 8, 128])
        #expect(try "0a020010".decodePBHexString(PackedIntMessage.self).values == [0, 8])
    }
    
    @Test
    func stringDecode() throws {
        #expect(try "0a0141".decodePBHexString(StringMessage.self).string == "A")
        #expect(try "0a0b4f70656e53776966745549".decodePBHexString(StringMessage.self).string == "OpenSwiftUI")
        #expect(try "0a0ae6b58be8af95f09f918b".decodePBHexString(StringMessage.self).string == "测试👋")
    }
    
    @Test
    func codableDecode() throws {
        let expectedForZero = "0a2e62706c6973743030a1011000080a000000000000010100000000000000020000000000000000000000000000000c"
        let expectedForOne = "0a2e62706c6973743030a1011001080a000000000000010100000000000000020000000000000000000000000000000c"
        
        #expect(try expectedForZero.decodePBHexString(CodableMessage.self).value == 0)
        #expect(try expectedForOne.decodePBHexString(CodableMessage.self).value == 1)
    }
}
