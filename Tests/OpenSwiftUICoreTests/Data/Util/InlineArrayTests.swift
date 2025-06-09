//
//  InlineArrayTests.swift
//  OpenSwiftUICoreTests
//
//  Status: Created by GitHub Copilot

@testable import OpenSwiftUICore
import Testing

struct ArrayWith2InlineTests {

    // MARK: - Initialization

    @Test
    func emptyInitialization() {
        let array: ArrayWith2Inline<Int> = ArrayWith2Inline<Int>()
        #expect(array.count == 0)
        #expect(array.isEmpty)
        if case .empty = array.storage {
            // Expected
        } else {
            Issue.record("Expected empty storage")
        }
    }

    @Test
    func singleElementInitialization() {
        let array: ArrayWith2Inline<Int> = ArrayWith2Inline(42)
        #expect(array.count == 1)
        #expect(!array.isEmpty)
        #expect(array[0] == 42)
        if case .one(let element) = array.storage {
            #expect(element == 42)
        } else {
            Issue.record("Expected one storage")
        }
    }

    @Test
    func twoElementInitialization() {
        let array: ArrayWith2Inline<Int> = ArrayWith2Inline(10, 20)
        #expect(array.count == 2)
        #expect(array[0] == 10)
        #expect(array[1] == 20)
        if case .two(let first, let second) = array.storage {
            #expect(first == 10)
            #expect(second == 20)
        } else {
            Issue.record("Expected two storage")
        }
    }

    @Test
    func sequenceInitializationEmpty() {
        let array: ArrayWith2Inline<Int> = ArrayWith2Inline([Int]())
        #expect(array.count == 0)
        if case .empty = array.storage {
            // Expected
        } else {
            Issue.record("Expected empty storage")
        }
    }

    @Test
    func sequenceInitializationOne() {
        let array: ArrayWith2Inline<Int> = ArrayWith2Inline([42])
        #expect(array.count == 1)
        #expect(array[0] == 42)
        if case .one(let element) = array.storage {
            #expect(element == 42)
        } else {
            Issue.record("Expected one storage")
        }
    }

    @Test
    func sequenceInitializationTwo() {
        let array: ArrayWith2Inline<Int> = ArrayWith2Inline([10, 20])
        #expect(array.count == 2)
        #expect(array[0] == 10)
        #expect(array[1] == 20)
        if case .two(let first, let second) = array.storage {
            #expect(first == 10)
            #expect(second == 20)
        } else {
            Issue.record("Expected two storage")
        }
    }

    @Test
    func sequenceInitializationMany() {
        let array: ArrayWith2Inline<Int> = ArrayWith2Inline([1, 2, 3, 4, 5])
        #expect(array.count == 5)
        for i in 0..<5 {
            #expect(array[i] == i + 1)
        }
        if case .many(let contiguousArray) = array.storage {
            #expect(contiguousArray.count == 5)
        } else {
            Issue.record("Expected many storage")
        }
    }

    @Test
    func arrayLiteralInitialization() {
        let array: ArrayWith2Inline<Int> = [1, 2, 3]
        #expect(array.count == 3)
        #expect(array[0] == 1)
        #expect(array[1] == 2)
        #expect(array[2] == 3)
    }

    // MARK: - Collection Operations

    @Test
    func indexAccess() {
        let array: ArrayWith2Inline<Int> = ArrayWith2Inline([10, 20, 30])
        #expect(array.startIndex == 0)
        #expect(array.endIndex == 3)
        #expect(array[0] == 10)
        #expect(array[1] == 20)
        #expect(array[2] == 30)
    }

    @Test
    func mutableIndexAccess() {
        var array: ArrayWith2Inline<Int> = ArrayWith2Inline([10, 20])
        array[0] = 100
        array[1] = 200
        #expect(array[0] == 100)
        #expect(array[1] == 200)
    }

    @Test
    func iteration() {
        let array: ArrayWith2Inline<Int> = ArrayWith2Inline([1, 2, 3])
        var result: [Int] = []
        for element in array {
            result.append(element)
        }
        #expect(result == [1, 2, 3])
    }

    @Test
    func copyToContiguousArray() {
        let array: ArrayWith2Inline<Int> = ArrayWith2Inline([1, 2])
        let contiguous = array._copyToContiguousArray()
        #expect(Array(contiguous) == [1, 2])
    }

    // MARK: - Array-like Operations

