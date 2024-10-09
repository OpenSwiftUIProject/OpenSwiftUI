//
//  ProtobufEncoderTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing
import Foundation

struct ProtobufEncoderTests {
    @Test
    func boolEncode() async throws {
        // FIXME: extra () is a workaround for swiftlang/swift-testing#756
        #expect((try BoolMessage(value: false).pbHexString) == "")
        #expect((try BoolMessage(value: true).pbHexString) == "0801")
    }
    
    @Test
    func intEncode() async throws {
        // FIXME: extra () is a workaround for swiftlang/swift-testing#756
        #expect((try IntegerMessage(intValue: 1).pbHexString) == "0802")
        #expect((try IntegerMessage(unsignedIntValue: 2).pbHexString) == "1002")
        #expect((try IntegerMessage(int64Value: 3).pbHexString) == "1806")
        #expect((try IntegerMessage(unsignedInt64Value: 4).pbHexString) == "2004")
        #expect((try IntegerMessage(int32Value: 5).pbHexString) == "2d05000000")
        #expect((try IntegerMessage(unsignedInt32Value: 6).pbHexString) == "3506000000")
        #expect(try IntegerMessage(intValue: 1, unsignedIntValue: 2, int64Value: 3, unsignedInt64Value: 4, int32Value: 5, unsignedInt32Value: 6).pbHexString == "08021002180620042d050000003506000000")
    }
}
