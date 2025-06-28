//
//  CountingIndexCollection.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - CountingIndexCollection [6.5.4]

package struct CountingIndexCollection<Base> where Base: BidirectionalCollection {
    package let base: Base

    package init(_ base: Base) {
        self.base = base
    }
}

extension CountingIndexCollection: BidirectionalCollection {
    package typealias Index = CountingIndex<Base.Index>
    package typealias Element = Base.Element

    package var startIndex: CountingIndexCollection<Base>.Index {
        CountingIndex(base: base.startIndex, offset: base.isEmpty ? nil : 0)
    }

    package var endIndex: CountingIndexCollection<Base>.Index {
        CountingIndex(base: base.endIndex, offset: nil)
    }

    package func index(before i: CountingIndexCollection<Base>.Index) -> CountingIndexCollection<Base>.Index {
        let newBase = base.index(before: i.base)
        guard newBase != base.startIndex else {
            return CountingIndex(base: newBase, offset: nil)
        }
        let newOffset = i.offset! - 1
        return CountingIndex(base: newBase, offset: newOffset)
    }

    package func index(after i: CountingIndexCollection<Base>.Index) -> CountingIndexCollection<Base>.Index {
        let newBase = base.index(after: i.base)
        guard newBase != base.endIndex else {
            return CountingIndex(base: newBase, offset: nil)
        }
        let newOffset = i.offset! + 1
        return CountingIndex(base: newBase, offset: newOffset)
    }

    package func index(
        _ i: CountingIndex<Base.Index>,
        offsetBy distance: Int,
        limitedBy limit: CountingIndex<Base.Index>
    ) -> CountingIndex<Base.Index>? {
        guard let newBase = base.index(i.base, offsetBy: distance, limitedBy: limit.base) else {
            return nil
        }
        guard newBase != base.endIndex else {
            return CountingIndex(base: newBase, offset: nil)
        }
        let newOffset = i.offset! + distance
        return CountingIndex(base: newBase, offset: newOffset)
    }

    package subscript(position: CountingIndexCollection<Base>.Index) -> CountingIndexCollection<Base>.Element {
        base[position.base]
    }

    package typealias Indices = DefaultIndices<CountingIndexCollection<Base>>
    package typealias Iterator = IndexingIterator<CountingIndexCollection<Base>>
    package typealias SubSequence = Slice<CountingIndexCollection<Base>>
}

// MARK: - CountingIndex [6.5.4]

package struct CountingIndex<Base>: Equatable where Base: Comparable {
    package let base: Base
    package let offset: Int?

    package init(base: Base, offset: Int?) {
        self.base = base
        self.offset = offset
    }
}

extension CountingIndex: Comparable {
    package static func < (lhs: CountingIndex<Base>, rhs: CountingIndex<Base>) -> Bool {
        return lhs.base < rhs.base
    }
}

extension CountingIndex: CustomStringConvertible {
    package var description: String {
        "(base: \(base) | offset: \(offset?.description ?? "nil"))"
    }
}
