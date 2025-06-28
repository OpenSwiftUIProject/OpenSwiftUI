import Testing
@testable import OpenSwiftUICore

// MARK: - CollectionOfTwo Tests

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
        #expect(collection.indices == 0..<2)
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
        let slice = collection[0..<1]
        
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
