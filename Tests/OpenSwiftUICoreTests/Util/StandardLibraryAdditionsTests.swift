//
//  StandardLibraryAdditionsTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

// MARK: - UnsafeMutableBufferProjectionPointerTests

struct UnsafeMutableBufferProjectionPointerTests {
    private struct TestScene {
        var x: Int
        var y: Double
        var z: String
    }

    @Test
    func emptyInitialization() {
        let pointer: UnsafeMutableBufferProjectionPointer<TestScene, Int> = UnsafeMutableBufferProjectionPointer()

        #expect(pointer.startIndex == 0)
        #expect(pointer.endIndex == 0)
        #expect(pointer.isEmpty)
    }

    @Test
    func directPointerInitialization() {
        let buffer = UnsafeMutableBufferPointer<Int>.allocate(capacity: 3)
        defer { buffer.deallocate() }

        buffer[0] = 10
        buffer[1] = 20
        buffer[2] = 30

        let pointer = UnsafeMutableBufferProjectionPointer<Int, Int>(start: buffer.baseAddress!, count: 3)

        #expect(pointer.startIndex == 0)
        #expect(pointer.endIndex == 3)
        #expect(pointer.count == 3)
        #expect(pointer[0] == 10)
        #expect(pointer[1] == 20)
        #expect(pointer[2] == 30)
    }

    @Test
    func keyPathProjectionWithEmptyBuffer() {
        let buffer = UnsafeMutableBufferPointer<TestScene>.allocate(capacity: 0)
        defer { buffer.deallocate() }

        let pointer = UnsafeMutableBufferProjectionPointer(buffer, \TestScene.x)

        #expect(pointer.startIndex == 0)
        #expect(pointer.endIndex == 0)
        #expect(pointer.isEmpty)
    }

    @Test
    func bufferProjection() {
        var scenes = [
            TestScene(x: 1, y: 1.0, z: "1"),
            TestScene(x: 2, y: 2.0, z: "2"),
        ]
        scenes.withUnsafeMutableBufferPointer { base in
            let xProjection = UnsafeMutableBufferProjectionPointer(base, \TestScene.x)
            #expect(xProjection[0] == 1)
            #expect(xProjection[1] == 2)

            let yProjection = UnsafeMutableBufferProjectionPointer(base, \TestScene.y)
            #expect(yProjection[0] == 1.0)
            #expect(yProjection[1] == 2.0)

            let zProjection = UnsafeMutableBufferProjectionPointer(base, \TestScene.z)
            #expect(zProjection[0] == "1")
            #expect(zProjection[1] == "2")

            xProjection[1] = 3
        }

        #expect(scenes[1].x == 3)
    }
}

// MARK: - CountingIndexCollectionTests

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

// MARK: - CountingIndexTests

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
        #expect(index1 != index3)
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

// MARK: - Cache3Tests

struct Cache3Tests {
    @Test
    func put() {
        var cache: Cache3<Int, String> = Cache3()
        cache.put(1, value: "1")
        #expect(cache.find(1) == "1")
        #expect(cache.find(2) == nil)
        #expect(cache.find(3) == nil)
        #expect(cache.find(4) == nil)

        cache.put(2, value: "2")
        #expect(cache.find(1) == "1")
        #expect(cache.find(2) == "2")
        #expect(cache.find(3) == nil)
        #expect(cache.find(4) == nil)

        cache.put(3, value: "3")
        #expect(cache.find(1) == "1")
        #expect(cache.find(2) == "2")
        #expect(cache.find(3) == "3")
        #expect(cache.find(4) == nil)

        cache.put(4, value: "4")
        #expect(cache.find(1) == nil)
        #expect(cache.find(2) == "2")
        #expect(cache.find(3) == "3")
        #expect(cache.find(4) == "4")
    }

