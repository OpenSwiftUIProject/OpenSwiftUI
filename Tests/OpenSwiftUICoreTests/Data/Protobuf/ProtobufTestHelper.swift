//
//  ProtobufTestHelper.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenSwiftUICore

// MARK: - Message Types

struct BoolMessage: ProtobufMessage, Equatable {
    var value: Bool
    
    init() {
        self.value = false
    }
    
    init(value: Bool) {
        self.value = value
    }
    
    init(from decoder: inout ProtobufDecoder) throws {
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                value = try decoder.boolField(field)
                return
            default:
                try decoder.skipField(field)
            }
        }
        value = false
    }
    
    func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.boolField(1, value)
    }
}

struct EnumMessage: ProtobufMessage {
    enum Value: UInt, ProtobufEnum {
        var protobufValue: UInt { rawValue }
        
        init?(protobufValue: UInt) {
            self.init(rawValue: protobufValue)
        }
        
        case a, b
    }
    
    var value: Value
    
    init(value: Value) {
        self.value = value
    }
    
    init(from decoder: inout ProtobufDecoder) throws {
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                value = try decoder.enumField(field) ?? .a
                return
            default:
                try decoder.skipField(field)
            }
        }
        throw ProtobufDecoder.DecodingError.failed
    }
    
    func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.enumField(1, value)
    }
}

struct EnumEquatableMessage: ProtobufMessage {
    enum Value: UInt, ProtobufEnum, Equatable {
        var protobufValue: UInt { rawValue }
        
        init?(protobufValue: UInt) {
            self.init(rawValue: protobufValue)
        }
        
        case a, b
    }
    
    var value: Value
    static let defaultValue: Value = .a
    
    init(value: Value) {
        self.value = value
    }
    
    init(from decoder: inout ProtobufDecoder) throws {
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                value = try decoder.enumField(field) ?? .a
                return
            default:
                try decoder.skipField(field)
            }
        }
        value = Self.defaultValue
    }
    
    func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.enumField(1, value, defaultValue: Self.defaultValue)
    }
}

struct IntegerMessage: ProtobufMessage, Equatable {
    var intValue: Int?
    var unsignedIntValue: UInt?
    var int64Value: Int64?
    var unsignedInt64Value: UInt64?
    var int32Value: Int32?
    var unsignedInt32Value: UInt32?
    
    init(intValue: Int? = nil, unsignedIntValue: UInt? = nil, int64Value: Int64? = nil, unsignedInt64Value: UInt64? = nil, int32Value: Int32? = nil, unsignedInt32Value: UInt32? = nil) {
        self.intValue = intValue
        self.unsignedIntValue = unsignedIntValue
        self.int64Value = int64Value
        self.unsignedInt64Value = unsignedInt64Value
        self.int32Value = int32Value
        self.unsignedInt32Value = unsignedInt32Value
    }
    
    init(from decoder: inout ProtobufDecoder) throws {
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                intValue = try decoder.intField(field)
            case 2:
                unsignedIntValue = try decoder.uintField(field)
            case 3:
                int64Value = Int64(try decoder.intField(field))
            case 4:
                unsignedInt64Value = try decoder.uint64Field(field)
            case 5:
                int32Value = Int32(bitPattern: try decoder.fixed32Field(field))
            case 6:
                unsignedInt32Value = try decoder.fixed32Field(field)
            default:
                try decoder.skipField(field)
            }
        }
    }
    
    func encode(to encoder: inout ProtobufEncoder) throws {
        if let intValue = intValue {
            encoder.intField(1, intValue)
        }
        if let unsignedIntValue = unsignedIntValue {
            encoder.uintField(2, unsignedIntValue)
        }
        if let int64Value = int64Value {
            encoder.int64Field(3, int64Value)
        }
        if let unsignedInt64Value = unsignedInt64Value {
            encoder.uint64Field(4, unsignedInt64Value)
        }
        if let int32Value = int32Value {
            encoder.fixed32Field(5, UInt32(bitPattern: int32Value))
        }
        if let unsignedInt32Value = unsignedInt32Value {
            encoder.fixed32Field(6, unsignedInt32Value)
        }
    }
}

struct FloatPointMessage: ProtobufMessage, Equatable {
    var float: Float?
    var double: Double?
    var cgFloat: CGFloat?
    
    init(float: Float? = nil, double: Double? = nil, cgFloat: CGFloat? = nil) {
        self.float = float
        self.double = double
        self.cgFloat = cgFloat
    }
    
    init(from decoder: inout ProtobufDecoder) throws {
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: float = try decoder.floatField(field)
            case 2: double = try decoder.doubleField(field)
            case 3: cgFloat = try decoder.cgFloatField(field)
            default:
                try decoder.skipField(field)
            }
        }
    }
    
    func encode(to encoder: inout ProtobufEncoder) throws {
        if let float {
            encoder.floatField(1, float)
        }
        if let double {
            encoder.doubleField(2, double)
        }
        if let cgFloat {
            encoder.cgFloatField(3, cgFloat)
        }
    }
}

struct DataMessage: ProtobufMessage, Equatable {
    var data: Data?
    
