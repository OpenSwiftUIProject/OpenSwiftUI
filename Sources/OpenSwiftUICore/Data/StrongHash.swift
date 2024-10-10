//
//  StrongHash.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Blocked by OGTypeGetSignature and RBUUID

#if OPENSWIFTUI_SWIFT_CRYPTO
internal import Crypto
#elseif canImport(CommonCrypto)
internal import CommonCrypto
#endif

import Foundation

package protocol StronglyHashable {
  func hash(into hasher: inout StrongHasher)
}

package struct StrongHash: Hashable, StronglyHashableByBitPattern, Codable, CustomStringConvertible {
    package var words: (UInt32, UInt32, UInt32, UInt32, UInt32)
    package init() {
        words = (.zero, .zero, .zero, .zero, .zero)
    }
    
    package init<T>(of value: T) where T: StronglyHashable {
        var hasher = StrongHasher()
        value.hash(into: &hasher)
        self = hasher.finalize()
    }
    
    package init<T>(encodable value: T) throws where T: Encodable {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(value)
        var hasher = StrongHasher()
        data.hash(into: &hasher)
        self = hasher.finalize()
    }
    
    package static func random() -> StrongHash {
        StrongHash(of: UUID())
    }
    
    package static func == (lhs: StrongHash, rhs: StrongHash) -> Bool {
        lhs.words.0 == rhs.words.0 &&
        lhs.words.1 == rhs.words.1 &&
        lhs.words.2 == rhs.words.2 &&
        lhs.words.3 == rhs.words.3 &&
        lhs.words.4 == rhs.words.4
    }
    
    package func hash(into hasher: inout Hasher) {
        withUnsafeTemporaryAllocation(of: UInt32.self, capacity: 5) { pointer in
            pointer.initializeElement(at: 0, to: words.0)
            pointer.initializeElement(at: 1, to: words.1)
            pointer.initializeElement(at: 2, to: words.2)
            pointer.initializeElement(at: 3, to: words.3)
            pointer.initializeElement(at: 4, to: words.4)
            hasher.combine(bytes: UnsafeRawBufferPointer(pointer))
        }
    }
    
    package var description: String {
        String(format: "#%08x%08x%08x%08x%08x", words.4, words.3, words.2, words.1, words.0)
    }
    
    package func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(words.0)
        try container.encode(words.1)
        try container.encode(words.2)
        try container.encode(words.3)
        try container.encode(words.4)
    }
    
    package init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        words.0 = try container.decode(UInt32.self)
        words.1 = try container.decode(UInt32.self)
        words.2 = try container.decode(UInt32.self)
        words.3 = try container.decode(UInt32.self)
        words.4 = try container.decode(UInt32.self)
    }
}

package struct StrongHasher {
    #if OPENSWIFTUI_SWIFT_CRYPTO
    var state: Insecure.SHA1
    #elseif canImport(CommonCrypto)
    var state: CC_SHA1state_st
    #endif
    
    package init() {
        #if OPENSWIFTUI_SWIFT_CRYPTO
        state = Insecure.SHA1()
        #elseif canImport(CommonCrypto)
        var context = CC_SHA1_CTX()
        CC_SHA1_Init(&context)
        state = context
        #endif
    }
    
    package mutating func finalize() -> StrongHash {
        #if OPENSWIFTUI_SWIFT_CRYPTO
        var hash = StrongHash()
        let digest = state.finalize()
        digest.withUnsafeBytes { pointer in
            pointer.withMemoryRebound(to: UInt32.self) { buffer in
                hash.words = (buffer[0], buffer[1], buffer[2], buffer[3], buffer[4])
            }
        }
        return hash
        #elseif canImport(CommonCrypto)
        withUnsafeTemporaryAllocation(of: UInt8.self, capacity: 20) { pointer in
            CC_SHA1_Final(pointer.baseAddress, &state)
            var hash = StrongHash()
            pointer.withMemoryRebound(to: UInt32.self) { buffer in
                hash.words = (buffer[0], buffer[1], buffer[2], buffer[3], buffer[4])
            }
            return hash
        }
        #endif
    }
    
    mutating func combineBytes(_ ptr: UnsafeRawBufferPointer) {
        #if OPENSWIFTUI_SWIFT_CRYPTO
        state.update(bufferPointer: ptr)
        #elseif canImport(CommonCrypto)
        combineBytes(UnsafeRawPointer(ptr.baseAddress!), count: ptr.count)
        #endif
    }
    
    #if !OPENSWIFTUI_SWIFT_CRYPTO && canImport(CommonCrypto)
    package mutating func combineBytes(_ ptr: UnsafeRawPointer, count: Int) {
        CC_SHA1_Update(&state, ptr, CC_LONG(count))
    }
    #endif
    
    package mutating func combineBitPattern<T>(_ x: T) {
        withUnsafeBytes(of: x) { buffer in
            combineBytes(buffer)
        }
    }
    
    package mutating func combine<T>(_ x: T) where T: StronglyHashable {
        x.hash(into: &self)
    }
    
    package mutating func combineType(_ type: any Any.Type) {
//        let signature = OGTypeGetSignature
//        CC_SHA1_Update(&state, signature, 20)
        fatalError("Blocked by latest OGTypeGetSignature")
    }
}

