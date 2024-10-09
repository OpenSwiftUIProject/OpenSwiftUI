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
    func intEncode() throws {
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
        
        print(try FloatPointMessage(float: 65536.0 + 1).pbHexString)
        print(try FloatPointMessage(double: 65536.0 + 1).pbHexString)
        print(try FloatPointMessage(cgFloat: 65536.0 + 1).pbHexString)
    }
}
