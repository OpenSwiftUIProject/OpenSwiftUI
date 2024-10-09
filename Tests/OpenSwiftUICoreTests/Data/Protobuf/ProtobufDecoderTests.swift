//
//  ProtobufDecoderTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing
import Foundation

// FIXME: extra () is a workaround for swiftlang/swift-testing#756
struct ProtobufDecoderTests {
    @Test
    func boolDecode() throws {
        #expect(try "".decodePBHexString(BoolMessage.self) == BoolMessage(value: false))
        #expect(try "0800".decodePBHexString(BoolMessage.self) == BoolMessage(value: false))
        #expect(try "0801".decodePBHexString(BoolMessage.self) == BoolMessage(value: true))
    }
    
    @Test
    func enumEncode() throws {
        #expect(try "".decodePBHexString(EnumMessage.self).value == .a)
        #expect(try "0800".decodePBHexString(EnumMessage.self).value == .a)
        #expect(try "0801".decodePBHexString(EnumMessage.self).value == .b)
    }
    
    @Test
    func intEncode() throws {
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
    func skipInvalidTag() throws {
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
    func floatEncode() throws {
        #expect(try "".decodePBHexString(FloatPointMessage.self) == FloatPointMessage())
        #expect(try "0d00ff7f47".decodePBHexString(FloatPointMessage.self) == FloatPointMessage(float: 65536.0 - 1))
        #expect(try "1100000000e0ffef40".decodePBHexString(FloatPointMessage.self) == FloatPointMessage(float: 65536.0 - 1))
        #expect(try "1d00ff7f47".decodePBHexString(FloatPointMessage.self) == FloatPointMessage(cgFloat: 65536.0 - 1))
        
        #expect(try "0d80008047".decodePBHexString(FloatPointMessage.self) == FloatPointMessage(float: 65536.0 + 1))
        #expect(try "11000000001000f040".decodePBHexString(FloatPointMessage.self) == FloatPointMessage(double: 65536.0 + 1))
        #expect(try "19000000001000f040".decodePBHexString(FloatPointMessage.self) == FloatPointMessage(cgFloat: 65536.0 + 1))
    }

    
    // TODO: packed Bool

}
