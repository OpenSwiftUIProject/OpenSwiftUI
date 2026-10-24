//
//  ProtobufDecoderTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

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
        #expect(try "107f".decodePBHexString(IntegerMessage.self) == IntegerMessage(unsignedIntValue: 0x7F))
        #expect(try "108001".decodePBHexString(IntegerMessage.self) == IntegerMessage(unsignedIntValue: 0x80))
        #expect(try "20ffffffffffffffffff01".decodePBHexString(IntegerMessage.self) == IntegerMessage(unsignedInt64Value: .max))
    }

    @Test(arguments: [
        ([0x00], 0, 0, 0),
        ([0xff, 0x01], 255, 255, 255),
        ([0x80, 0x02], 0, 256, 256),
        ([0x81, 0x02], 1, 257, 257),
        ([0xff, 0xff, 0x03], 255, 65535, 65535),
        ([0x80, 0x80, 0x04], 0, 0, 65536),
        ([0x81, 0x80, 0x04], 1, 1, 65537),
        ([0xff, 0xff, 0xff, 0xff, 0x0f], 255, 65535, 4294967295),
        ([0x80, 0x80, 0x80, 0x80, 0x10], 0, 0, 0),
        ([0x81, 0x80, 0x80, 0x80, 0x10], 1, 1, 1),
        ([0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01], 255, 65535, 4294967295),
    ] as [([UInt8], UInt8, UInt16, UInt32)])
    func unsignedIntegerDecode(bytes: [UInt8], expected8: UInt8, expected16: UInt16, expected32: UInt32) throws {
        let data = Data([0x08] + bytes)
        var decoder = ProtobufDecoder(data)
        var field = try #require(try decoder.nextField())
        #expect(try decoder.uint8Field(field) == expected8)
        #expect(try decoder.nextField() == nil)

        decoder = ProtobufDecoder(data)
        field = try #require(try decoder.nextField())
        #expect(try decoder.uint16Field(field) == expected16)
        #expect(try decoder.nextField() == nil)

        decoder = ProtobufDecoder(data)
        field = try #require(try decoder.nextField())
        #expect(try decoder.uint32Field(field) == expected32)
        #expect(try decoder.nextField() == nil)
    }

    @Test(arguments: [
        [0x08, 0x80],
        [0x0a, 0x02, 0x80],
        [0x0a, 0x01, 0x80],
        [0x0d, 0x00, 0x00, 0x00, 0x00],
    ] as [[UInt8]])
    func invalidUnsignedIntegerDecode(bytes: [UInt8]) throws {
        let data = Data(bytes)
        var decoder = ProtobufDecoder(data)
        var field = try #require(try decoder.nextField())
        #expect(throws: ProtobufDecoder.DecodingError.failed) {
            try decoder.uint8Field(field)
        }

        decoder = ProtobufDecoder(data)
        field = try #require(try decoder.nextField())
        #expect(throws: ProtobufDecoder.DecodingError.failed) {
            try decoder.uint16Field(field)
        }

        decoder = ProtobufDecoder(data)
        field = try #require(try decoder.nextField())
        #expect(throws: ProtobufDecoder.DecodingError.failed) {
            try decoder.uint32Field(field)
        }
    }
    
    @Test
    func skipInvalidTagDecode() throws {
        #expect(try "3900000000000000000801".decodePBHexString(IntegerMessage.self) == IntegerMessage(intValue: -1))
        #expect(try "3d000000000801".decodePBHexString(IntegerMessage.self) == IntegerMessage(intValue: -1))
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
    func skipTruncatedFixedFieldDecode() {
        #expect(throws: Error.self) {
            try "39".decodePBHexString(IntegerMessage.self)
        }
        #expect(throws: Error.self) {
            try "3d".decodePBHexString(IntegerMessage.self)
        }
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

        let payload127 = String(repeating: "ff", count: 0x7F)
        let payload128 = String(repeating: "ff", count: 0x80)
        #expect(try "0a7f\(payload127)".decodePBHexString(DataMessage.self) == DataMessage(data: .init(repeating: 0xFF, count: 0x7F)))
        #expect(try "0a8001\(payload128)".decodePBHexString(DataMessage.self) == DataMessage(data: .init(repeating: 0xFF, count: 0x80)))
    }

    @Test(arguments: [false, true])
    func emptyDataDecode(hasFollowingField: Bool) throws {
        let bytes: [UInt8] = hasFollowingField ? [0x0a, 0x00, 0x10, 0x01] : [0x0a, 0x00]
        var decoder = ProtobufDecoder(Data(bytes))
        let field = try #require(try decoder.nextField())
        let data = try decoder.dataField(field)
        #expect(data.isEmpty)
        #expect(data.startIndex == 0)
        #expect(data.endIndex == 0)
        if hasFollowingField {
            let next = try #require(try decoder.nextField())
            #expect(next.tag == 2)
            #expect(try decoder.boolField(next))
        }
        #expect(try decoder.nextField() == nil)
    }

    @Test
    func dataSliceDecode() throws {
        var decoder = ProtobufDecoder(Data([0x0a, 0x02, 0xab, 0xcd, 0x12, 0x00]))
        let field = try #require(try decoder.nextField())
        let data = try decoder.dataField(field)
        #expect(data == Data([0xab, 0xcd]))
        #expect(data.startIndex == 2)
        #expect(data.endIndex == 4)

        let next = try #require(try decoder.nextField())
        #expect(next.tag == 2)
        let empty = try decoder.dataField(next)
        #expect(empty.isEmpty)
        #expect(empty.startIndex == 0)
        #expect(empty.endIndex == 0)
        #expect(try decoder.nextField() == nil)
    }

    @Test(arguments: [
        [0x0a],
        [0x0a, 0x80],
        [0x0a, 0x02, 0xff],
        [0x08, 0x00],
    ] as [[UInt8]])
    func invalidDataDecode(bytes: [UInt8]) throws {
        var decoder = ProtobufDecoder(Data(bytes))
        let field = try #require(try decoder.nextField())
        #expect(throws: ProtobufDecoder.DecodingError.failed) {
            try decoder.dataField(field)
        }
    }
    
    @Test
    func packedDecode() throws {
        #expect(try "".decodePBHexString(PackedIntMessage.self).values == [])
        #expect(try "0a0400108002".decodePBHexString(PackedIntMessage.self).values == [0, 8, 128])
        #expect(try "0a020010".decodePBHexString(PackedIntMessage.self).values == [0, 8])
    }

    @Test
    func packedUnsignedIntegerDecode() throws {
        var decoder = ProtobufDecoder(Data([
            0x0a, 0x0d,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01,
            0x80, 0x02, 0x01,
            0x12, 0x0e,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01,
            0x80, 0x80, 0x04, 0x01,
            0x1a, 0x10,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01,
            0x80, 0x80, 0x80, 0x80, 0x10, 0x01,
            0x20, 0x01,
        ]))
        for expected in [255, 0, 1] as [UInt8] {
            let field = try #require(try decoder.nextField())
            #expect(field.tag == 1)
            #expect(try decoder.uint8Field(field) == expected)
        }
        for expected in [65535, 0, 1] as [UInt16] {
            let field = try #require(try decoder.nextField())
            #expect(field.tag == 2)
            #expect(try decoder.uint16Field(field) == expected)
        }
        for expected in [4294967295, 0, 1] as [UInt32] {
            let field = try #require(try decoder.nextField())
            #expect(field.tag == 3)
            #expect(try decoder.uint32Field(field) == expected)
        }
        let field = try #require(try decoder.nextField())
        #expect(field.tag == 4)
        #expect(try decoder.boolField(field))
        #expect(try decoder.nextField() == nil)
    }
    
    @Test
    func messageDecode() throws {
        let expectedForFalse = "0a00"
        let expectedForTrue = "0a020801"

        #expect(try expectedForFalse.decodePBHexString(MessageMessage<BoolMessage>.self).value.value == false)
        #expect(try expectedForTrue.decodePBHexString(MessageMessage<BoolMessage>.self).value.value == true)

        #expect(try "".decodePBHexString(EquatableMessageMessage<BoolMessage>.self).value.value == false)
        #expect(try expectedForFalse.decodePBHexString(EquatableMessageMessage<BoolMessage>.self).value.value == false)
        #expect(try expectedForTrue.decodePBHexString(EquatableMessageMessage<BoolMessage>.self).value.value == true)
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
