//
//  ProtobufEncoder.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Complete
//  ID: C7B3AAD101AF9EA76FC322BD6EF713E6

import Foundation

/// An object that encodes instances of a data type as protobuf objects.
package struct ProtobufEncoder {
    /// An error that can occur during `ProtobufEncoder` encoding.
    package enum EncodingError: Error {
        case failed
    }
    
    /// A type representing a field in a protobuf encoding.
    package typealias Field = ProtobufFormat.Field
    
    /// A type representing the wire type of a protobuf encoding.
    package typealias WireType = ProtobufFormat.WireType
    
    /// The buffer being encoded.
    var buffer: UnsafeMutableRawPointer!
    
    /// The size of the buffer.
    var size: Int = 0
    
    /// The capacity of the buffer.
    var capacity: Int = 0
    
    /// A stack of pointers for nested messages.
    var stack: [Int] = []
    
    /// User-defined information.
    package var userInfo: [CodingUserInfoKey: Any] = [:]
    
    /// Takes the encoded data.
    ///
    /// - Returns: The encoded data.
    private func takeData() -> Data {
        if let buffer {
            Data(bytes: buffer, count: size)
        } else {
            Data()
        }
    }
    
    /// Encodes a value using a closure.
    ///
    /// - Parameters:
    ///   - body: A closure that encodes the value.
    /// - Returns: The encoded data.
    package static func encoding(_ body: (inout ProtobufEncoder) throws -> Void) rethrows -> Data {
        var encoder = ProtobufEncoder()
        try body(&encoder)
        defer { free(encoder.buffer) }
        return encoder.takeData()
    }
    
    /// Encodes a value to a protobuf representation.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    /// - Returns: The encoded data.
    package static func encoding<T>(_ value: T) throws -> Data where T: ProtobufEncodableMessage {
        try encoding { encoder in
            try value.encode(to: &encoder)
        }
    }
    
    /// Grows the buffer to a new size.
    ///
    /// - Parameter newSize: The new size of the buffer.
    /// - Returns: A pointer to the new buffer.
    private mutating func growBufferSlow(to newSize: Int) -> UnsafeMutableRawPointer {
        #if canImport(Darwin)
        let idealSize = malloc_good_size(max(newSize, 0x80))
        #else
        func roundUpToPowerOfTwo(_ value: Int) -> Int {
            guard value > 0 else { return 1 }

            var v = value
            v -= 1
            v |= v >> 1
            v |= v >> 2
            v |= v >> 4
            v |= v >> 8
            v |= v >> 16
            v |= v >> 32 // For 64-bit systems
            v += 1

            return v
        }
        let idealSize = roundUpToPowerOfTwo(max(newSize, 0x80))
        #endif
        guard let newBuffer = realloc(buffer, idealSize) else {
            preconditionFailure("memory allocation failed")
        }
        let oldSize = size
        buffer = newBuffer
        size = newSize
        capacity = idealSize
        return newBuffer + oldSize
    }
    
    /// Ends a length-delimited field.
    private mutating func endLengthDelimited() {
        let lengthPosition = stack.removeLast()
        let length = size - (lengthPosition + 1)
        let highBit = 64 - (length | 1).leadingZeroBitCount
        let count = (highBit + 6) / 7
        let oldSize = size
        let newSize = size - 1 + count
        var pointer: UnsafeMutableRawPointer
        if capacity < newSize {
            pointer = growBufferSlow(to: newSize)
        } else {
            size = newSize
            pointer = buffer.advanced(by: oldSize)
        }
        let firstLengthBytePointer = pointer.advanced(by: -(length + 1))
        if count != 1 {
            memmove(firstLengthBytePointer.advanced(by: count), firstLengthBytePointer.advanced(by: 1), length)
        }
        var currentPointer = firstLengthBytePointer
        var currentValue = length
        while currentValue >= 0x80 {
            currentPointer.storeBytes(of: UInt8(currentValue & 0x7F) | 0x80, as: UInt8.self)
            currentPointer += 1
            currentValue >>= 7
        }
        currentPointer.storeBytes(of: UInt8(currentValue), as: UInt8.self)
    }
}