extension String: StronglyHashable {
    package func hash(into hasher: inout StrongHasher) {
        guard !isEmpty else { return }
        let cString = utf8CString
        cString.withUnsafeBufferPointer { buffer in
            hasher.combineBytes(UnsafeRawBufferPointer(buffer))
        }
    }
}

extension Data: StronglyHashable {
    package func hash(into hasher: inout StrongHasher) {
        withUnsafeBytes { (pointer: UnsafeRawBufferPointer) in
            hasher.combineBytes(pointer)
        }
    }
}

extension Bool: StronglyHashable {
    package func hash(into hasher: inout StrongHasher) {
        hasher.combineBitPattern(self)
    }
}

extension Optional where Wrapped: StronglyHashable {
    package func hash(into hasher: inout StrongHasher) {
        guard let value = self else { return }
        value.hash(into: &hasher)
    }
}

extension RawRepresentable where RawValue: StronglyHashable {
    package func hash(into hasher: inout StrongHasher) {
        rawValue.hash(into: &hasher)
    }
}

package protocol StronglyHashableByBitPattern: StronglyHashable {}

extension StronglyHashableByBitPattern {
    package func hash(into hasher: inout StrongHasher) {
        hasher.combineBitPattern(self)
    }
}
extension Int: StronglyHashableByBitPattern {}
extension UInt: StronglyHashableByBitPattern {}
extension Int8: StronglyHashableByBitPattern {}
extension UInt8: StronglyHashableByBitPattern {}
extension Int16: StronglyHashableByBitPattern {}
extension UInt16: StronglyHashableByBitPattern {}
extension Int32: StronglyHashableByBitPattern {}
extension UInt32: StronglyHashableByBitPattern {}
extension Int64: StronglyHashableByBitPattern {}
extension UInt64: StronglyHashableByBitPattern {}
extension Float: StronglyHashableByBitPattern {}
extension Double: StronglyHashableByBitPattern {}
extension UUID: StronglyHashableByBitPattern {}

//extension RenderBox.RBUUID {
//  package init(hash: StrongHash)
//}

extension StrongHash: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) {
        encoder.packedField(1) { encoder in
            encoder.encodeFixed32(words.0)
            encoder.encodeFixed32(words.1)
            encoder.encodeFixed32(words.2)
            encoder.encodeFixed32(words.3)
            encoder.encodeFixed32(words.4)
        }
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
        var hash = StrongHash()
        var count = 0
        while count < 5 {
            guard let field = try decoder.nextField() else {
                self = hash
                return
            }
            if field.tag == 1 {
                let result = try decoder.fixed32Field(field)
                switch count {
                case 0: hash.words.0 = result
                case 1: hash.words.1 = result
                case 2: hash.words.2 = result
                case 3: hash.words.3 = result
                case 4: hash.words.4 = result
                default: break
                }
                count += 1
            } else {
                try decoder.skipField(field)
            }
        }
        self = hash
    }
}
