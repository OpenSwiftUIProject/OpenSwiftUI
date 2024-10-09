//
//  ProtobufTestHelper.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenSwiftUICore

// MARK: - Message Types

struct BoolMessage: ProtobufMessage {
    var value: Bool
    
    init(value: Bool) {
        self.value = value
    }
    
    init(from decoder: inout ProtobufDecoder) throws {
        fatalError("TODO")
    }
    
    func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.boolField(1, value)
    }
}

struct IntegerMessage: ProtobufMessage {
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
        fatalError("TODO")
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

struct FloatPointMessage: ProtobufMessage {
    var float: Float?
    var double: Double?
    var cgFloat: CGFloat?
    
    init(float: Float? = nil, double: Double? = nil, cgFloat: CGFloat? = nil) {
        self.float = float
        self.double = double
        self.cgFloat = cgFloat
    }
    
    init(from decoder: inout ProtobufDecoder) throws {
        fatalError("TODO")
    }
    
    func encode(to encoder: inout ProtobufEncoder) throws {
        if let float = float {
            encoder.floatField(1, float)
        }
        if let double = double {
            encoder.doubleField(2, double)
        }
        if let cgFloat = cgFloat {
            encoder.cgFloatField(3, cgFloat)
        }
    }
}

struct UIntMessage: ProtobufMessage {
    var value: UInt
    
    init(value: UInt) {
        self.value = value
    }
    
    init(from decoder: inout ProtobufDecoder) throws {
        fatalError("TODO")
    }
    
    func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.uintField(1, value)
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

// MARK: - ProtobufEncodableMessage + Extension

extension ProtobufEncodableMessage {
    var pbHexString: String {
        get throws {
            try ProtobufEncoder.encoding(self).hexString
        }
    }
}
