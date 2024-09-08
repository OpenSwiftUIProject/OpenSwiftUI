//
//  BitVector64.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: WIP

import Foundation

@_spi(ForOpenSwiftUIOnly)
public struct BitVector64: OptionSet {
    @_spi(ForOpenSwiftUIOnly)
    public var rawValue: UInt64
    
    @_spi(ForOpenSwiftUIOnly)
    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }
    
    @_spi(ForOpenSwiftUIOnly)
    @inlinable
    public init() { self.init(rawValue: 0) }
    
    @_spi(ForOpenSwiftUIOnly)
    package subscript(index: Int) -> Bool {
        get { fatalError("TODO") }
        set { fatalError("TODO") }
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension BitVector64: Sendable {}

extension Array {
    package func mapBool(_ predicate: (Element) -> Bool) -> BitVector64 {
        fatalError("TODO")
    }
}

package struct BitVector: MutableCollection, RandomAccessCollection {
    package init(count: Int) {
        fatalError("TODO")
    }
    
    @inlinable
    package var startIndex: Int {
        fatalError("TODO")
    }
    
    package var endIndex: Int {
        fatalError("TODO")
    }
    
    @inlinable
    package subscript(index: Int) -> Bool {
        get { fatalError("TODO") }
        set { fatalError("TODO") }
    }
}