    @Test
    func appendToEmpty() {
        var array = ArrayWith2Inline<Int>()
        array.append(42)
        #expect(array.count == 1)
        #expect(array[0] == 42)
        if case .one = array.storage {
            // Expected
        } else {
            Issue.record("Expected one storage after append")
        }
    }

    @Test
    func appendToOne() {
        var array: ArrayWith2Inline<Int> = ArrayWith2Inline(10)
        array.append(20)
        #expect(array.count == 2)
        #expect(array[0] == 10)
        #expect(array[1] == 20)
        if case .two = array.storage {
            // Expected
        } else {
            Issue.record("Expected two storage after append")
        }
    }

    @Test
    func appendToTwo() {
        var array: ArrayWith2Inline<Int> = ArrayWith2Inline(10, 20)
        array.append(30)
        #expect(array.count == 3)
        #expect(array[0] == 10)
        #expect(array[1] == 20)
        #expect(array[2] == 30)
        if case .many = array.storage {
            // Expected
        } else {
            Issue.record("Expected many storage after append")
        }
    }

    @Test
    func appendToMany() {
        var array: ArrayWith2Inline<Int> = ArrayWith2Inline([1, 2, 3])
        array.append(4)
        #expect(array.count == 4)
        #expect(array[3] == 4)
    }

    @Test
    func removeAll() {
        var array: ArrayWith2Inline<Int> = ArrayWith2Inline([1, 2, 3])
        array.removeAll()
        #expect(array.count == 0)
        #expect(array.isEmpty)
        if case .empty = array.storage {
            // Expected
        } else {
            Issue.record("Expected empty storage after removeAll")
        }
    }

    @Test
    func removeAllKeepingCapacity() {
        var array: ArrayWith2Inline<Int> = ArrayWith2Inline([1, 2, 3, 4])
        array.removeAll(keepingCapacity: true)
        #expect(array.count == 0)
        if case .many(let contiguous) = array.storage {
            #expect(contiguous.count == 0)
        } else {
            Issue.record("Expected many storage with capacity preserved")
        }
    }

    // MARK: - RangeReplaceableCollection

    @Test
    func replaceSubrangeInMany() {
        var array: ArrayWith2Inline<Int> = ArrayWith2Inline([1, 2, 3, 4, 5])
        array.replaceSubrange(1..<3, with: [10, 20])
        #expect(Array(array) == [1, 10, 20, 4, 5])
    }

    @Test
    func replaceSubrangeInSmallArray() {
        var array: ArrayWith2Inline<Int> = ArrayWith2Inline([1, 2])
        array.replaceSubrange(1..<2, with: [10, 20])
        #expect(Array(array) == [1, 10, 20])
    }

    @Test
    func replaceSubrangeAtEnd() {
        var array: ArrayWith2Inline<Int> = ArrayWith2Inline([1, 2, 3])
        array.replaceSubrange(2..<3, with: [10])
        #expect(Array(array) == [1, 2, 10])
    }

    @Test
    func replaceSubrangeAtBeginning() {
        var array: ArrayWith2Inline<Int> = ArrayWith2Inline([1, 2, 3])
        array.replaceSubrange(0..<1, with: [10, 20])
        #expect(Array(array) == [10, 20, 2, 3])
    }

    @Test
    func replaceSubrangeEmpty() {
        var array: ArrayWith2Inline<Int> = ArrayWith2Inline([1, 2, 3])
        array.replaceSubrange(1..<1, with: [10])
        #expect(Array(array) == [1, 10, 2, 3])
    }

    @Test
    func replaceSubrangeSameSize() {
        var array: ArrayWith2Inline<Int> = ArrayWith2Inline([1, 2])
        array.replaceSubrange(0..<1, with: [10])
        #expect(Array(array) == [10, 2])
    }

    @Test
    func replaceSubrangeEntireArray() {
        var array: ArrayWith2Inline<Int> = ArrayWith2Inline([1, 2])
        array.replaceSubrange(0..<2, with: [10, 20, 30])
        #expect(Array(array) == [10, 20, 30])
    }

    // MARK: - Equatable

    @Test
    func equalityEmpty() {
        let array1: ArrayWith2Inline<Int> = ArrayWith2Inline<Int>()
        let array2: ArrayWith2Inline<Int> = ArrayWith2Inline<Int>()
        #expect(array1 == array2)
    }

    @Test
    func equalityOne() {
        let array1: ArrayWith2Inline<Int> = ArrayWith2Inline(42)
        let array2: ArrayWith2Inline<Int> = ArrayWith2Inline(42)
        let array3: ArrayWith2Inline<Int> = ArrayWith2Inline(43)
        #expect(array1 == array2)
        #expect(array1 != array3)
    }