    @Test
    func get() {
        var cache: Cache3<Int, String> = Cache3()

        let value4 = cache.get(4) { "4" }
        #expect(value4 == "4")
        #expect(cache.find(1) == nil)
        #expect(cache.find(2) == nil)
        #expect(cache.find(3) == nil)
        #expect(cache.find(4) == "4")

        let value3 = cache.get(3) { "3" }
        #expect(value3 == "3")
        #expect(cache.find(1) == nil)
        #expect(cache.find(2) == nil)
        #expect(cache.find(3) == "3")
        #expect(cache.find(4) == "4")

        let value2 = cache.get(2) { "2" }
        #expect(value2 == "2")
        #expect(cache.find(1) == nil)
        #expect(cache.find(2) == "2")
        #expect(cache.find(3) == "3")
        #expect(cache.find(4) == "4")

        let value1 = cache.get(1) { "1" }
        #expect(value1 == "1")
        #expect(cache.find(1) == "1")
        #expect(cache.find(2) == "2")
        #expect(cache.find(3) == "3")
        #expect(cache.find(4) == nil)
    }
}

// MARK: - CollectionOfTwoTests

struct CollectionOfTwoTests {
    @Test
    func initialization() {
        let collection = CollectionOfTwo("first", "second")

        #expect(collection.elements.0 == "first")
        #expect(collection.elements.1 == "second")
    }

    @Test
    func indices() {
        let collection = CollectionOfTwo(10, 20)

        #expect(collection.startIndex == 0)
        #expect(collection.endIndex == 2)
        #expect(collection.count == 2)
        #expect(collection.indices == 0 ..< 2)
    }

    @Test
    func subscriptGetter() {
        let collection = CollectionOfTwo("a", "b")

        #expect(collection[0] == "a")
        #expect(collection[1] == "b")
    }

    @Test
    func subscriptSetter() {
        var collection = CollectionOfTwo(1, 2)

        collection[0] = 10
        collection[1] = 20

        #expect(collection[0] == 10)
        #expect(collection[1] == 20)
        #expect(collection.elements.0 == 10)
        #expect(collection.elements.1 == 20)
    }

    @Test
    func iteration() {
        let collection = CollectionOfTwo("hello", "world")
        var result: [String] = []

        for element in collection {
            result.append(element)
        }

        #expect(result == ["hello", "world"])
    }

    @Test
    func randomAccessCollection() {
        let collection = CollectionOfTwo(100, 200)

        #expect(collection.first == 100)
        #expect(collection.last == 200)
        #expect(collection.isEmpty == false)
    }

    @Test
    func map() {
        let collection = CollectionOfTwo(1, 2)
        let mapped = collection.map { $0 * 10 }

        #expect(mapped == [10, 20])
    }

    @Test
    func filter() {
        let collection = CollectionOfTwo(1, 2)
        let filtered = collection.filter { $0 > 1 }

        #expect(filtered == [2])
    }

    @Test
    func reduce() {
        let collection = CollectionOfTwo(5, 10)
        let sum = collection.reduce(0, +)

        #expect(sum == 15)
    }

    @Test
    func slicing() {
        let collection = CollectionOfTwo("a", "b")
        let slice = collection[0 ..< 1]

        #expect(Array(slice) == ["a"])
    }

    @Test
    func mutatingMethods() {
        var collection = CollectionOfTwo(1, 2)

        for i in collection.indices {
            collection[i] *= 2
        }

        #expect(collection[0] == 2)
        #expect(collection[1] == 4)
    }

    @Test
    func differentTypes() {
        let intCollection = CollectionOfTwo(1, 2)
        let stringCollection = CollectionOfTwo("x", "y")
        let doubleCollection = CollectionOfTwo(1.5, 2.5)

        #expect(intCollection.count == 2)
        #expect(stringCollection.count == 2)
        #expect(doubleCollection.count == 2)

        #expect(intCollection[0] == 1)
        #expect(stringCollection[1] == "y")
        #expect(doubleCollection[0] == 1.5)
    }

    @Test
    func indexAdvancement() {
        let collection = CollectionOfTwo("first", "second")

        let startIndex = collection.startIndex
        let nextIndex = collection.index(after: startIndex)
        let endIndex = collection.endIndex

        #expect(startIndex == 0)
        #expect(nextIndex == 1)
        #expect(endIndex == 2)

        let previousIndex = collection.index(before: endIndex)
        #expect(previousIndex == 1)
    }

    @Test
    func contains() {
        let collection = CollectionOfTwo("apple", "banana")

        #expect(collection.contains("apple"))
        #expect(collection.contains("banana"))
        #expect(!collection.contains("orange"))
    }
}
