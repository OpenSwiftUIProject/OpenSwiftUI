//
//  ProtobufDecoder.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Complete
//  ID: FFA06CAF6B06DC3E21EC75547A0CD421

package import Foundation

/// An object that decodes instances of a data type from protobuf objects.
package struct ProtobufDecoder {
    /// An error that can occur during `ProtobufDecoder` decoding.
    package enum DecodingError: Error {
        case failed
    }
    
    /// A type representing a field in a protobuf encoding.
    package typealias Field = ProtobufFormat.Field
    
    /// A type representing the wire type of a protobuf encoding.
    package typealias WireType = ProtobufFormat.WireType
    
    /// The data being decoded.
    var data: NSData
    
    /// A pointer to the current position in the data.
    var ptr: UnsafeRawPointer
    
    /// A pointer to the end of the data.
    var end: UnsafeRawPointer
    
    /// The current packed field.
    var packedField: Field = Field(rawValue: 0)
    
    /// A pointer to the end of the packed field.
    var packedEnd: UnsafeRawPointer
    
    /// A stack of pointers for nested messages.
    var stack: [UnsafeRawPointer] = []
    
    /// User-defined information.
    package var userInfo: [CodingUserInfoKey : Any] = [:]
    
    /// Creates an instance with a data buffer.
    package init(_ data: Data) {
        let nsData = data as NSData
        self.data = nsData
        let ptr = nsData.bytes
        self.ptr = ptr
        self.end = ptr + nsData.length
        self.packedEnd = ptr
    }
}

extension ProtobufDecoder {
    /// Decodes the next field in the data.
    package mutating func nextField() throws -> ProtobufDecoder.Field? {
        guard ptr < end else {
            packedField = Field(rawValue: 0)
            return nil
        }
        if packedField.rawValue != 0 {
            if ptr < packedEnd {
                return packedField
            } else if packedEnd < ptr {
                throw DecodingError.failed
            }
        }
        let result = try decodeVariant()
        let field = Field(rawValue: result)
        guard field.tag > 0 else {
            throw DecodingError.failed
        }
        return field
    }
    
    /// Skips the next field in the data.
    package mutating func skipField(_ field: ProtobufDecoder.Field) throws {
        switch field.wireType {
        case .varint:
            _ = try decodeVariant()
        case .fixed64:
            let newPtr = ptr.advanced(by: 8)
            guard newPtr <= end else {
                return
            }
            ptr = newPtr
        case .lengthDelimited:
            _ = try decodeDataBuffer()
        case .fixed32:
            let newPtr = ptr.advanced(by: 4)
            guard newPtr <= end else {
                return
            }
            ptr = newPtr
        default:
            throw DecodingError.failed
        }
    }
    
    /// Decodes a boolean(Bool) value field from the data.
    ///
    /// - Parameter field: The field to decode.
    /// - Returns: A boolean(Bool) value.
    package mutating func boolField(_ field: ProtobufDecoder.Field) throws -> Bool {
        switch field.wireType {
        case .varint:
            break
        case .lengthDelimited:
            let offset = try decodeVariant()
            let offsetPtr = ptr.advanced(by: Int(offset))
            guard offsetPtr <= end else {
                throw DecodingError.failed
            }
            packedField = Field(field.tag, wireType: .varint)
            packedEnd = offsetPtr
        default:
            throw DecodingError.failed
        }
        return try decodeVariant() != 0
    }
    
    /// Decodes an unsigned integer(UInt) value field from the data.
    ///
    /// - Parameter field: The field to decode.
    /// - Returns: An unsigned integer(UInt) value.
    package mutating func uintField(_ field: ProtobufDecoder.Field) throws -> UInt {
        switch field.wireType {
        case .varint:
            break
        case .lengthDelimited:
            let offset = try decodeVariant()
            let offsetPtr = ptr.advanced(by: Int(offset))
            guard offsetPtr <= end else {
                throw DecodingError.failed
            }
            packedField = Field(field.tag, wireType: .varint)
            packedEnd = offsetPtr
        default:
            throw DecodingError.failed
        }
        return try decodeVariant()
    }
    
