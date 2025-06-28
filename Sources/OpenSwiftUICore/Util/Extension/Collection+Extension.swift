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

// MARK: - Collection + prefix and suffix [6.5.4]

extension Collection where Self.Element: Equatable {
    package func commonPrefix<Other>(with other: Other) -> (Self.SubSequence, Other.SubSequence) where Other: Collection, Element == Other.Element {
        var selfIndex = startIndex
        var otherIndex = other.startIndex

        while selfIndex != endIndex && otherIndex != other.endIndex && self[selfIndex] == other[otherIndex] {
            formIndex(after: &selfIndex)
            other.formIndex(after: &otherIndex)
        }

        return (self[startIndex..<selfIndex], other[other.startIndex..<otherIndex])
    }
}

extension BidirectionalCollection where Self.Element: Equatable {
    package func commonSuffix<Other>(with other: Other) -> (Self.SubSequence, Other.SubSequence) where Other: BidirectionalCollection, Self.Element == Other.Element {
        var selfIndex = endIndex
        var otherIndex = other.endIndex

        while selfIndex != startIndex && otherIndex != other.startIndex {
            formIndex(before: &selfIndex)
            other.formIndex(before: &otherIndex)

            if self[selfIndex] != other[otherIndex] {
                formIndex(after: &selfIndex)
                other.formIndex(after: &otherIndex)
                break
            }
        }

        return (self[selfIndex..<endIndex], other[otherIndex..<other.endIndex])
    }
}
