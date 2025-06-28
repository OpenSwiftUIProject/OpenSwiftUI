//
//  CollectionOfTwo.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - CollectionOfTwo [6.5.4]

package struct CollectionOfTwo<T>: RandomAccessCollection, MutableCollection {
    package var startIndex: Int { 0 }

    package var endIndex: Int { 2 }
    
    package var elements: (T, T)
    
    package init(_ first: T, _ second: T) {
        self.elements = (first, second)
    }
    
    package subscript(i: Int) -> T {
        get {
            switch i {
            case 0: return elements.0
            case 1: return elements.1
            default: preconditionFailure("index out of range")
            }
        }
        set {
            switch i {
            case 0: elements.0 = newValue
            case 1: elements.1 = newValue
            default: preconditionFailure("index out of range")
            }
        }
    }
}