extension ProtobufEncoder {
    /// Encodes a boolean field.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func boolField(_ tag: UInt, _ value: Bool, defaultValue: Bool? = false) {
        guard value != defaultValue else { return }
        let field = Field(tag, wireType: .varint)
        encodeVarint(field.rawValue)
        encodeVarint(value ? 1 : 0)
    }
    
    /// Encodes an unsigned integer field.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func uintField(_ tag: UInt, _ value: UInt, defaultValue: UInt? = 0) {
        guard value != defaultValue else { return }
        let field = Field(tag, wireType: .varint)
        encodeVarint(field.rawValue)
        encodeVarint(value)
    }

    /// Encodes an enum field.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func enumField<T>(_ tag: UInt, _ value: T, defaultValue: T?) where T: Equatable, T: ProtobufEnum {
        guard value != defaultValue else { return }
        enumField(tag, value)
    }
    
    /// Encodes an enum field.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    @inline(__always)
    package mutating func enumField<T>(_ tag: UInt, _ value: T) where T: ProtobufEnum {
        let field = Field(tag, wireType: .varint)
        encodeVarint(field.rawValue)
        encodeVarint(value.protobufValue)
    }
    
    /// Encodes an unsigned 64-bit integer field.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func uint64Field(_ tag: UInt, _ value: UInt64, defaultValue: UInt64? = 0) {
        guard value != defaultValue else { return }
        let field = Field(tag, wireType: .varint)
        encodeVarint(field.rawValue)
        encodeVarint64(value)
    }
    
    /// Encodes a signed integer field.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func intField(_ tag: UInt, _ value: Int, defaultValue: Int? = 0) {
        guard value != defaultValue else { return }
        let field = Field(tag, wireType: .varint)
        encodeVarint(field.rawValue)
        encodeVarintZZ(value)
    }
    
    /// Encodes a signed 64-bit integer field.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func int64Field(_ tag: UInt, _ value: Int64, defaultValue: Int64? = 0) {
        guard value != defaultValue else { return }
        let field = Field(tag, wireType: .varint)
        encodeVarint(field.rawValue)
        encodeVarint64ZZ(value)
    }
    
    /// Encodes a fixed 32-bit integer field.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func fixed32Field(_ tag: UInt, _ value: UInt32, defaultValue: UInt32? = 0) {
        guard value != defaultValue else { return }
        let field = Field(tag, wireType: .fixed32)
        encodeVarint(field.rawValue)
        encodeFixed32(value)
    }
    
    /// Encodes a fixed 64-bit integer field.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func fixed64Field(_ tag: UInt, _ value: UInt64, defaultValue: UInt64? = 0) {
        guard value != defaultValue else { return }
        let field = Field(tag, wireType: .fixed64)
        encodeVarint(field.rawValue)
        encodeFixed64(value)
    }
    
    /// Encodes a float field.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func floatField(_ tag: UInt, _ value: Float, defaultValue: Float? = 0) {
        guard value != defaultValue else { return }
        let field = Field(tag, wireType: .fixed32)
        encodeVarint(field.rawValue)
        encodeFloat(value)
    }
    
    /// Encodes a double field.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func doubleField(_ tag: UInt, _ value: Double, defaultValue: Double? = 0) {
        guard value != defaultValue else { return }
        let field = Field(tag, wireType: .fixed64)
        encodeVarint(field.rawValue)
        encodeBitwiseCopyable(value)
    }
    
    /// Encodes a CGFloat field.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func cgFloatField(_ tag: UInt, _ value: CGFloat, defaultValue: CGFloat? = 0) {
        guard value != defaultValue else { return }
        let field = Field(tag, wireType: value < 65536.0 ? .fixed32 : .fixed64)
        encodeVarint(field.rawValue)
        if value < 65536.0 {
            encodeFloat(Float(value))
        } else {
            encodeDouble(Double(value))
        }
    }
    
    /// Encodes a data field.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    package mutating func dataField(_ tag: UInt, _ value: Data) {
        value.withUnsafeBytes { buffer in
            dataField(tag, buffer)
        }
    }
    
    /// Encodes a data field.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    package mutating func dataField(_ tag: UInt, _ value: UnsafeRawBufferPointer) {
        guard !value.isEmpty else {
            return
        }
        let field = Field(tag, wireType: .lengthDelimited)
        encodeVarint(field.rawValue)
        encodeData(value)
    }
    
    /// Encodes a packed field.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - body: A closure that encodes the value.
    @inline(__always)
    package mutating func packedField(_ tag: UInt, _ body: (inout ProtobufEncoder) -> Void) {
        let field = Field(tag, wireType: .lengthDelimited)
        encodeVarint(field.rawValue)
        stack.append(size)
        size += 1
        body(&self)
        endLengthDelimited()
    }
    
    /// Encodes a message field.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - body: A closure that encodes the value.
    @inline(__always)
    package mutating func messageField(_ tag: UInt, _ body: (inout ProtobufEncoder) throws -> Void) rethrows {
        let field = Field(tag, wireType: .lengthDelimited)
        encodeVarint(field.rawValue)
        stack.append(size)
        size += 1
        try body(&self)
        endLengthDelimited()
    }
    
    /// Encodes a message field with a default value.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func messageField<T>(_ tag: UInt, _ value: T, defaultValue: T) throws where T: Equatable, T: ProtobufEncodableMessage {
        guard value != defaultValue else { return }
        try messageField(tag, value)
    }
    
    /// Encodes a message field.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    package mutating func messageField<T>(_ tag: UInt, _ value: T) throws where T: ProtobufEncodableMessage {
        let field = Field(tag, wireType: .lengthDelimited)
        encodeVarint(field.rawValue)
        try encodeMessage(value)
    }
    
    /// Encodes a string field.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    private mutating func stringFieldAlways(_ tag: UInt, _ value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw EncodingError.failed
        }
        dataField(tag, data)
    }
    
    /// Encodes a string field.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func stringField(_ tag: UInt, _ value: String, defaultValue: String? = "") throws {
        guard value != defaultValue else { return }
        try stringFieldAlways(tag, value)
    }
    
    /// Encodes a encodeable data into a binary plist data.
    ///
    /// NOTE: This is only available on non-WASI platforms.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    /// - Returns: The encoded binary plist data.
    func binaryPlistData<T>(for value: T) throws -> Data where T: Encodable {
        #if os(WASI)
        fatalError("PropertyListEncoder is not avaiable on WASI")
        #else
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        encoder.userInfo = userInfo
        return try encoder.encode([value])
        #endif
    }
    
    /// Encodes a codable field with a default value.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func codableField<T>(_ tag: UInt, _ value: T, defaultValue: T) throws where T: Encodable, T: Equatable {
        guard value != defaultValue else { return }
        try codableField(tag, value)
    }
    
    /// Encodes a codable field.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    package mutating func codableField<T>(_ tag: UInt, _ value: T) throws where T: Encodable {
        let field = Field(tag, wireType: .lengthDelimited)
        encodeVarint(field.rawValue)
        let data = try binaryPlistData(for: value)
        data.withUnsafeBytes { buffer in
            encodeData(buffer)
        }
    }
    
    /// Encodes an empty field.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    package mutating func emptyField(_ tag: UInt) {
        let field = Field(tag, wireType: .lengthDelimited)
        encodeVarint(field.rawValue)
        stack.append(size)
        size += 1
        endLengthDelimited()
    }
}


