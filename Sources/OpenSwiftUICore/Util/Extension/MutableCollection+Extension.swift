//
//  MutableCollection+Extension.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Author: Implmeneted by Copilot

public import Foundation

@available(OpenSwiftUI_v1_0, *)
extension RangeReplaceableCollection where Self: MutableCollection {
    public mutating func remove(atOffsets offsets: IndexSet) {
        guard !offsets.isEmpty else { return }
        let partitionIndex = halfStablePartitionByOffset { offset in
            offsets.contains(offset)
        }
        removeSubrange(partitionIndex...)
    }
}

extension RangeReplaceableCollection {
    package mutating func _remove(atOffsets offsets: IndexSet) {
        guard !offsets.isEmpty else { return }
        
        let ranges = offsets.rangeView.reversed()
        
        for range in ranges {
            let startOffset = range.lowerBound
            let endOffset = range.upperBound
            
            guard startOffset >= 0 && startOffset < count else { continue }
            guard endOffset > startOffset && endOffset <= count else { continue }
            
            let startIndex = index(self.startIndex, offsetBy: startOffset)
            let endIndex = index(self.startIndex, offsetBy: endOffset)
            
            removeSubrange(startIndex..<endIndex)
        }
    }
}

extension Collection {
    package func firstIndexByOffset(where predicate: (Int) throws -> Bool) rethrows -> (Index, Int)? {
        var offset = 0
        var currentIndex = startIndex
        
        while currentIndex != endIndex {
            if try predicate(offset) {
                return (currentIndex, offset)
            }
            formIndex(after: &currentIndex)
            offset += 1
        }
        
        return nil
    }
}

extension MutableCollection {
    package mutating func halfStablePartitionByOffset(isSuffixElementAtOffset: (Int) throws -> Bool) rethrows -> Index {
        guard !isEmpty else { return startIndex }
        
        var writeIndex = startIndex
        var offset = 0
        
        for readIndex in indices {
            let shouldKeep = try !isSuffixElementAtOffset(offset)
            if shouldKeep {
                if writeIndex != readIndex {
                    swapAt(writeIndex, readIndex)
                }
                formIndex(after: &writeIndex)
            }
            offset += 1
        }
        
        return writeIndex
    }
}

@available(OpenSwiftUI_v1_0, *)
extension MutableCollection where Self: RangeReplaceableCollection {
    public mutating func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        guard !source.isEmpty else { return }
        guard destination >= 0 && destination <= count else { return }
        
        let sourceIndices = source.compactMap { offset -> Index? in
            guard offset >= 0 && offset < count else { return nil }
            return index(startIndex, offsetBy: offset)
        }
        
        guard !sourceIndices.isEmpty else { return }
        
        let sourceElements = sourceIndices.map { self[$0] }
        
        var adjustedDestination = destination
        for offset in source.sorted() {
            if offset < destination {
                adjustedDestination -= 1
            }
        }
        
        for offset in source.sorted(by: >) {
            guard offset >= 0 && offset < count else { continue }
            let indexToRemove = index(startIndex, offsetBy: offset)
            remove(at: indexToRemove)
        }
        
        if adjustedDestination >= 0 && adjustedDestination <= count {
            let insertionIndex = index(startIndex, offsetBy: adjustedDestination)
            insert(contentsOf: sourceElements, at: insertionIndex)
        }
    }

    @discardableResult
    package mutating func stablePartitionByOffset(
        in range: Range<Index>,
        startOffset: Int,
        isSuffixElementAtOffset: (Int) throws -> Bool
    ) rethrows -> Index {
        guard range.lowerBound != range.upperBound else { return range.lowerBound }
        
        var writeIndex = range.lowerBound
        var currentIndex = range.lowerBound
        var offset = startOffset
        
        while currentIndex != range.upperBound {
            let shouldKeep = try !isSuffixElementAtOffset(offset)
            if shouldKeep {
                if writeIndex != currentIndex {
                    swapAt(writeIndex, currentIndex)
                }
                formIndex(after: &writeIndex)
            }
            formIndex(after: &currentIndex)
            offset += 1
        }
        
        return writeIndex
    }

    package mutating func stablePartitionByOffset(
        in range: Range<Index>,
        startOffset: Int,
        count n: Int,
        isSuffixElementAtOffset: (Int) throws -> Bool
    ) rethrows -> Index {
        guard n > 0 else { return range.lowerBound }
        guard range.lowerBound != range.upperBound else { return range.lowerBound }
        
        let endIndex = index(range.lowerBound, offsetBy: Swift.min(n, distance(from: range.lowerBound, to: range.upperBound)))
        let subRange = range.lowerBound..<endIndex
        
        return try stablePartitionByOffset(
            in: subRange,
            startOffset: startOffset,
            isSuffixElementAtOffset: isSuffixElementAtOffset
        )
    }

    @discardableResult
    package mutating func rotate(
        in range: Range<Index>,
        shiftingToStart middle: Index
    ) -> Index {
        guard range.lowerBound != range.upperBound else { return range.lowerBound }
        guard middle != range.lowerBound && middle != range.upperBound else { return middle }
        
        let firstHalf = range.lowerBound..<middle
        let secondHalf = middle..<range.upperBound
        
        guard !firstHalf.isEmpty && !secondHalf.isEmpty else { return middle }
        
        var result = middle
        var currentRange = range
        var currentMiddle = middle
        
        while currentRange.lowerBound != currentRange.upperBound && currentMiddle != currentRange.lowerBound {
            let (newMiddle, newEnd) = _swapNonemptySubrangePrefixes(
                currentRange.lowerBound..<currentMiddle,
                currentMiddle..<currentRange.upperBound
            )
            
            if distance(from: currentRange.lowerBound, to: newMiddle) < distance(from: newMiddle, to: newEnd) {
                currentRange = newMiddle..<currentRange.upperBound
                currentMiddle = newEnd
            } else {
                currentRange = currentRange.lowerBound..<newMiddle
                result = currentRange.lowerBound
            }
        }
        
        return result
    }

    package mutating func _swapNonemptySubrangePrefixes(
        _ lhs: Range<Index>,
        _ rhs: Range<Index>
    ) -> (Index, Index) {
        let lhsCount = distance(from: lhs.lowerBound, to: lhs.upperBound)
        let rhsCount = distance(from: rhs.lowerBound, to: rhs.upperBound)
        let swapCount = Swift.min(lhsCount, rhsCount)

        var lhsIndex = lhs.lowerBound
        var rhsIndex = rhs.lowerBound
        
        for _ in 0..<swapCount {
            swapAt(lhsIndex, rhsIndex)
            formIndex(after: &lhsIndex)
            formIndex(after: &rhsIndex)
        }
        
        return (lhsIndex, rhsIndex)
    }
}
