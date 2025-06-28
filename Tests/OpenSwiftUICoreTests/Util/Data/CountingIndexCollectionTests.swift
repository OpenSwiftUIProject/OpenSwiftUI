//
//  ConcatenatedCollectionTests.swift
//  OpenSwiftUICoreTests
//
//  Status: Created by GitHub Copilot

import Testing
@testable import OpenSwiftUICore

// MARK: - CountingIndexCollection Tests

struct CountingIndexCollectionTests {
    
    @Test
    func emptyCollection() {
        let base: [Int] = []
        let counting = CountingIndexCollection(base)
        
        #expect(counting.isEmpty)
        #expect(counting.startIndex.offset == nil)
        #expect(counting.endIndex.offset == nil)
    }
    
    @Test
    func singleElementCollection() {
        let base = [42]
        let counting = CountingIndexCollection(base)
        
        #expect(counting.count == 1)
        #expect(counting.startIndex.offset == 0)
        #expect(counting.endIndex.offset == nil)
        #expect(counting[counting.startIndex] == 42)
    }
    
    @Test
    func multipleElementsCollection() {
        let base = [10, 20, 30, 40]
        let counting = CountingIndexCollection(base)
        
        #expect(counting.count == 4)
        #expect(counting.startIndex.offset == 0)
        #expect(counting.endIndex.offset == nil)
        
        var index = counting.startIndex
        #expect(counting[index] == 10)
        #expect(index.offset == 0)
        
        index = counting.index(after: index)
        #expect(counting[index] == 20)
        #expect(index.offset == 1)
        
        index = counting.index(after: index)
        #expect(counting[index] == 30)
        #expect(index.offset == 2)
        
        index = counting.index(after: index)
        #expect(counting[index] == 40)
        #expect(index.offset == 3)
        
        index = counting.index(after: index)
        #expect(index == counting.endIndex)
        #expect(index.offset == nil)
    }
    
    @Test
    func bidirectionalIteration() {
        let base = ["a", "b", "c"]
        let counting = CountingIndexCollection(base)
        
        var index = counting.index(atOffset: 2)

        index = counting.index(before: index)
        #expect(counting[index] == "b")
        #expect(index.offset == 1)

        index = counting.index(before: index)
        #expect(counting[index] == "a")
        #expect(index.offset == nil)
    }

    @Test
    func offsetByLimitedMethod() {
        let base = [1, 2, 3]
        let counting = CountingIndexCollection(base)
        
        let startIndex = counting.startIndex
        let limitIndex = counting.index(after: startIndex)
        
        let result = counting.index(startIndex, offsetBy: 3, limitedBy: limitIndex)
        #expect(result == nil)
        
        let validResult = counting.index(startIndex, offsetBy: 1, limitedBy: limitIndex)
        #expect(validResult?.offset == 1)
    }
    
    @Test
    func iterationWithForLoop() {
        let base = [10, 20, 30]
        let counting = CountingIndexCollection(base)
        
        var elements: [Int] = []
        var offsets: [Int?] = []
        
        for element in counting {
            elements.append(element)
        }
        
        for index in counting.indices {
            offsets.append(index.offset)
        }
        
        #expect(elements == [10, 20, 30])
        #expect(offsets == [0, 1, 2])
    }
    
    @Test
    func stringCollection() {
        let base = "hello"
        let counting = CountingIndexCollection(base)
        
        #expect(counting.count == 5)
        
        var characters: [Character] = []
        for char in counting {
            characters.append(char)
        }
        
        #expect(characters == ["h", "e", "l", "l", "o"])
    }
}

// MARK: - CountingIndex Tests

struct CountingIndexTests {
    
    @Test
    func equality() {
        let index1 = CountingIndex(base: 10, offset: 5)
        let index2 = CountingIndex(base: 10, offset: 5)
        let index3 = CountingIndex(base: 10, offset: 3)
        let index4 = CountingIndex(base: 8, offset: 5)
        
        #expect(index1 == index2)
        #expect(index1 != index3)
        #expect(index1 != index4)
    }
    
    @Test
    func comparison() {
        let index1 = CountingIndex(base: 5, offset: 10)
        let index2 = CountingIndex(base: 8, offset: 2)
        let index3 = CountingIndex(base: 5, offset: 15)
        
        #expect(index1 < index2)
        #expect(index1 == index3)
    }
    
    @Test
    func description() {
        let index1 = CountingIndex(base: 42, offset: 7)
        let index2 = CountingIndex(base: 42, offset: nil)
        
        #expect(index1.description == "(base: 42 | offset: 7)")
        #expect(index2.description == "(base: 42 | offset: nil)")
    }
    
    @Test
    func nilOffset() {
        let index = CountingIndex(base: "test", offset: nil)
        
        #expect(index.base == "test")
        #expect(index.offset == nil)
        #expect(index.description.contains("nil"))
    }
}
