//
//  ConcatenatedCollectionTests.swift
//  OpenSwiftUICoreTests
//
//  Status: Created by GitHub Copilot

import Testing
@testable import OpenSwiftUICore

struct ConcatenatedCollectionTests {

    // MARK: - Basic Concatenation

    @Test
    func basicConcatenation() {
        let first = [1, 2, 3]
        let second = [4, 5, 6]
        let concatenated = concatenate(first, second)

        #expect(Array(concatenated) == [1, 2, 3, 4, 5, 6])
        #expect(concatenated.count == 6)
    }

    @Test
    func emptyConcatenation() {
        let empty1: [Int] = []
        let empty2: [Int] = []
        let concatenated = concatenate(empty1, empty2)

        #expect(Array(concatenated) == [])
        #expect(concatenated.count == 0)
        #expect(concatenated.isEmpty)
    }

    @Test
    func firstEmptySecondFull() {
        let empty: [Int] = []
        let full = [1, 2, 3]
        let concatenated = concatenate(empty, full)

        #expect(Array(concatenated) == [1, 2, 3])
        #expect(concatenated.count == 3)
    }

    @Test
    func firstFullSecondEmpty() {
        let full = [1, 2, 3]
        let empty: [Int] = []
        let concatenated = concatenate(full, empty)

        #expect(Array(concatenated) == [1, 2, 3])
        #expect(concatenated.count == 3)
    }

    // MARK: - Index Operations

    @Test
    func startIndex() {
        let first = [1, 2]
        let second = [3, 4]
        let concatenated = concatenate(first, second)

        let startIdx = concatenated.startIndex
        #expect(concatenated[startIdx] == 1)
    }

    @Test
    func endIndex() {
        let first = [1, 2]
        let second = [3, 4]
        let concatenated = concatenate(first, second)

        let beforeEnd = concatenated.index(before: concatenated.endIndex)
        #expect(concatenated[beforeEnd] == 4)
    }

    @Test
    func indexAdvancement() {
        let first = [1, 2]
        let second = [3, 4, 5]
        let concatenated = concatenate(first, second)

        var idx = concatenated.startIndex
        #expect(concatenated[idx] == 1)

        idx = concatenated.index(after: idx)
        #expect(concatenated[idx] == 2)

        idx = concatenated.index(after: idx)
        #expect(concatenated[idx] == 3)

        idx = concatenated.index(after: idx)
        #expect(concatenated[idx] == 4)

        idx = concatenated.index(after: idx)
        #expect(concatenated[idx] == 5)
    }

    @Test
    func indexOffsetBy() {
        let first = [1, 2, 3]
        let second = [4, 5, 6]
        let concatenated = concatenate(first, second)

        let start = concatenated.startIndex
        let offset3 = concatenated.index(start, offsetBy: 3)
        #expect(concatenated[offset3] == 4)

        let offset5 = concatenated.index(start, offsetBy: 5)
        #expect(concatenated[offset5] == 6)
    }

    @Test
    func indexOffsetByZero() {
        let first = [1, 2]
        let second = [3, 4]
        let concatenated = concatenate(first, second)

        let start = concatenated.startIndex
        let sameIndex = concatenated.index(start, offsetBy: 0)
        #expect(start == sameIndex)
    }

    @Test
    func indexOffsetByNegative() {
        let first = [1, 2, 3]
        let second = [4, 5, 6]
        let concatenated = concatenate(first, second)

        let end = concatenated.endIndex
        let beforeEnd = concatenated.index(end, offsetBy: -1)
        #expect(concatenated[beforeEnd] == 6)

        let thirdFromEnd = concatenated.index(end, offsetBy: -3)
        #expect(concatenated[thirdFromEnd] == 4)
    }

    // MARK: - Collection Properties

    @Test
    func isEmpty() {
        let empty1: [Int] = []
        let empty2: [Int] = []
        let emptyConcat = concatenate(empty1, empty2)
        #expect(emptyConcat.isEmpty)

        let nonEmpty = concatenate([1], [2])
        #expect(!nonEmpty.isEmpty)
    }

    @Test
    func count() {
        let first = Array(1...5)
        let second = Array(6...10)
        let concatenated = concatenate(first, second)

        #expect(concatenated.count == 10)
        #expect(concatenated.count == first.count + second.count)
    }

    @Test
    func firstElement() {
        let first = [10, 20]
        let second = [30, 40]
        let concatenated = concatenate(first, second)

        #expect(concatenated.first == 10)
    }

    @Test
    func firstElementEmptyFirst() {
        let empty: [Int] = []
        let second = [30, 40]
        let concatenated = concatenate(empty, second)

        #expect(concatenated.first == 30)
    }

    @Test
    func firstElementAllEmpty() {
        let empty1: [Int] = []
        let empty2: [Int] = []
        let concatenated = concatenate(empty1, empty2)

        #expect(concatenated.first == nil)
    }

    // MARK: - Bidirectional Collection

    @Test
    func lastElement() {
        let first = [10, 20]
        let second = [30, 40]
        let concatenated = concatenate(first, second)

        #expect(concatenated.last == 40)
    }

    @Test
    func lastElementEmptySecond() {
        let first = [10, 20]
        let empty: [Int] = []
        let concatenated = concatenate(first, empty)

        #expect(concatenated.last == 20)
    }

    @Test
    func indexBefore() {
        let first = [1, 2, 3]
        let second = [4, 5, 6]
        let concatenated = concatenate(first, second)

        let end = concatenated.endIndex
        let beforeEnd = concatenated.index(before: end)
        #expect(concatenated[beforeEnd] == 6)

        let twoBeforeEnd = concatenated.index(before: beforeEnd)
        #expect(concatenated[twoBeforeEnd] == 5)
    }

