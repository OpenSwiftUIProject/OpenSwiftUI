//
//  ProtobufDecoder.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: WIP
//  ID: FFA06CAF6B06DC3E21EC75547A0CD421

import Foundation

package struct ProtobufDecoder {
    package enum DecodingError: Error {
        case failed
    }
    
    package typealias Field = ProtobufFormat.Field
    package typealias WireType = ProtobufFormat.WireType
    
    var data: NSData
    var ptr: UnsafeRawPointer
    var end: UnsafeRawPointer
    var packedField: Field = Field(rawValue: 0)
    var packedEnd: UnsafeRawPointer
    var stack: [UnsafeRawPointer] = []
    package var userInfo: [CodingUserInfoKey : Any] = [:]
    
    package init(_ data: Data) {
        let nsData = data as NSData
        self.data = nsData
        let ptr = nsData.bytes
        self.ptr = ptr
        self.end = ptr + nsData.length
        self.packedEnd = ptr
    }
    
    private mutating func decodeVariant() throws -> UInt {
        var value: UInt = 0
        var shift: UInt = 0
        while true {
            guard ptr < end else {
                throw DecodingError.failed
            }
            let byte = ptr.load(as: UInt8.self)
            ptr += 1
            value |= UInt(byte & 0x7f) << shift
            if byte & 0x80 == 0 {
                return value
            }
            shift += 7
        }
        return 0
    }
    
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
    
    private mutating func beginMessage() throws {
        fatalError()
    }
    
    private mutating func decodeMessage<T>(_ body: (inout ProtobufEncoder) throws -> T) throws -> T {
        fatalError()
    }
    
    private mutating func decodeMessage<T>() throws -> T where T: ProtobufDecodableMessage {
        fatalError()
    }
}

extension ProtobufDecoder {
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
    
    package mutating func enumField<T>(_ field: ProtobufDecoder.Field) throws -> T? where T: ProtobufEnum {
        try T(protobufValue: uintField(field))
    }
    
    package mutating func uint8Field(_ field: ProtobufDecoder.Field) throws -> UInt8 {
        try UInt8(uintField(field))
    }
    
    package mutating func uint16Field(_ field: ProtobufDecoder.Field) throws -> UInt16 {
        try UInt16(uintField(field))
    }
    
    package mutating func uint32Field(_ field: ProtobufDecoder.Field) throws -> UInt32 {
        try UInt32(uintField(field))
    }
    
    package mutating func uint64Field(_ field: ProtobufDecoder.Field) throws -> UInt64 {
        try UInt64(uintField(field))
    }
    
    package mutating func intField(_ field: ProtobufDecoder.Field) throws -> Int {
        let value = Int(bitPattern: try uintField(field))
        return Int(bitPattern: UInt(bitPattern: (value >> 1)) ^ UInt(bitPattern: -(value & 1)))
    }
    
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
        let value = ptr.load(as: UInt32.self)
        ptr = newPtr
        return value
    }
    
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
        let value = ptr.load(as: UInt64.self)
        ptr = newPtr
        return value
    }
    
    // TODO
}
