//
//  BitVector.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete
//  ID: 8433FC349A42D7F59B64CD7FA08D81A9 (SwiftUICore)

import Foundation

package struct BitVector: MutableCollection, RandomAccessCollection {
    private enum Kind {
        case inline
        case array
    }
    
    private var kind: Kind
    var vector: BitVector64
    var array: [BitVector64]
    package internal(set) var endIndex: Int
    
    package init(count: Int) {
        if count <= 64 {
            kind = .inline
            vector = BitVector64()
            array = []
            endIndex = count
        } else {
            let length = (count + 63) / 64
            kind = .array
            vector = BitVector64()
            array = .init(repeating: BitVector64(), count: length)
            endIndex = count
        }
    }
    
    @inlinable
    package var startIndex: Int { 0 }
    
    @inlinable
    package subscript(index: Int) -> Bool {
        get { 
            if kind == .inline {
                return vector[index]
            } else {
                let (q, r) = index.quotientAndRemainder(dividingBy: 64)
                return array[q][r]
            }
        }
        set {
            if kind == .inline {
                vector[index] = newValue
            } else {
                let (q, r) = index.quotientAndRemainder(dividingBy: 64)
                array[q][r] = newValue
            }
        }
    }
}
