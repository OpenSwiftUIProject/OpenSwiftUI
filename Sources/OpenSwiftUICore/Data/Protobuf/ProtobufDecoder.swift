//
//  ProtobufDecoder.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: WIP

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
}

extension ProtobufDecoder {
    // TODO: Implement decoding methods
}