    @Test
    func equalityTwo() {
        let array1: ArrayWith2Inline<Int> = ArrayWith2Inline(10, 20)
        let array2: ArrayWith2Inline<Int> = ArrayWith2Inline(10, 20)
        let array3: ArrayWith2Inline<Int> = ArrayWith2Inline(10, 21)
        #expect(array1 == array2)
        #expect(array1 != array3)
    }

    @Test
    func equalityMany() {
        let array1: ArrayWith2Inline<Int> = ArrayWith2Inline([1, 2, 3, 4])
        let array2: ArrayWith2Inline<Int> = ArrayWith2Inline([1, 2, 3, 4])
        let array3: ArrayWith2Inline<Int> = ArrayWith2Inline([1, 2, 3, 5])
        #expect(array1 == array2)
        #expect(array1 != array3)
    }

    @Test
    func equalityDifferentSizes() {
        let array1: ArrayWith2Inline<Int> = ArrayWith2Inline([1])
        let array2: ArrayWith2Inline<Int> = ArrayWith2Inline([1, 2])
        #expect(array1 != array2)
    }

    // MARK: - UnsafeMutableBufferPointer

    @Test
    func withUnsafeMutableBufferPointerEmpty() {
        var array = ArrayWith2Inline<Int>()
        let result = array.withUnsafeMutableBufferPointer { buffer in
            #expect(buffer.count == 0)
            return 42
        }
        #expect(result == 42)
    }

    @Test
    func withUnsafeMutableBufferPointerOne() {
        var array: ArrayWith2Inline<Int> = ArrayWith2Inline(10)
        array.withUnsafeMutableBufferPointer { buffer in
            #expect(buffer.count == 1)
            #expect(buffer[0] == 10)
            buffer[0] = 20
        }
        #expect(array[0] == 20)
    }

    @Test
    func withUnsafeMutableBufferPointerTwo() {
        var array: ArrayWith2Inline<Int> = ArrayWith2Inline(10, 20)
        array.withUnsafeMutableBufferPointer { buffer in
            #expect(buffer.count == 2)
            #expect(buffer[0] == 10)
            #expect(buffer[1] == 20)
            buffer[0] = 100
            buffer[1] = 200
        }
        #expect(array[0] == 100)
        #expect(array[1] == 200)
    }

    @Test
    func withUnsafeMutableBufferPointerMany() {
        var array: ArrayWith2Inline<Int> = ArrayWith2Inline([1, 2, 3])
        array.withUnsafeMutableBufferPointer { buffer in
            #expect(buffer.count == 3)
            for i in 0..<buffer.count {
                buffer[i] *= 10
            }
        }
        #expect(Array(array) == [10, 20, 30])
    }

    // MARK: - Edge Cases and Error Conditions

    #if compiler(>=6.2)
    @Test
    func indexOutOfRangeEmpty() {
        let array: ArrayWith2Inline<Int> = ArrayWith2Inline<Int>()
        #expect(throws: Never.self) {
            _ = array[0]
        }
    }

    @Test
    func indexOutOfRangeOne() {
        let array: ArrayWith2Inline<Int> = ArrayWith2Inline(42)
        #expect(throws: Never.self) {
            _ = array[1]
        }
    }

    @Test
    func indexOutOfRangeTwo() {
        let array: ArrayWith2Inline<Int> = ArrayWith2Inline(10, 20)
        #expect(throws: Never.self) {
            _ = array[2]
        }
    }
    #endif

    // MARK: - Performance and Storage Optimization

    @Test
    func storageOptimization() {
        var array = ArrayWith2Inline<Int>()
        
        #expect(array.count == 0)
        if case .empty = array.storage { } else {
            Issue.record("Expected empty storage")
        }
        
        array.append(1)
        if case .one = array.storage { } else {
            Issue.record("Expected one storage")
        }
        
        array.append(2)
        if case .two = array.storage { } else {
            Issue.record("Expected two storage")
        }
        
        array.append(3)
        if case .many = array.storage { } else {
            Issue.record("Expected many storage")
        }
    }

    @Test
    func largeSequenceInitialization() {
        let largeArray = Array(1...100)
        let inlineArray: ArrayWith2Inline<Int> = ArrayWith2Inline(largeArray)
        #expect(inlineArray.count == 100)
        #expect(Array(inlineArray) == largeArray)
        if case .many = inlineArray.storage { } else {
            Issue.record("Expected many storage for large sequence")
        }
    }
}
