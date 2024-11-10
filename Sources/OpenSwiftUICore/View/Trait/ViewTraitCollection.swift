//
//  ViewTraitCollection.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP
//  ID: 9929B476764059557433A108298EE66F

package struct ViewTraitCollection {
    package init() {
        self.storage = []
    }
    
    private var storage: [any AnyViewTrait]
    
    private struct AnyTrait<Key: _ViewTraitKey>: AnyViewTrait {
        var value: Key.Value
        
        init(value: Key.Value) {
            self.value = value
        }
        
        var id: ObjectIdentifier { ObjectIdentifier(Key.self) }
        
        subscript<V>() -> V {
            get { value as! V }
            set { value = newValue as! Key.Value }
        }
    }
    
    subscript<Key: _ViewTraitKey>(_: Key.Type) -> Key.Value {
        get {
            value(for: Key.self)
        }
        set {
            if let index = storage.firstIndex(where: { $0.id == ObjectIdentifier(Key.self) }) {
                storage[index][] = newValue
            } else {
                storage.append(AnyTrait<Key>(value: newValue))
            }
        }
    }
    
    func value<Key: _ViewTraitKey>(for _: Key.Type, defaultValue: Key.Value = Key.defaultValue) -> Key.Value {
        storage.first { $0.id == ObjectIdentifier(Key.self) }?[] ?? defaultValue
    }
    
    mutating func setValueIfUnset<Key: _ViewTraitKey>(_ value: Key.Value, for _: Key.Type) {
        guard !storage.contains(where: { $0.id == ObjectIdentifier(Key.self) }) else {
            return
        }
        storage.append(AnyTrait<Key>(value: value))
    }
    
//    func insertInteraction(for: OnInsertInteraction.Strategy) -> OnInsertInteraction? {
//        fatalError("TODO")
//    }
//    
//    var optionalTransition: AnyTransition? {
//        fatalError("TODO")
//    }
}

private protocol AnyViewTrait {
    var id: ObjectIdentifier { get }
    subscript<V>() -> V { get set }
}