    /// Decodes an enum field from the data.
    ///
    /// - Parameter field: The field to decode.
    /// - Returns: A ProtobufEnum value.
    package mutating func enumField<T>(_ field: ProtobufDecoder.Field) throws -> T? where T: ProtobufEnum {
        try T(protobufValue: uintField(field))
    }
    
    /// Decodes an unsigned 8-bit integer(UInt8) value field from the data.
    ///
    /// - Parameter field: The field to decode.
    /// - Returns: An unsigned 8-bit integer(UInt8) value.
    package mutating func uint8Field(_ field: ProtobufDecoder.Field) throws -> UInt8 {
        try UInt8(uintField(field))
    }
    
    /// Decodes an unsigned 16-bit integer(UInt16) value field from the data.
    ///
    /// - Parameter field: The field to decode.
    /// - Returns: An unsigned 16-bit integer(UInt16) value.
    package mutating func uint16Field(_ field: ProtobufDecoder.Field) throws -> UInt16 {
        try UInt16(uintField(field))
    }
    
    /// Decodes an unsigned 32-bit integer(UInt32) value field from the data.
    ///
    /// - Parameter field: The field to decode.
    /// - Returns: An unsigned 32-bit integer(UInt32) value.
    package mutating func uint32Field(_ field: ProtobufDecoder.Field) throws -> UInt32 {
        try UInt32(uintField(field))
    }
    
    /// Decodes an unsigned 64-bit integer(UInt64) value field from the data.
    ///
    /// - Parameter field: The field to decode.
    /// - Returns: An unsigned 64-bit integer(UInt64) value.
    package mutating func uint64Field(_ field: ProtobufDecoder.Field) throws -> UInt64 {
        try UInt64(uintField(field))
    }
    
    /// Decodes a signed integer(Int) value field from the data.
    ///
    /// - Parameter field: The field to decode.
    /// - Returns: A signed integer(Int) value.
    package mutating func intField(_ field: ProtobufDecoder.Field) throws -> Int {
        let value = Int(bitPattern: try uintField(field))
        return Int(bitPattern: UInt(bitPattern: (value >> 1)) ^ UInt(bitPattern: -(value & 1)))
    }
    
    /// Decodes a fixed 32-bit integer(UInt32) value field from the data.
    ///
    /// - Parameter field: The field to decode.
    /// - Returns: A fixed 32-bit integer(UInt32) value.
    package mutating func fixed32Field(_ field: ProtobufDecoder.Field) throws -> UInt32 {
        switch field.wireType {
        case .lengthDelimited:
            let offset = try decodeVariant()
            let offsetPtr = ptr.advanced(by: Int(offset))
            guard offsetPtr <= end else {
                throw DecodingError.failed
            }
            packedField = Field(field.tag, wireType: .fixed32)
            packedEnd = offsetPtr
        case .fixed32:
            break
        default:
            throw DecodingError.failed
        }
        let newPtr = ptr.advanced(by: 4)
        guard newPtr <= end else {
            throw DecodingError.failed
        }
        let value = ptr.loadUnaligned(as: UInt32.self)
        ptr = newPtr
        return value
    }
    
    /// Decodes a fixed 64-bit integer(UInt64) value field from the data.
    ///
    /// - Parameter field: The field to decode.
    /// - Returns: A fixed 64-bit integer(UInt64) value.
    package mutating func fixed64Field(_ field: ProtobufDecoder.Field) throws -> UInt64 {
        switch field.wireType {
        case .lengthDelimited:
            let offset = try decodeVariant()
            let offsetPtr = ptr.advanced(by: Int(offset))
            guard offsetPtr <= end else {
                throw DecodingError.failed
            }
            packedField = Field(field.tag, wireType: .fixed64)
            packedEnd = offsetPtr
        case .fixed64:
            break
        default:
            throw DecodingError.failed
        }
        let newPtr = ptr.advanced(by: 8)
        guard newPtr <= end else {
            throw DecodingError.failed
        }
        let value = ptr.loadUnaligned(as: UInt64.self)
        ptr = newPtr
        return value
    }
    
