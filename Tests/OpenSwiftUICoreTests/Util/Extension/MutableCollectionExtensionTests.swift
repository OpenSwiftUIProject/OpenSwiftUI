//
//  MutableCollectionExtensionTests.swift
//  OpenSwiftUICoreTests
//
//  Author: Copilot

import Foundation
import OpenSwiftUICore
import Testing

// MARK: - MutableCollectionExtensionTests

struct MutableCollectionExtensionTests {
    // MARK: - remove(atOffsets:)

    @Test
    func removeAtOffsetsEmpty() {
        var array = [1, 2, 3, 4, 5]
        array.remove(atOffsets: IndexSet())
        #expect(array == [1, 2, 3, 4, 5])
    }

    @Test
    func removeAtOffsetsSingle() {
        var array = [1, 2, 3, 4, 5]
        array.remove(atOffsets: IndexSet([2]))
        #expect(array == [1, 2, 4, 5])
    }

    @Test
    func removeAtOffsetsMultiple() {
        var array = [1, 2, 3, 4, 5]
        array.remove(atOffsets: IndexSet([1, 3]))
        #expect(array == [1, 3, 5])
    }

    @Test
    func removeAtOffsetsConsecutive() {
        var array = [1, 2, 3, 4, 5]
        array.remove(atOffsets: IndexSet([1, 2, 3]))
        #expect(array == [1, 5])
    }

    @Test
    func removeAtOffsetsAll() {
        var array = [1, 2, 3]
        array.remove(atOffsets: IndexSet([0, 1, 2]))
        #expect(array.isEmpty)
    }

    // MARK: - _remove(atOffsets:)

    @Test
    func _removeAtOffsetsEmpty() {
        var array = [1, 2, 3, 4, 5]
        array._remove(atOffsets: IndexSet())
        #expect(array == [1, 2, 3, 4, 5])
    }

    @Test
    func _removeAtOffsetsRange() {
        var array = [1, 2, 3, 4, 5]
        array._remove(atOffsets: IndexSet(1 ... 3))
        #expect(array == [1, 5])
    }

    @Test
    func _removeAtOffsetsMultipleRanges() {
        var array = [1, 2, 3, 4, 5, 6, 7]
        array._remove(atOffsets: IndexSet([1, 3, 5]))
        #expect(array == [1, 3, 5, 7])
    }

    // MARK: - firstIndexByOffset(where:)

    @Test
    func firstIndexByOffsetFound() {
        let array = [10, 20, 30, 40]
        let result = array.firstIndexByOffset { $0 == 2 }

        #expect(result?.1 == 2)
        #expect(array[result!.0] == 30)
    }

    @Test
    func firstIndexByOffsetNotFound() {
        let array = [10, 20, 30]
        let result = array.firstIndexByOffset { $0 == 5 }

        #expect(result == nil)
    }

    @Test
    func firstIndexByOffsetEmpty() {
        let array: [Int] = []
        let result = array.firstIndexByOffset { _ in true }

        #expect(result == nil)
    }

    @Test
    func firstIndexByOffsetFirst() {
        let array = [10, 20, 30]
        let result = array.firstIndexByOffset { $0 == 0 }

        #expect(result?.1 == 0)
        #expect(array[result!.0] == 10)
    }

    // MARK: - halfStablePartitionByOffset

    @Test
    func halfStablePartitionByOffsetEmpty() {
        var array: [Int] = []
        let result = array.halfStablePartitionByOffset { _ in false }

        #expect(result == array.startIndex)
    }

    @Test
    func halfStablePartitionByOffsetKeepAll() {
        var array = [1, 2, 3, 4, 5]
        let result = array.halfStablePartitionByOffset { _ in false }

        #expect(array == [1, 2, 3, 4, 5])
        #expect(result == array.endIndex)
    }

    @Test
    func halfStablePartitionByOffsetRemoveAll() {
        var array = [1, 2, 3, 4, 5]
        let result = array.halfStablePartitionByOffset { _ in true }

        #expect(result == array.startIndex)
    }

    @Test
    func halfStablePartitionByOffsetMixed() {
        var array = [1, 2, 3, 4, 5]
        let result = array.halfStablePartitionByOffset { $0 % 2 == 0 }

        #expect(Array(array[..<result]) == [2, 4])
    }

    // MARK: - move(fromOffsets:toOffset:)

    @Test
    func moveEmpty() {
        var array = [1, 2, 3, 4, 5]
        array.move(fromOffsets: IndexSet(), toOffset: 2)
        #expect(array == [1, 2, 3, 4, 5])
    }

    @Test
    func moveSingleForward() {
        var array = [1, 2, 3, 4, 5]
        array.move(fromOffsets: IndexSet([1]), toOffset: 4)
        #expect(array == [1, 3, 4, 2, 5])
    }

    @Test
    func moveSingleBackward() {
        var array = [1, 2, 3, 4, 5]
        array.move(fromOffsets: IndexSet([3]), toOffset: 1)
        #expect(array == [1, 4, 2, 3, 5])
    }

    @Test
    func moveMultiple() {
        var array = [1, 2, 3, 4, 5]
        array.move(fromOffsets: IndexSet([1, 3]), toOffset: 0)
        #expect(array == [2, 4, 1, 3, 5])
    }

    @Test
    func moveToEnd() {
        var array = [1, 2, 3, 4, 5]
        array.move(fromOffsets: IndexSet([0, 2]), toOffset: 5)
        #expect(array == [2, 4, 5, 1, 3])
    }

