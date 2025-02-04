//
//  ViewTraitTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Testing
import Numerics

fileprivate struct IntTrait: _ViewTraitKey {
    static let defaultValue: Int = .zero
}

fileprivate struct Int32Trait: _ViewTraitKey {
    static let defaultValue: Int32 = .zero
}

fileprivate struct DoubleTrait: _ViewTraitKey {
    static let defaultValue: Double = .zero
}

struct ViewTraitCollectionTests {
    @Test("Test ViewTraitCollection contains API")
    func contains() {
        var collection = ViewTraitCollection()
        #expect(collection.contains(IntTrait.self) == false)
        #expect(collection.contains(DoubleTrait.self) == false)
        
        collection[IntTrait.self] = 1
        #expect(collection.contains(IntTrait.self) == true)
        
        collection[DoubleTrait.self] = 1.0
        #expect(collection.contains(DoubleTrait.self) == true)
    }
    
    @Test("Test ViewTraitCollection value abd setValueIfUnset API")
    func value() {
        var collection = ViewTraitCollection()
        
        #expect(collection.value(for: IntTrait.self) == IntTrait.defaultValue)
        #expect(collection.value(for: DoubleTrait.self).isApproximatelyEqual(to: DoubleTrait.defaultValue))
        
        collection[IntTrait.self] = 1
        collection[DoubleTrait.self] = 1.0
        
        #expect(collection.value(for: IntTrait.self) == 1)
        #expect(collection.value(for: DoubleTrait.self).isApproximatelyEqual(to: 1.0))
        
        collection.setValueIfUnset(2, for: IntTrait.self)
        collection.setValueIfUnset(2.0, for: DoubleTrait.self)
        
        // Values should not change since they were already set
        #expect(collection.value(for: IntTrait.self) == 1)
        #expect(collection.value(for: DoubleTrait.self).isApproximatelyEqual(to: 1.0))
        
        collection[IntTrait.self] = 3
        collection[DoubleTrait.self] = 3.0
        
        #expect(collection.value(for: IntTrait.self) == 3)
        #expect(collection.value(for: DoubleTrait.self).isApproximatelyEqual(to: 3.0))
    }
    
    @Test("Test ViewTraitCollection mergeValues API")
    func mergeValues() {
        var collection1 = ViewTraitCollection()
        var collection2 = ViewTraitCollection()

        collection1[IntTrait.self] = 1
        collection1[DoubleTrait.self] = 1.0
                
        collection2[Int32Trait.self] = 2
        collection2[DoubleTrait.self] = 2.0
        
        collection1.mergeValues(collection2)
        #expect(collection1.value(for: IntTrait.self) == 1)
        #expect(collection1.value(for: Int32Trait.self) == 2)
        #expect(collection1.value(for: DoubleTrait.self).isApproximatelyEqual(to: 2.0))
        
        // Test merging with empty collection
        let emptyCollection = ViewTraitCollection()
        collection1.mergeValues(emptyCollection)
        
        // Values should remain unchanged
        #expect(collection1.value(for: IntTrait.self) == 1)
        #expect(collection1.value(for: Int32Trait.self) == 2)
        #expect(collection1.value(for: DoubleTrait.self).isApproximatelyEqual(to: 2.0))
    }
}

struct ViewTraitKeyTests {
    @Test("Test ViewTraitKeys contains API")
    func contains() {
        var keys = ViewTraitKeys()
        #expect(keys.contains(IntTrait.self) == false)
        #expect(keys.contains(Int32Trait.self) == false)
        #expect(keys.contains(DoubleTrait.self) == false)
        
        keys.insert(IntTrait.self)
        #expect(keys.contains(IntTrait.self) == true)
        #expect(keys.contains(Int32Trait.self) == false)
        #expect(keys.contains(DoubleTrait.self) == false)
    }
    
    @Test("Test ViewTraitKeys formUnion API")
    func formUnion() {
        var keys1 = ViewTraitKeys()
        var keys2 = ViewTraitKeys()
        
        keys1.insert(IntTrait.self)
        keys2.insert(Int32Trait.self)
        keys2.insert(DoubleTrait.self)
        
        keys1.formUnion(keys2)
        
        #expect(keys1.contains(IntTrait.self) == true)
        #expect(keys1.contains(Int32Trait.self) == true)
        #expect(keys1.contains(DoubleTrait.self) == true)
        #expect(keys1.isDataDependent == false)
        
        // Test union with data dependent keys
        let dataDependent = keys2.withDataDependent()
        keys1.formUnion(dataDependent)
        #expect(keys1.isDataDependent == true)
    }
    
    @Test("Test ViewTraitKeys withDataDependent API")
    func withDataDependent() {
        var keys = ViewTraitKeys()
        keys.insert(IntTrait.self)
        #expect(keys.isDataDependent == false)
        
        let dependent = keys.withDataDependent()
        #expect(dependent.isDataDependent == true)
        #expect(dependent.contains(IntTrait.self) == true)
        
        // Original should remain unchanged
        #expect(keys.isDataDependent == false)
    }
}
