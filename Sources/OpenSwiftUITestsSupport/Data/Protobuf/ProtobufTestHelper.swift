//
//  ProtobufTestHelper.swift
//  OpenSwiftUICoreTests

#if OPENSWIFTUI
package import Foundation
package import OpenSwiftUICore

// MARK: - Message Types

package struct BoolMessage: ProtobufMessage, Equatable {
    package var value: Bool

    package init() {
        self.value = false
    }
    
    package init(value: Bool) {
        self.value = value
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
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
    
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.boolField(1, value)
    }
}

package struct EnumMessage: ProtobufMessage {
    package enum Value: UInt, ProtobufEnum {
        package var protobufValue: UInt { rawValue }
        
        package init?(protobufValue: UInt) {
            self.init(rawValue: protobufValue)
        }
        
        case a, b
    }
    
    package var value: Value
    
    package init(value: Value) {
        self.value = value
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
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
    
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.enumField(1, value)
    }
}

package struct EnumEquatableMessage: ProtobufMessage {
    package enum Value: UInt, ProtobufEnum, Equatable {
        package var protobufValue: UInt { rawValue }
        
        package init?(protobufValue: UInt) {
            self.init(rawValue: protobufValue)
        }
        
        case a, b
    }
    
    package var value: Value
    package static let defaultValue: Value = .a
    
    package init(value: Value) {
        self.value = value
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
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
    
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.enumField(1, value, defaultValue: Self.defaultValue)
    }
}

package struct IntegerMessage: ProtobufMessage, Equatable {
    package var intValue: Int?
    package var unsignedIntValue: UInt?
    package var int64Value: Int64?
    package var unsignedInt64Value: UInt64?
    package var int32Value: Int32?
    package var unsignedInt32Value: UInt32?
    
    package init(intValue: Int? = nil, unsignedIntValue: UInt? = nil, int64Value: Int64? = nil, unsignedInt64Value: UInt64? = nil, int32Value: Int32? = nil, unsignedInt32Value: UInt32? = nil) {
        self.intValue = intValue
        self.unsignedIntValue = unsignedIntValue
        self.int64Value = int64Value
        self.unsignedInt64Value = unsignedInt64Value
        self.int32Value = int32Value
        self.unsignedInt32Value = unsignedInt32Value
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
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
    
    package func encode(to encoder: inout ProtobufEncoder) throws {
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

package struct FloatPointMessage: ProtobufMessage, Equatable {
    package var float: Float?
    package var double: Double?
    package var cgFloat: CGFloat?
    
    package init(float: Float? = nil, double: Double? = nil, cgFloat: CGFloat? = nil) {
        self.float = float
        self.double = double
        self.cgFloat = cgFloat
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
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
    
    package func encode(to encoder: inout ProtobufEncoder) throws {
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

package struct DataMessage: ProtobufMessage, Equatable {
    package var data: Data?
    
    package init(data: Data? = nil) {
        self.data = data
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
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
    
    package func encode(to encoder: inout ProtobufEncoder) throws {
        if let data {
            encoder.dataField(1, data)
        }
    }
}

package struct PackedIntMessage: ProtobufMessage {
    package var values: [Int]
    
    package init(values: [Int]) {
        self.values = values
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
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
    
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.packedField(1) { encoder in
            values.forEach { encoder.encodeVarintZZ($0) }
        }
    }
}

package struct MessageMessage<T>: ProtobufMessage where T: ProtobufMessage {
    package var value: T
    
    package init(value: T) {
        self.value = value
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
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
    
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, value)
    }
}

package protocol Defaultable {
    init()
}

extension BoolMessage: Defaultable {}

package struct EquatableMessageMessage<T>: ProtobufMessage where T: ProtobufMessage, T: Equatable, T: Defaultable {
    package var value: T
    
    package init(value: T) {
        self.value = value
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
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
    
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, value, defaultValue: .init())
    }
}

package struct StringMessage: ProtobufMessage, Equatable {
    package var string: String
    
    package init(string: String) {
        self.string = string
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
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
    
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.stringField(1, string)
    }
}

package struct CodableMessage<T>: ProtobufMessage where T: Codable {
    package var value: T
    
    package init(value: T) {
        self.value = value
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
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
    
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.codableField(1, value)
    }
}

package struct EquatableCodableMessage<T>: ProtobufMessage where T: Codable, T: Equatable {
    package var value: T
    package let defaultValue: T
    
    package init(value: T, defaultValue: T) {
        self.value = value
        self.defaultValue = defaultValue
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
        _openSwiftUIUnimplementedFailure()
    }
    
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.codableField(1, value, defaultValue: defaultValue)
    }
}

package struct EmptyMessage: ProtobufMessage {
    package init() {}
    
    package init(from decoder: inout ProtobufDecoder) throws {}
    
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.emptyField(1)
    }
}

// MARK: - Data + Extension

extension Data {
    package init?(hexString: String) {
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
    
    package var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - String + Extension

extension String {
    package func decodePBHexString<T>(_ type: T.Type = T.self) throws -> T where T: ProtobufDecodableMessage {
        guard let data = Data(hexString: self) else {
            throw ProtobufDecoder.DecodingError.failed
        }
        var decoder = ProtobufDecoder(data)
        return try T(from: &decoder)
    }
}

// MARK: - ProtobufEncodableMessage + Extension

extension ProtobufEncodableMessage {
    package var pbHexString: String {
        get throws {
            try ProtobufEncoder.encoding(self).hexString
        }
    }
}

// MARK: - ProtobufMessage + Testing

#if canImport(Testing)
import Testing

extension ProtobufEncodableMessage {
    package func testPBEncoding(hexString expectedHexString: String) throws {
        let data = try ProtobufEncoder.encoding(self)
        #expect(data.hexString == expectedHexString)
    }
}

extension ProtobufDecodableMessage where Self: Equatable {
    package func testPBDecoding(hexString: String) throws {
        let decodedValue = try hexString.decodePBHexString(Self.self)
        #expect(decodedValue == self)
    }
}
#endif
#endif