    /// Decodes a float(Float) value field from the data.
    ///
    /// - Parameter field: The field to decode.
    /// - Returns: A float(Float) value.
    package mutating func floatField(_ field: ProtobufDecoder.Field) throws -> Float {
        switch field.wireType {
        case .lengthDelimited:
            let offset = try decodeVariant()
            let offsetPtr = ptr.advanced(by: Int(offset))
            guard offsetPtr <= end else {
                throw DecodingError.failed
            }
            packedField = Field(field.tag, wireType: .fixed32)
            packedEnd = offsetPtr
        case .fixed32:
            break
        default:
            throw DecodingError.failed
        }
        let newPtr = ptr.advanced(by: 4)
        guard newPtr <= end else {
            throw DecodingError.failed
        }
        let value = ptr.loadUnaligned(as: UInt32.self)
        ptr = newPtr
        return Float(bitPattern: value)
    }
    
    /// Decodes a double(Double) value field from the data.
    ///
    /// - Parameter field: The field to decode.
    /// - Returns: A double(Double) value.
    package mutating func doubleField(_ field: ProtobufDecoder.Field) throws -> Double {
        switch field.wireType {
        case .fixed64:
            break
        case .lengthDelimited:
            let offset = try decodeVariant()
            let offsetPtr = ptr.advanced(by: Int(offset))
            guard offsetPtr <= end else {
                throw DecodingError.failed
            }
            packedField = Field(field.tag, wireType: .fixed64)
            packedEnd = offsetPtr
        case .fixed32:
            let newPtr = ptr.advanced(by: 4)
            guard newPtr <= end else {
                throw DecodingError.failed
            }
            let value = ptr.loadUnaligned(as: UInt32.self)
            ptr = newPtr
            return Double(Float(bitPattern: value))
        default:
            throw DecodingError.failed
        }
        let newPtr = ptr.advanced(by: 8)
        guard newPtr <= end else {
            throw DecodingError.failed
        }
        let value = ptr.loadUnaligned(as: UInt64.self)
        ptr = newPtr
        return Double(bitPattern: value)
    }
    
    /// Decodes a CGFloat value field from the data.
    ///
    /// - Parameter field: The field to decode.
    /// - Returns: A CGFloat value.
    @inline(__always)
    package mutating func cgFloatField(_ field: ProtobufDecoder.Field) throws -> CGFloat {
        try doubleField(field)
    }
    
    /// Decodes a data buffer value field from the data.
    ///
    /// - Parameter field: The field to decode.
    /// - Returns: A data buffer value.
    package mutating func dataBufferField(_ field: ProtobufDecoder.Field) throws -> UnsafeRawBufferPointer {
        switch field.wireType {
        case .lengthDelimited:
            try decodeDataBuffer()
        default:
            throw DecodingError.failed
        }
    }
    
    /// Decodes a data value field from the data.
    ///
    /// - Parameter field: The field to decode.
    /// - Returns: A data value.
    package mutating func dataField(_ field: ProtobufDecoder.Field) throws -> Data {
        switch field.wireType {
        case .lengthDelimited:
            let buffer = try decodeDataBuffer()
            guard let baseAddress = buffer.baseAddress else {
                return Data()
            }
            let startIndex = baseAddress - data.bytes
            let endIndex = startIndex + buffer.count
            return (data as Data)[startIndex..<endIndex]
        default:
            throw DecodingError.failed
        }
    }
    
    /// Decodes a message value field from the data.
    ///
    /// - Parameter field: The field to decode.
    /// - Returns: A ProtobufDecodableMessage value.
    package mutating func messageField<T>(_ field: ProtobufDecoder.Field) throws -> T where T: ProtobufDecodableMessage {
        guard field.wireType == .lengthDelimited else {
            throw DecodingError.failed
        }
        return try decodeMessage()
    }
    