    // MARK: - stablePartitionByOffset

    @Test
    func stablePartitionByOffsetFullRange() {
        var array = [1, 2, 3, 4, 5]
        let result = array.stablePartitionByOffset(
            in: array.startIndex ..< array.endIndex,
            startOffset: 0,
            isSuffixElementAtOffset: { $0 % 2 == 1 }
        )

        #expect(Array(array[..<result]) == [1, 3, 5])
        #expect(Array(array[result...]) == [4, 2])
    }

    @Test
    func stablePartitionByOffsetSubrange() {
        var array = [1, 2, 3, 4, 5]
        let startIndex = array.index(after: array.startIndex)
        let endIndex = array.index(before: array.endIndex)

        let _ = array.stablePartitionByOffset(
            in: startIndex ..< endIndex,
            startOffset: 1,
            isSuffixElementAtOffset: { $0 % 2 == 0 }
        )

        #expect(array[0] == 1)
        #expect(array[4] == 5)
    }

    @Test
    func stablePartitionByOffsetWithCount() {
        var array = [1, 2, 3, 4, 5, 6]
        let result = array.stablePartitionByOffset(
            in: array.startIndex ..< array.endIndex,
            startOffset: 0,
            count: 4,
            isSuffixElementAtOffset: { $0 % 2 == 1 }
        )

        #expect(Array(array[..<result]) == [1, 3])
        #expect(array[4] == 5)
        #expect(array[5] == 6)
    }

    // MARK: - rotate

    @Test
    func rotateEmpty() {
        var array: [Int] = []
        let result = array.rotate(
            in: array.startIndex ..< array.endIndex,
            shiftingToStart: array.startIndex
        )
        #expect(result == array.startIndex)
    }

    @Test
    func rotateSingle() {
        var array = [1]
        let result = array.rotate(
            in: array.startIndex ..< array.endIndex,
            shiftingToStart: array.startIndex
        )
        #expect(result == array.startIndex)
        #expect(array == [1])
    }

    // MARK: - _swapNonemptySubrangePrefixes

    @Test
    func swapNonemptySubrangePrefixesEqual() {
        var array = [1, 2, 3, 4, 5, 6]
        let lhs = array.startIndex ..< array.index(array.startIndex, offsetBy: 3)
        let rhs = array.index(array.startIndex, offsetBy: 3) ..< array.endIndex

        let (newLhs, newRhs) = array._swapNonemptySubrangePrefixes(lhs, rhs)

        #expect(array == [4, 5, 6, 1, 2, 3])
        #expect(newLhs == array.index(array.startIndex, offsetBy: 3))
        #expect(newRhs == array.endIndex)
    }

    @Test
    func swapNonemptySubrangePrefixesUnequal() {
        var array = [1, 2, 3, 4, 5]
        let lhs = array.startIndex ..< array.index(array.startIndex, offsetBy: 2)
        let rhs = array.index(array.startIndex, offsetBy: 2) ..< array.endIndex

        let (newLhs, newRhs) = array._swapNonemptySubrangePrefixes(lhs, rhs)

        #expect(array == [3, 4, 1, 2, 5])
        #expect(newLhs == array.index(array.startIndex, offsetBy: 2))
        #expect(newRhs == array.index(array.startIndex, offsetBy: 4))
    }

    @Test
    func swapNonemptySubrangePrefixesSingle() {
        var array = [1, 2]
        let lhs = array.startIndex ..< array.index(after: array.startIndex)
        let rhs = array.index(after: array.startIndex) ..< array.endIndex

        let (newLhs, newRhs) = array._swapNonemptySubrangePrefixes(lhs, rhs)

        #expect(array == [2, 1])
        #expect(newLhs == array.index(after: array.startIndex))
        #expect(newRhs == array.endIndex)
    }

    // MARK: - Edge Cases

    @Test
    func removeAtOffsetsInvalidIndices() {
        var array = [1, 2, 3]
        array.remove(atOffsets: IndexSet([5, 10]))
        #expect(array == [1, 2, 3])
    }

    @Test
    func moveInvalidDestination() {
        var array = [1, 2, 3]
        array.move(fromOffsets: IndexSet([0]), toOffset: 10)
        #expect(array == [1, 2, 3])
    }

    @Test
    func moveInvalidSource() {
        var array = [1, 2, 3]
        array.move(fromOffsets: IndexSet([5]), toOffset: 1)
        #expect(array == [1, 2, 3])
    }

    // MARK: - String Collection Tests

    @Test
    func stringCollectionRemove() {
        let string = "hello"
        var chars = Array(string)
        chars.remove(atOffsets: IndexSet([1, 3]))
        #expect(String(chars) == "hlo")
    }

    @Test
    func stringCollectionMove() {
        let string = "hello"
        var chars = Array(string)
        chars.move(fromOffsets: IndexSet([0]), toOffset: 4)
        #expect(String(chars) == "ellho")
    }

    // MARK: - Performance Edge Cases

    @Test
    func largeCollectionRemove() {
        var array = Array(0 ..< 1000)
        let offsets = IndexSet(stride(from: 0, to: 1000, by: 2))
        array.remove(atOffsets: offsets)
        #expect(array.count == 500)
        #expect(array.allSatisfy { $0 % 2 == 1 })
    }

    @Test
    func largeCollectionMove() {
        var array = Array(0 ..< 100)
        let sourceOffsets = IndexSet([0, 10, 20, 30])
        array.move(fromOffsets: sourceOffsets, toOffset: 50)
        #expect(array.count == 100)
    }
}
