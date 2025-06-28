//
//  Collection+Extension.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

extension Collection {
    package func index(atOffset n: Int) -> Index {
        index(startIndex, offsetBy: n)
    }
    
    package func index(atOffset n: Int, limitedBy limit: Index) -> Index? {
        index(startIndex, offsetBy: n, limitedBy: limit)
    }
    
    package func offset(of i: Index) -> Int {
        distance(from: startIndex, to: i)
    }
    
    package subscript(safe index: Index) -> Element? {
        guard index >= startIndex, index < endIndex else {
            return nil
        }
        return self[index]
    }
    
    package func withContiguousStorage<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R) rethrows -> R {
        try withContiguousStorageIfAvailable(body) ?? ContiguousArray(self).withUnsafeBufferPointer(body)
    }
}
