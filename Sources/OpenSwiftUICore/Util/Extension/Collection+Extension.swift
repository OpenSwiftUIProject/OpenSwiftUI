//
//  Collection+Extension.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - Collection + Index Extension [6.0.87]

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
