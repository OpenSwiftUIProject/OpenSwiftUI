//
//  BitVector64.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

import Foundation

@_spi(ForOpenSwiftUIOnly)
public struct BitVector64: OptionSet {
    public var rawValue: UInt64
    
    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }
    
    @inlinable
    public init() { self.init(rawValue: 0) }
    
    package subscript(index: Int) -> Bool {
        get {
            rawValue & (1 << UInt(index)) != 0
        }
        set {
            if newValue {
                rawValue |= 1 << UInt(index)
            } else {
                rawValue &= ~(1 << UInt(index))
            }
        }
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension BitVector64: Sendable {}

extension Array {
    package func mapBool(_ predicate: (Element) -> Bool) -> BitVector64 {
        var result = BitVector64()
        for (index, element) in enumerated() {
            result[index] = predicate(element)
        }
        return result
    }
}