    init(data: Data? = nil) {
        self.data = data
    }
    
    init(from decoder: inout ProtobufDecoder) throws {
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                data = try decoder.dataField(field)
                return
            default:
                try decoder.skipField(field)
            }
        }
        data = nil
    }
    
    func encode(to encoder: inout ProtobufEncoder) throws {
        if let data {
            encoder.dataField(1, data)
        }
    }
}

struct PackedIntMessage: ProtobufMessage {
    var values: [Int]
    
    init(values: [Int]) {
        self.values = values
    }
    
    init(from decoder: inout ProtobufDecoder) throws {
        var values: [Int] = []
        while true {
            guard let field = try decoder.nextField() else {
                self.init(values: values)
                return
            }
            if field.tag == 1 {
                let result = try decoder.intField(field)
                values.append(result)
            } else {
                try decoder.skipField(field)
            }
        }
    }
    
    func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.packedField(1) { encoder in
            values.forEach { encoder.encodeVarintZZ($0) }
        }
    }
}

struct MessageMessage<T>: ProtobufMessage where T: ProtobufMessage {
    var value: T
    
    init(value: T) {
        self.value = value
    }
    
    init(from decoder: inout ProtobufDecoder) throws {
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                value = try decoder.messageField(field)
                return
            default:
                try decoder.skipField(field)
            }
        }
        throw ProtobufDecoder.DecodingError.failed
    }
    
    func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, value)
    }
}

protocol Defaultable {
    init()
}

extension BoolMessage: Defaultable {}

struct EquatableMessageMessage<T>: ProtobufMessage where T: ProtobufMessage, T: Equatable, T: Defaultable {
    var value: T
    
    init(value: T) {
        self.value = value
    }
    
    init(from decoder: inout ProtobufDecoder) throws {
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                value = try decoder.messageField(field)
                return
            default:
                try decoder.skipField(field)
            }
        }
        value = T()
    }
    
    func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, value, defaultValue: .init())
    }
}

struct StringMessage: ProtobufMessage, Equatable {
    var string: String
    
    init(string: String) {
        self.string = string
    }
    
    init(from decoder: inout ProtobufDecoder) throws {
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                string = try decoder.stringField(field)
                return
            default:
                try decoder.skipField(field)
            }
        }
        throw ProtobufDecoder.DecodingError.failed
    }
    
    func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.stringField(1, string)
    }
}

struct CodableMessage<T>: ProtobufMessage where T: Codable {
    var value: T
    
    init(value: T) {
        self.value = value
    }
    
    init(from decoder: inout ProtobufDecoder) throws {
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                value = try decoder.codableField(field)
                return
            default:
                try decoder.skipField(field)
            }
        }
        throw ProtobufDecoder.DecodingError.failed
    }
    
    func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.codableField(1, value)
    }
}

struct EquatableCodableMessage<T>: ProtobufMessage where T: Codable, T: Equatable {
    var value: T
    let defaultValue: T
    
    init(value: T, defaultValue: T) {
        self.value = value
        self.defaultValue = defaultValue
    }
    
    init(from decoder: inout ProtobufDecoder) throws {
        _openSwiftUIUnimplementedFailure()
    }
    
    func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.codableField(1, value, defaultValue: defaultValue)
    }
}

struct EmptyMessage: ProtobufMessage {
    init() {}
    
    init(from decoder: inout ProtobufDecoder) throws {}
    
    func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.emptyField(1)
    }
}

// MARK: - Data + Extension

extension Data {
    init?(hexString: String) {
        let hex = hexString.count % 2 == 0 ? hexString : "0" + hexString
        var index = hex.startIndex
        var bytes: [UInt8] = []
        while index < hex.endIndex {
            let nextIndex = hex.index(index, offsetBy: 2)
            let byteString = hex[index..<nextIndex]
            if let byte = UInt8(byteString, radix: 16) {
                bytes.append(byte)
            } else {
                return nil
            }
            index = nextIndex
        }
        self.init(bytes)
    }
    
    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - String + Extension

extension String {
    func decodePBHexString<T>(_ type: T.Type = T.self) throws -> T where T: ProtobufDecodableMessage {
        guard let data = Data(hexString: self) else {
            throw ProtobufDecoder.DecodingError.failed
        }
        var decoder = ProtobufDecoder(data)
        return try T(from: &decoder)
    }
}

// MARK: - ProtobufEncodableMessage + Extension

extension ProtobufEncodableMessage {
    var pbHexString: String {
        get throws {
            try ProtobufEncoder.encoding(self).hexString
        }
    }
}

// MARK: - ProtobufMessage + Testing

#if canImport(Testing)
import Testing

extension ProtobufEncodableMessage {
    func testPBEncoding(hexString expectedHexString: String) throws {
        let data = try ProtobufEncoder.encoding(self)
        #expect(data.hexString == expectedHexString)
    }
}

extension ProtobufDecodableMessage where Self: Equatable {
    func testPBDecoding(hexString: String) throws {
        let decodedValue = try hexString.decodePBHexString(Self.self)
        #expect(decodedValue == self)
    }
}
#endif
