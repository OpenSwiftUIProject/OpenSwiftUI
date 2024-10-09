//
//  ProtobufEncoder.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: WIP
//  ID: C7B3AAD101AF9EA76FC322BD6EF713E6

import Foundation

package struct ProtobufEncoder {
    package enum EncodingError: Error {
        case failed
    }
    package typealias Field = ProtobufFormat.Field
    package typealias WireType = ProtobufFormat.WireType
    
    var buffer: UnsafeMutableRawPointer!
    var size: Int = 0
    var capacity: Int = 0
    var stack: [Int] = []
    package var userInfo: [CodingUserInfoKey: Any] = [:]
    
    package static func encoding(_ body: (inout ProtobufEncoder) throws -> Void) rethrows -> Data {
        var encoder = ProtobufEncoder()
        try body(&encoder)
        defer { free(encoder.buffer) }
        return encoder.takeData()
    }
    
    package static func encoding<T>(_ value: T) throws -> Data where T: ProtobufEncodableMessage {
        try encoding { encoder in
            try value.encode(to: &encoder)
        }
    }
    
    private mutating func growBufferSlow(to newSize: Int) -> UnsafeMutableRawPointer {
        let idealSize = malloc_good_size(max(newSize, 0x80))
        guard let newBuffer = realloc(buffer, idealSize) else {
            preconditionFailure("memory allocation failed")
        }
        let oldSize = size
        buffer = newBuffer
        size = newSize
        capacity = idealSize
        return newBuffer + oldSize
    }
    
    private func takeData() -> Data {
        if let buffer {
            Data(bytes: buffer, count: size)
        } else {
            Data()
        }
    }
    
    private func encodeData(_ buffer: UnsafeRawBufferPointer) {
        fatalError("TODO")
    }
    
    private func endLengthDelimited() {
        fatalError("TODO")
    }
}

extension ProtobufEncoder {
    @inline(__always)
    package mutating func boolField(_ tag: UInt, _ value: Bool, defaultValue: Bool? = false) {
        guard value != defaultValue else { return }
        let field = Field(tag, wireType: .varint)
        encodeVarint(field.rawValue)
        encodeVarint(value ? 1 : 0)
    }
    
    @inline(__always)
    package mutating func uintField(_ tag: UInt, _ value: UInt, defaultValue: UInt? = 0) {
        guard value != defaultValue else { return }
        let field = Field(tag, wireType: .varint)
        encodeVarint(field.rawValue)
        encodeVarint(value)
    }

    @inline(__always)
    package mutating func enumField<T>(_ tag: UInt, _ value: T, defaultValue: T?) where T: Equatable, T: ProtobufEnum {
        guard value != defaultValue else { return }
        let field = Field(tag, wireType: .varint)
        encodeVarint(field.rawValue)
        encodeVarint(value.protobufValue)
    }
    
    @inline(__always)
    package mutating func enumField<T>(_ tag: UInt, _ value: T, defaultValue: T?) where T: ProtobufEnum {
        let field = Field(tag, wireType: .varint)
        encodeVarint(field.rawValue)
        encodeVarint(value.protobufValue)
    }
    
    @inline(__always)
    package mutating func uint64Field(_ tag: UInt, _ value: UInt64, defaultValue: UInt64? = 0) {
        guard value != defaultValue else { return }
        let field = Field(tag, wireType: .varint)
        encodeVarint(field.rawValue)
        encodeVarint64(value)
    }
    
    @inline(__always)
    package mutating func intField(_ tag: UInt, _ value: Int, defaultValue: Int? = 0) {
        guard value != defaultValue else { return }
        let field = Field(tag, wireType: .varint)
        encodeVarint(field.rawValue)
        encodeVarintZZ(value)
    }
    
    @inline(__always)
    package mutating func int64Field(_ tag: UInt, _ value: Int64, defaultValue: Int64? = 0) {
        guard value != defaultValue else { return }
        let field = Field(tag, wireType: .varint)
        encodeVarint(field.rawValue)
        encodeVarint64ZZ(value)
    }
    