    // MARK: - Random Access Collection

    @Test
    func distance() {
        let first = [1, 2, 3]
        let second = [4, 5]
        let concatenated = concatenate(first, second)

        let start = concatenated.startIndex
        let end = concatenated.endIndex
        #expect(concatenated.distance(from: start, to: end) == 5)

        let midIndex = concatenated.index(start, offsetBy: 2)
        #expect(concatenated.distance(from: start, to: midIndex) == 2)
        #expect(concatenated.distance(from: midIndex, to: end) == 3)
    }

    // MARK: - Partition Point

    @Test
    func partitionPointBasic() {
        let first = [1, 3, 5]
        let second = [7, 9, 11]
        let concatenated = concatenate(first, second)

        let pivot = concatenated.partitionPoint { $0 >= 7 }
        #expect(concatenated[pivot] == 7)
    }

    @Test
    func partitionPointNotFound() {
        let first = [1, 3, 5]
        let second = [7, 9, 11]
        let concatenated = concatenate(first, second)

        let pivot = concatenated.partitionPoint { $0 >= 15 }
        #expect(pivot == concatenated.endIndex)
    }

    @Test
    func partitionPointAllMatch() {
        let first = [5, 7, 9]
        let second = [11, 13, 15]
        let concatenated = concatenate(first, second)

        let pivot = concatenated.partitionPoint { $0 >= 3 }
        #expect(pivot == concatenated.startIndex)
    }

    @Test
    func partitionPointEmpty() {
        let empty1: [Int] = []
        let empty2: [Int] = []
        let concatenated = concatenate(empty1, empty2)

        let pivot = concatenated.partitionPoint { $0 >= 5 }
        #expect(pivot == concatenated.endIndex)
    }

    @Test
    func partitionPointSorted() {
        let first = [1, 2, 3]
        let second = [4, 5, 6]
        let concatenated = concatenate(first, second)

        let pivot = concatenated.partitionPoint { $0 >= 4 }
        #expect(concatenated[pivot] == 4)

        let pivot2 = concatenated.partitionPoint { $0 >= 2 }
        #expect(concatenated[pivot2] == 2)

        let pivot3 = concatenated.partitionPoint { $0 >= 6 }
        #expect(concatenated[pivot3] == 6)
    }

    // MARK: - Index Representation

    @Test
    func indexRepresentationFirst() {
        let first = [1, 2, 3]
        let second = [4, 5, 6]
        let concatenated = concatenate(first, second)

        let startIdx = concatenated.startIndex
        if case .first(let idx) = startIdx._position {
            #expect(first[idx] == 1)
        } else {
            #expect(Bool(false), "Expected first representation")
        }
    }

    @Test
    func indexRepresentationSecond() {
        let first = [1, 2]
        let second = [3, 4, 5]
        let concatenated = concatenate(first, second)

        let thirdIndex = concatenated.index(concatenated.startIndex, offsetBy: 2)
        if case .second(let idx) = thirdIndex._position {
            #expect(second[idx] == 3)
        } else {
            #expect(Bool(false), "Expected second representation")
        }
    }

    // MARK: - String Concatenation

    @Test
    func stringConcatenation() {
        let first = "Hello"
        let second = "World"
        let concatenated = concatenate(first, second)

        #expect(String(concatenated) == "HelloWorld")
        #expect(concatenated.count == 10)
    }

    @Test
    func characterAccess() {
        let first = "ABC"
        let second = "DEF"
        let concatenated = concatenate(first, second)

        var idx = concatenated.startIndex
        #expect(concatenated[idx] == "A")

        idx = concatenated.index(idx, offsetBy: 3)
        #expect(concatenated[idx] == "D")

        idx = concatenated.index(idx, offsetBy: 2)
        #expect(concatenated[idx] == "F")
    }

    // MARK: - Edge Cases

    @Test
    func singleElementCollections() {
        let first = [42]
        let second = [100]
        let concatenated = concatenate(first, second)

        #expect(Array(concatenated) == [42, 100])
        #expect(concatenated.count == 2)
        #expect(concatenated.first == 42)
        #expect(concatenated.last == 100)
    }

    @Test
    func largeCollections() {
        let first = Array(1...1000)
        let second = Array(1001...2000)
        let concatenated = concatenate(first, second)

        #expect(concatenated.count == 2000)
        #expect(concatenated.first == 1)
        #expect(concatenated.last == 2000)

        let midPoint = concatenated.index(concatenated.startIndex, offsetBy: 999)
        #expect(concatenated[midPoint] == 1000)

        let afterMidPoint = concatenated.index(after: midPoint)
        #expect(concatenated[afterMidPoint] == 1001)
    }

    @Test
    func indexEquality() {
        let first = [1, 2, 3]
        let second = [4, 5, 6]
        let concatenated = concatenate(first, second)

        let idx1 = concatenated.startIndex
        let idx2 = concatenated.index(concatenated.startIndex, offsetBy: 0)
        #expect(idx1 == idx2)

        let idx3 = concatenated.index(concatenated.startIndex, offsetBy: 1)
        #expect(idx1 != idx3)
    }

    @Test
    func indexComparison() {
        let first = [1, 2, 3]
        let second = [4, 5, 6]
        let concatenated = concatenate(first, second)

        let start = concatenated.startIndex
        let middle = concatenated.index(start, offsetBy: 3)
        let end = concatenated.endIndex

        #expect(start < middle)
        #expect(middle < end)
        #expect(start < end)
    }
}