extension ProtobufEncoder {
    /// Encodes a boolean field with tag.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func boolField<T>(_ tag: T, _ value: Bool, defaultValue: Bool? = false) where T: ProtobufTag {
        boolField(tag.rawValue, value, defaultValue: defaultValue)
    }
    
    /// Encodes an unsigned integer field with tag.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func uintField<T>(_ tag: T, _ value: UInt, defaultValue: UInt? = 0) where T: ProtobufTag {
        uintField(tag.rawValue, value, defaultValue: defaultValue)
    }
    
    /// Encodes an enum field with tag.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func enumField<T, U>(_ tag: T, _ value: U, defaultValue: U?) where T: ProtobufTag, U: Equatable, U: ProtobufEnum {
        enumField(tag.rawValue, value, defaultValue: defaultValue)
    }
    
    /// Encodes an enum field with tag.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    @inline(__always)
    package mutating func enumField<T, U>(_ tag: T, _ value: U) where T: ProtobufTag, U: ProtobufEnum {
        enumField(tag.rawValue, value)
    }
    
    /// Encodes an unsigned 64-bit integer field with tag.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func uint64Field<T>(_ tag: T, _ value: UInt64, defaultValue: UInt64? = 0) where T: ProtobufTag {
        uint64Field(tag.rawValue, value, defaultValue: defaultValue)
    }
    
    /// Encodes a signed integer field with tag.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func intField<T>(_ tag: T, _ value: Int, defaultValue: Int? = 0) where T: ProtobufTag {
        intField(tag.rawValue, value, defaultValue: defaultValue)
    }
    
    /// Encodes a signed 64-bit integer field with tag.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func int64Field<T>(_ tag: T, _ value: Int64, defaultValue: Int64? = 0) where T: ProtobufTag {
        int64Field(tag.rawValue, value, defaultValue: defaultValue)
    }
    
    /// Encodes a fixed 32-bit integer field with tag.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func fixed32Field<T>(_ tag: T, _ value: UInt32, defaultValue: UInt32? = 0) where T: ProtobufTag {
        fixed32Field(tag.rawValue, value, defaultValue: defaultValue)
    }
    
    /// Encodes a fixed 64-bit integer field with tag.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func fixed64Field<T>(_ tag: T, _ value: UInt64, defaultValue: UInt64? = 0) where T: ProtobufTag {
        fixed64Field(tag.rawValue, value, defaultValue: defaultValue)
    }
    
    /// Encodes a float field with tag.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func floatField<T>(_ tag: T, _ value: Float, defaultValue: Float? = 0) where T: ProtobufTag {
        floatField(tag.rawValue, value, defaultValue: defaultValue)
    }
    
    /// Encodes a double field with tag.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func doubleField<T>(_ tag: T, _ value: Double, defaultValue: Double? = 0) where T: ProtobufTag {
        doubleField(tag.rawValue, value, defaultValue: defaultValue)
    }
    
    /// Encodes a CGFloat field with tag.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func cgFloatField<T>(_ tag: T, _ value: CGFloat, defaultValue: CGFloat? = 0) where T: ProtobufTag {
        cgFloatField(tag.rawValue, value, defaultValue: defaultValue)
    }
    
    /// Encodes a data field with tag.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    @inline(__always)
    package mutating func dataField<T>(_ tag: T, _ value: Data) where T: ProtobufTag {
        dataField(tag.rawValue, value)
    }
    
    /// Encodes a data field with tag.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    @inline(__always)
    package mutating func dataField<T>(_ tag: T, _ value: UnsafeRawBufferPointer) where T: ProtobufTag {
        dataField(tag.rawValue, value)
    }
    
    /// Encodes a packed field with tag.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - body: A closure that encodes the value.
    @inline(__always)
    package mutating func packedField<T>(_ tag: T, _ body: (inout ProtobufEncoder) -> Void) where T: ProtobufTag {
        packedField(tag.rawValue, body)
    }
    
    /// Encodes a message field with tag.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - body: A closure that encodes the value.
    @inline(__always)
    package mutating func messageField<T>(_ tag: T, _ body: (inout ProtobufEncoder) throws -> Void) rethrows where T: ProtobufTag {
        try messageField(tag.rawValue, body)
    }
    
    /// Encodes a message field with tag and default value.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func messageField<T, U>(_ tag: T, _ value: U, defaultValue: U) throws where T: ProtobufTag, U: Equatable, U: ProtobufEncodableMessage {
        try messageField(tag.rawValue, value, defaultValue: defaultValue)
    }
    
    /// Encodes a message field with tag.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    @inline(__always)
    package mutating func messageField<T>(_ tag: T, _ value: ProtobufEncodableMessage) throws where T: ProtobufTag {
        try messageField(tag.rawValue, value)
    }
    
    /// Encodes a string field with tag.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func stringField<T>(_ tag: T, _ value: String, defaultValue: String? = "") throws where T: ProtobufTag {
        try stringField(tag.rawValue, value, defaultValue: defaultValue)
    }
    
    /// Encodes a codable field with tag and default value.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    ///   - defaultValue: The default value of the field.
    @inline(__always)
    package mutating func codableField<T>(_ tag: T, _ value: T, defaultValue: T) throws where T: ProtobufTag, T: Encodable, T: Equatable {
        try codableField(tag.rawValue, value, defaultValue: defaultValue)
    }
    
    /// Encodes a codable field with tag.
    ///
    /// - Parameters:
    ///   - tag: The tag of the field.
    ///   - value: The value to encode.
    @inline(__always)
    package mutating func codableField<T>(_ tag: T, _ value: T) throws where T: ProtobufTag, T: Encodable {
        try codableField(tag.rawValue, value)
    }
}

