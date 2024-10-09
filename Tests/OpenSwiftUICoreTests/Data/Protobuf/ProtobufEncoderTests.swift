//
//  ProtobufEncoderTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing
import Foundation

// FIXME: extra () is a workaround for swiftlang/swift-testing#756
struct ProtobufEncoderTests {
    @Test
    func boolEncode() throws {
        #expect((try BoolMessage(value: false).pbHexString) == "")
        #expect((try BoolMessage(value: true).pbHexString) == "0801")
    }
    
    @Test
    func enumEncode() throws {
        #expect((try EnumMessage(value: .a).pbHexString) == "0800")
        #expect((try EnumMessage(value: .b).pbHexString) == "0801")
        #expect((try EnumEquatableMessage(value: .a, defaultValue: .a).pbHexString) == "")
        #expect((try EnumEquatableMessage(value: .b, defaultValue: .a).pbHexString) == "0801")
    }
    
    @Test
    func intEncode() throws {
        #expect((try IntegerMessage(intValue: -1).pbHexString) == "0801")
        #expect((try IntegerMessage(intValue: 1).pbHexString) == "0802")
        #expect((try IntegerMessage(unsignedIntValue: 2).pbHexString) == "1002")
        #expect((try IntegerMessage(int64Value: 3).pbHexString) == "1806")
        #expect((try IntegerMessage(unsignedInt64Value: 4).pbHexString) == "2004")
        #expect((try IntegerMessage(int32Value: 5).pbHexString) == "2d05000000")
        #expect((try IntegerMessage(unsignedInt32Value: 6).pbHexString) == "3506000000")
        #expect(try IntegerMessage(intValue: 1, unsignedIntValue: 2, int64Value: 3, unsignedInt64Value: 4, int32Value: 5, unsignedInt32Value: 6).pbHexString == "08021002180620042d050000003506000000")
        #expect((try IntegerMessage(intValue: 0x8888).pbHexString) == "0890a204")
    }
    
    @Test
    func floatEncode() throws {
        #expect((try FloatPointMessage(float: .zero).pbHexString) == "")
        #expect((try FloatPointMessage(double: .zero).pbHexString) == "")
        #expect((try FloatPointMessage(cgFloat: .zero).pbHexString) == "")
        
        #expect((try FloatPointMessage(float: 65536.0 - 1).pbHexString) == "0d00ff7f47")
        #expect((try FloatPointMessage(double: 65536.0 - 1).pbHexString) == "1100000000e0ffef40")
        #expect((try FloatPointMessage(cgFloat: 65536.0 - 1).pbHexString) == "1d00ff7f47")
        
        #expect((try FloatPointMessage(float: 65536.0 + 1).pbHexString) == "0d80008047")
        #expect((try FloatPointMessage(double: 65536.0 + 1).pbHexString) == "11000000001000f040")
        #expect((try FloatPointMessage(cgFloat: 65536.0 + 1).pbHexString) == "19000000001000f040")
    }
    
    @Test
    func dataEncode() throws {
        #expect((try DataMessage(data: .init(repeating: UInt8(0xFF), count: 4)).pbHexString) == "0a04ffffffff")
        #expect((try DataMessage(data: .init(repeating: UInt8(0x88), count: 2)).pbHexString) == "0a028888")
    }
    
    @Test
    func packedEncode() throws {
        #expect((try PackedIntMessage(values: [0, 8, 128]).pbHexString) == "0a0400108002")
        #expect((try PackedIntMessage(values: [0, 8]).pbHexString) == "0a020010")
    }
    
    @Test
    func messageEncode() throws {
        let falseMessage = BoolMessage(value: false)
        let trueMessage = BoolMessage(value: true)
        
        let expectedForFalse = "0a00"
        let expectedForTrue = "0a020801"
        
        #expect((try MessageMessage(value: falseMessage).pbHexString) == expectedForFalse)
        #expect((try MessageMessage(value: trueMessage).pbHexString) == expectedForTrue)
        #expect((try EquatableMessageMessage(value: falseMessage, defaultValue: falseMessage).pbHexString) == "")
        #expect((try EquatableMessageMessage(value: trueMessage, defaultValue: falseMessage).pbHexString) == expectedForTrue)
    }
    
    @Test
    func stringEncode() throws {
        #expect((try StringMessage(string: "").pbHexString) == "")
        #expect((try StringMessage(string: "A").pbHexString) == "0a0141")
        #expect((try StringMessage(string: "OpenSwiftUI").pbHexString) == "0a0b4f70656e53776966745549")
        #expect((try StringMessage(string: "测试👋").pbHexString) == "0a0ae6b58be8af95f09f918b")
    }
    
    @Test
    func codableEncode() throws {
        let expectedForZero = "0a2e62706c6973743030a1011000080a000000000000010100000000000000020000000000000000000000000000000c"
        let expectedForOne = "0a2e62706c6973743030a1011001080a000000000000010100000000000000020000000000000000000000000000000c"
        
        #expect((try CodableMessage(value: 0).pbHexString) == expectedForZero)
        #expect((try CodableMessage(value: 1).pbHexString) == expectedForOne)
        #expect((try EquatableCodableMessage(value: 0, defaultValue: 0).pbHexString) == "")
        #expect((try EquatableCodableMessage(value: 1, defaultValue: 0).pbHexString) == expectedForOne)
    }
    
    @Test
    func emptyEncode() throws {
        #expect((try EmptyMessage().pbHexString) == "0a00")
    }
}