    @inline(__always)
    package mutating func fixed32Field(_ tag: UInt, _ value: UInt32, defaultValue: UInt32? = 0) {
        guard value != defaultValue else { return }
        let field = Field(tag, wireType: .fixed32)
        encodeVarint(field.rawValue)
        encodeFixed32(value)
    }
    
    @inline(__always)
    package mutating func fixed64Field(_ tag: UInt, _ value: UInt64, defaultValue: UInt64? = 0) {
        guard value != defaultValue else { return }
        let field = Field(tag, wireType: .fixed64)
        encodeVarint(field.rawValue)
        encodeFixed64(value)
    }
    
    @inline(__always)
    package mutating func floatField(_ tag: UInt, _ value: Float, defaultValue: Float? = 0) {
        guard value != defaultValue else { return }
        let field = Field(tag, wireType: .fixed32)
        encodeVarint(field.rawValue)
        encodeFloat(value)
    }
    
    @inline(__always)
    package mutating func doubleField(_ tag: UInt, _ value: Double, defaultValue: Double? = 0) {
        guard value != defaultValue else { return }
        let field = Field(tag, wireType: .fixed64)
        encodeVarint(field.rawValue)
        encodeBitwiseCopyable(value)
    }
    
    @inline(__always)
    package mutating func cgFloatField(_ tag: UInt, _ value: CGFloat, defaultValue: CGFloat? = 0) {
        guard value != defaultValue else { return }
        let field = Field(tag, wireType: value < 65536.0 ? .fixed32 : .fixed64)
        encodeVarint(field.rawValue)
        if value < 65536.0 {
            encodeBitwiseCopyable(Float(value))
        } else {
            encodeBitwiseCopyable(Double(value))
        }
    }
    
    package mutating func dataField(_ tag: UInt, _ value: Data) {
//        let field = Field(tag, wireType: .lengthDelimited)
//        encodeVarint(field.rawValue)
//        encodeVarint(UInt(value.count))
//        encodeBitwiseCopyable(value)
    }
    
    package mutating func dataField(_ tag: UInt, _ value: UnsafeRawBufferPointer) {
//        value.isEmpty
//        let field = Field(tag, wireType: .lengthDelimited)
//        encodeVarint(field.rawValue)
//        encodeVarint(UInt(value.count))
//        encodeBitwiseCopyable(value)
    }
    
    // TODO: Implement encoding methods
    
    @inline(__always)
    package mutating func emptyField(_ tag: UInt) {
        let field = Field(tag, wireType: .lengthDelimited)
        encodeVarint(field.rawValue)
//        encodeVarint(0)
//        fatalError()
//        endLengthDelimited()
    }
}


extension ProtobufEncoder {
    @inline(__always)
    package mutating func boolField<T>(_ tag: T, _ value: Bool, defaultValue: Bool? = false) where T: ProtobufTag {
        boolField(tag.rawValue, value, defaultValue: defaultValue)
    }
    
    // TODO: Implement encoding methods
}


extension ProtobufEncoder {
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
    
    package mutating func encodeVarint64(_ value: UInt64) {
        encodeVarint(UInt(value))
    }
    
    // (n << 1) ^ (n >> 63)
    // See https://protobuf.dev/programming-guides/encoding/#signed-ints
    package mutating func encodeVarintZZ(_ value: Int) {
        encodeVarint(UInt(bitPattern: (value << 1) ^ (value >> 63)))
    }
    
    package mutating func encodeVarint64ZZ(_ value: Int64) {
        encodeVarintZZ(Int(value))
    }
    
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
    
    package mutating func encodeBool(_ value: Bool) {
        encodeBitwiseCopyable(value)
    }
    
    package mutating func encodeFixed32(_ value: UInt32) {
        encodeBitwiseCopyable(value)
    }
    
    package mutating func encodeFixed64(_ value: UInt64) {
        encodeBitwiseCopyable(value)
    }
    
    package mutating func encodeFloat(_ value: Float) {
        encodeBitwiseCopyable(value)
    }
}
