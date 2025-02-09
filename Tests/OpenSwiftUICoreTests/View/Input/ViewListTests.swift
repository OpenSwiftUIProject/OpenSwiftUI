//
//  ViewListTests.swift
//  OpenSwiftUICoreTests

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import Testing

struct ViewListIteratorStyleTests {
    @Test
    func granularityAndApplyGranularity() {
        var iteratorStyle = ViewList.IteratorStyle()
        #expect(iteratorStyle.granularity == 1)
        #expect(iteratorStyle.applyGranularity == false)
        
        iteratorStyle.granularity = 2
        iteratorStyle.applyGranularity = true
        
        #expect(iteratorStyle.granularity == 2)
        #expect(iteratorStyle.applyGranularity == true)
    }
    
    @Test(arguments: [
        (ViewList.IteratorStyle(granularity: 1), 0, 0, 0),
        (ViewList.IteratorStyle(granularity: 1), 1, 1, 1),
        (ViewList.IteratorStyle(granularity: 1), 2, 2, 2),
        (ViewList.IteratorStyle(granularity: 2), 0, 0, 0),
        (ViewList.IteratorStyle(granularity: 2), 1, 0, 2),
        (ViewList.IteratorStyle(granularity: 2), 2, 2, 2),
        (ViewList.IteratorStyle(granularity: 2), 3, 2, 4),
        (ViewList.IteratorStyle(granularity: 3), 0, 0, 0),
        (ViewList.IteratorStyle(granularity: 3), 1, 0, 3),
        (ViewList.IteratorStyle(granularity: 3), 2, 0, 3),
        (ViewList.IteratorStyle(granularity: 3), 3, 3, 3),
        (ViewList.IteratorStyle(granularity: 3), 4, 3, 6),
    ])
    func alignment(
        _ iteratorStyle: ViewList.IteratorStyle,
        _ initialValue: Int,
        _ expectedPrevious: Int,
        _ expectedNext: Int
    ) {
        var previous = initialValue
        iteratorStyle.alignToPreviousGranularityMultiple(&previous)
        #expect(previous == expectedPrevious)
        
        var next = initialValue
        iteratorStyle.alignToNextGranularityMultiple(&next)
        #expect(next == expectedNext)
    }
}

struct ViewListIDTests {
    @Test
    func initialization() {
        let id1 = ViewList.ID()
        #expect(id1.index == 0)
        #expect(id1.primaryExplicitID == nil)
        
        let id2 = ViewList.ID(implicitID: 42)
        #expect(id2.index == 0)
        #expect(id2.primaryExplicitID == nil)
    }
    
    @Test
    func elementIDGeneration() {
        let baseID = ViewList.ID(implicitID: 1)
        let element1 = baseID.elementID(at: 0)
        let element2 = baseID.elementID(at: 5)
        
        #expect(element1.index == 0)
        #expect(element2.index == 5)
    }
    
    @Test
    func elementCollection() {
        let baseID = ViewList.ID(implicitID: 1)
        let collection = baseID.elementIDs(count: 3)
        
        #expect(collection.count == 3)
        #expect(collection.startIndex == 0)
        #expect(collection.endIndex == 3)
        
        let elements = Array(collection)
        #expect(elements.count == 3)
        #expect(elements[0].index == 0)
        #expect(elements[1].index == 1)
        #expect(elements[2].index == 2)
    }
    
    @Test
    func canonicalID() {
        var id = ViewList.ID(implicitID: 42)
        let canonical1 = id.canonicalID
        #expect(canonical1.index == 0)
        #expect(canonical1.requiresImplicitID == true)
        #expect(canonical1.explicitID == nil)
        #expect(canonical1.description == "@0")
        
        #if canImport(Darwin)
        id.bind(explicitID: "test", owner: .nil)
        let canonical2 = id.canonicalID
        #expect(canonical2.index == 0)
        #expect(canonical2.requiresImplicitID == true)
        #expect(canonical2.explicitID?.description == "test")
        #expect(canonical2.description == "test")
        #endif
    }
    
    @Test
    func explicitIDOperations() {
        #if canImport(Darwin)
        var id = ViewList.ID()
        
        // Test binding single explicit ID
        id.bind(explicitID: "test1", owner: .nil)
        #expect(id.primaryExplicitID?.description == "test1")
        #expect(id.allExplicitIDs.count == 1)
        
        // Test binding multiple explicit IDs
        id.bind(explicitID: "test2", owner: .nil)
        #expect(id.allExplicitIDs.count == 2)
        #expect(id.primaryExplicitID?.description == "test1")
        
        // Test explicit ID lookup
        let stringID: String? = id.explicitID(for: String.self)
        #expect(stringID == "test1")
        
        // Test static explicit ID creation
        let explicitID = ViewList.ID.explicit("test3")
        #expect(explicitID.primaryExplicitID?.description == "test3")
        #endif
    }
    
    @Test
    func hashableConformance() {
        let id1 = ViewList.ID(implicitID: 1)
        let id2 = ViewList.ID(implicitID: 1)
        let id3 = ViewList.ID(implicitID: 2)
        
        #expect(id1 == id2)
        #expect(id1 != id3)
        
        var hasher = Hasher()
        id1.hash(into: &hasher)
        id2.hash(into: &hasher)
        // Just verifying that hashing doesn't crash
    }
}
