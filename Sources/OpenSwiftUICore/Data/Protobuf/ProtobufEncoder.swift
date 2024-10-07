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
    
    var buffer: UnsafeMutableRawPointer = .init(bitPattern: 0)!
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
    
    private func takeData() -> Data {
        Data(bytes: buffer, count: size)
    }
}

extension ProtobufEncoder {
    // TODO: Implement encoding methods
}
