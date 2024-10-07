//
//  ProtobufMessage.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: WIP

// MARK: - ProtobufMessage

package protocol ProtobufEncodableMessage {
    func encode(to encoder: inout ProtobufEncoder) throws
}
package protocol ProtobufDecodableMessage {
    init(from decoder: inout ProtobufDecoder) throws
}

package typealias ProtobufMessage = ProtobufDecodableMessage & ProtobufEncodableMessage

// MARK: - ProtobufEnum

package protocol ProtobufEnum {
    var protobufValue: UInt { get }
    init?(protobufValue: UInt)
}

extension ProtobufEnum where Self: RawRepresentable, RawValue: BinaryInteger {
    package var protobufValue: UInt {
        UInt(rawValue)
    }
    
    package init?(protobufValue: UInt) {
        self.init(rawValue: RawValue(protobufValue))
    }
}

// MARK: - ProtobufTag

package protocol ProtobufTag: Equatable {
    var rawValue: UInt { get }
    init(rawValue: UInt)
}

// MARK: - ProtobufFormat

package enum ProtobufFormat {
    package struct WireType: Equatable {
        package let rawValue: UInt
        package init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        package static var varint: ProtobufFormat.WireType { WireType(rawValue: 0) }
        package static var fixed64: ProtobufFormat.WireType { WireType(rawValue: 1) }
        package static var lengthDelimited: ProtobufFormat.WireType { WireType(rawValue: 2) }
        package static var fixed32: ProtobufFormat.WireType { WireType(rawValue: 5) }
    }
    
    package struct Field: Equatable {
        package var rawValue: UInt
        package init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        // field = (field_number << 3) | wire_type
        // See https://protobuf.dev/programming-guides/encoding/
        package init(_ tag: UInt, wireType: WireType) {
            rawValue = (tag << 3) | wireType.rawValue
        }
        
        package var tag: UInt {
            rawValue >> 3
        }
        
        package var wireType: WireType {
            WireType(rawValue: rawValue & 7)
        }
        
        @inline(__always)
        package func tag<T>(as: T.Type = T.self) -> T where T: ProtobufTag {
            T(rawValue: tag)
        }
    }
}

// MARK: - CoddleByProtobuf [WIP]

package protocol CodaleByProtobuf: Codable, ProtobufMessage {}

extension CodaleByProtobuf {
    func encode(to encoder: any Encoder) throws {
        fatalError("Blocked by ProtobufEncoder")
    }
    
    init(from decoder: any Decoder) throws {
        fatalError("Blocked by ProtobufDecoder")
    }
}

// MARK: - ProtobufCodable [WIP]

@propertyWrapper
package struct ProtobufCodable<Value>: Swift.Codable where Value: ProtobufMessage {
    package var wrappedValue: Value
    package init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    package func encode(to encoder: any Encoder) throws {
        fatalError("Blocked by ProtobufEncoder")
    }
    package init(from decoder: any Decoder) throws {
        fatalError("Blocked by ProtobufDecoder")
    }
}

extension ProtobufCodable: Equatable where Value: Equatable {
    package static func == (lhs: ProtobufCodable<Value>, rhs: ProtobufCodable<Value>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}