    /// Decodes a message value field from the data.
    ///
    /// - Parameters:
    ///   - field: The field to decode.
    ///   - body: A closure that decodes the message.
    /// - Returns: A value decoded from the message.
    package mutating func messageField<T>(_ field: ProtobufDecoder.Field, _ body: (inout ProtobufDecoder) throws -> T) throws -> T {
        guard field.wireType == .lengthDelimited else {
            throw DecodingError.failed
        }
        return try decodeMessage(body)
    }
    
    /// Decodes a string value field from the data.
    ///
    /// - Parameter field: The field to decode.
    /// - Returns: A string value.
    package mutating func stringField(_ field: ProtobufDecoder.Field) throws -> String {
        let data = try dataField(field)
        guard let result = String(data: data, encoding: .utf8) else {
            throw DecodingError.failed
        }
        return result
    }
    
    /// Decodes a codable value field from the data.
    ///
    /// - Parameter field: The field to decode.
    /// - Returns: A codable value.
    package mutating func codableField<T>(_ field: ProtobufDecoder.Field) throws -> T where T: Decodable {
        let data = try dataField(field)
        return try value(fromBinaryPlist: data)
    }
}

extension ProtobufDecoder {
    /// Decodes a variant from the data.
    private mutating func decodeVariant() throws -> UInt {
        var value: UInt = 0
        var shift: UInt = 0
        var shouldContinue = false
        repeat {
            guard ptr < end else {
                throw DecodingError.failed
            }
            let byte = ptr.loadUnaligned(as: UInt8.self)
            ptr += 1
            value |= UInt(byte & 0x7f) << shift
            shift += 7
            shouldContinue = (byte & 0x80 != 0)
        } while shouldContinue
        return value
    }
    
    /// Decodes a data buffer from the data.
    private mutating func decodeDataBuffer() throws -> UnsafeRawBufferPointer {
        let count = try Int(decodeVariant())
        let oldPtr = ptr
        let newPtr = ptr.advanced(by: count)
        guard newPtr <= end else {
            throw DecodingError.failed
        }
        ptr = newPtr
        return UnsafeRawBufferPointer(start: oldPtr, count: count)
    }
    
    /// Begins decoding a message.
    private mutating func beginMessage() throws {
        stack.append(end)
        let count = try Int(decodeVariant())
        let newPtr = ptr.advanced(by: count)
        guard newPtr <= end else {
            throw DecodingError.failed
        }
        end = newPtr
    }
    
    /// Decodes a message from the data.
    ///
    /// - Parameters:
    ///   - body: A closure that decodes the message.
    /// - Returns: The value decoded from the message.
    private mutating func decodeMessage<T>(_ body: (inout ProtobufDecoder) throws -> T) throws -> T {
        try beginMessage()
        defer { end = stack.removeLast() }
        return try body(&self)
    }
    
    /// Decodes a message from the data.
    ///
    /// - Returns: A ProtobufDecodableMessage value.
    private mutating func decodeMessage<T>() throws -> T where T: ProtobufDecodableMessage {
        try beginMessage()
        defer { end = stack.removeLast() }
        return try T(from: &self)
    }
    
    /// Decodes a value from a binary plist.
    ///
    /// NOTE: This is only available on non-WASI platforms.
    ///
    /// - Parameters:
    ///   - data: The plist data.
    ///   - type: The type to decode.
    /// - Returns: The decodable value resulting from the plist data.
    func value<T>(fromBinaryPlist data: Data, type: T.Type = T.self) throws -> T where T: Decodable {
        #if os(WASI)
        fatalError("PropertyListDecoder is not avaiable on WASI")
        #else
        let decoder = PropertyListDecoder()
        decoder.userInfo = userInfo
        let resuls = try decoder.decode([T].self, from: data)
        guard let result = resuls.first else {
            throw DecodingError.failed
        }
        return result
        #endif
    }
}