extension ProtobufEncoder {
    /// Encodes a varint.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    package mutating func encodeVarint(_ value: UInt) {
        let highBit = 64 - (value | 1).leadingZeroBitCount
        let count = (highBit + 6) / 7
        let oldSize = size
        let newSize = size + count
        var pointer: UnsafeMutableRawPointer

        if capacity < newSize {
            pointer = growBufferSlow(to: newSize)
        } else {
            size = newSize
            pointer = buffer.advanced(by: oldSize)
        }

        var currentValue = value
        while currentValue >= 0x80 {
            pointer.storeBytes(of: UInt8(currentValue & 0x7F) | 0x80, as: UInt8.self)
            pointer += 1
            currentValue >>= 7
        }
        pointer.storeBytes(of: UInt8(currentValue), as: UInt8.self)
    }
    
    /// Encodes a varint.
    package mutating func encodeVarint64(_ value: UInt64) {
        encodeVarint(UInt(value))
    }
    
    // (n << 1) ^ (n >> 63)
    // See https://protobuf.dev/programming-guides/encoding/#signed-ints
    /// Encodes a zigzag varint for Int value.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    package mutating func encodeVarintZZ(_ value: Int) {
        encodeVarint(UInt(bitPattern: (value << 1) ^ (value >> 63)))
    }
    
    /// Encodes a zigzag varint for Int64 value.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    package mutating func encodeVarint64ZZ(_ value: Int64) {
        encodeVarintZZ(Int(value))
    }
    
    #if compiler(>=6.0)
    /// Encodes a bitwise copyable value.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    @inline(__always)
    private mutating func encodeBitwiseCopyable<T>(_ value: T) where T: BitwiseCopyable {
        let oldSize = size
        let newSize = oldSize + MemoryLayout<T>.size
        if capacity < newSize {
            growBufferSlow(to: newSize).storeBytes(of: value, as: T.self)
        } else {
            size = newSize
            buffer.advanced(by: oldSize).storeBytes(of: value, as: T.self)
        }
    }
    #else // FIXME: Remove this after we drop WASI 5.10 support
    /// Encodes a bitwise copyable value.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    @inline(__always)
    private mutating func encodeBitwiseCopyable<T>(_ value: T) {
        let oldSize = size
        let newSize = oldSize + MemoryLayout<T>.size
        if capacity < newSize {
            growBufferSlow(to: newSize).storeBytes(of: value, as: T.self)
        } else {
            size = newSize
            buffer.advanced(by: oldSize).storeBytes(of: value, as: T.self)
        }
    }
    #endif
    
    /// Encodes a boolean value.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    package mutating func encodeBool(_ value: Bool) {
        encodeBitwiseCopyable(value)
    }
    
    /// Encodes a fixed 32-bit integer value.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    package mutating func encodeFixed32(_ value: UInt32) {
        encodeBitwiseCopyable(value)
    }
    
    /// Encodes a fixed 64-bit integer value.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    package mutating func encodeFixed64(_ value: UInt64) {
        encodeBitwiseCopyable(value)
    }
    
    /// Encodes a float value.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    package mutating func encodeFloat(_ value: Float) {
        encodeBitwiseCopyable(value)
    }
    
    /// Encodes a double value.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    package mutating func encodeDouble(_ value: Double) {
        encodeBitwiseCopyable(value)
    }
    
    /// Encodes a data value.
    ///
    /// - Parameters:
    ///   - dataBuffer: The data to encode.
    package mutating func encodeData(_ dataBuffer: UnsafeRawBufferPointer) {
        // Encode LEN
        let dataBufferCount = dataBuffer.count
        encodeVarint(UInt(bitPattern: dataBufferCount))
        guard let baseAddress = dataBuffer.baseAddress,
              !dataBuffer.isEmpty else {
            return
        }
        let oldSize = size
        let newSize = size + dataBufferCount
        
        let pointer: UnsafeMutableRawPointer
        if capacity < newSize {
            pointer = growBufferSlow(to: newSize)
        } else {
            size = newSize
            pointer = buffer.advanced(by: oldSize)
        }
        memcpy(pointer, baseAddress, dataBufferCount)
    }
    
    /// Encodes a message.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    package mutating func encodeMessage<T>(_ value: T) throws where T: ProtobufEncodableMessage {
        stack.append(size)
        size += 1
        try value.encode(to: &self)
        endLengthDelimited()
    }
}
