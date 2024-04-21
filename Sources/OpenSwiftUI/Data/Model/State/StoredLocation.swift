//
//  StoredLocation.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: EBDC911C9EE054BAE3D86F947C24B7C3

internal import OpenGraphShims
internal import COpenSwiftUI

class StoredLocationBase<Value>: AnyLocation<Value>, Location {
    private struct LockedData {
        var currentValue: Value
        var savedValue: [Value]
        var cache: LocationProjectionCache
        
        init(currentValue: Value, savedValue: [Value], cache: LocationProjectionCache = LocationProjectionCache()) {
            self.currentValue = currentValue
            self.savedValue = savedValue
            self.cache = cache
        }
    }
    
    private struct BeginUpdate: GraphMutation {
        weak var box: StoredLocationBase<Value>?
        
        func apply() {
            box?.beginUpdate()
        }
        
        func combine<Mutation: GraphMutation>(with mutation: Mutation) -> Bool {
            guard let otherBeginUpdate = mutation as? BeginUpdate,
                  let box,
                  let otherBox = otherBeginUpdate.box,
                  box === otherBox
            else {
                return false
            }
            
            box.$data.withMutableData { data in
                _ = data.savedValue.removeFirst()
            }
            return true
        }
    }
    
    @UnsafeLockedPointer
    private var data: LockedData
    
    var _wasRead: Bool
    
    init(initialValue value: Value) {
        _wasRead = false
        _data = UnsafeLockedPointer(wrappedValue: LockedData(currentValue: value, savedValue: []))
        super.init()
    }
    
    private var isValid: Bool {
        true
    }
    
    // MARK: - abstract method
    
    private var isUpdating: Bool {
        fatalError("abstract")
    }
    
    private func commit(transaction: Transaction, mutation: BeginUpdate) {
        fatalError("abstract")
    }
    
    private func notifyObservers() {
        fatalError("abstract")
    }
    
    // MARK: - AnyLocation
    
    override var wasRead: Bool {
        get { _wasRead }
        set { _wasRead = newValue }
    }
    
    override func get() -> Value {
        data.currentValue
    }
    
    override func set(_ value: Value, transaction: Transaction) {
        guard !isUpdating else {
            Log.runtimeIssues("Modifying state during view update, this will cause undefined behavior.")
            return
        }
        guard isValid else {
            $data.withMutableData { data in
                data.savedValue.removeAll()
            }
            return
        }
        let _ = $data.withMutableData { data in
            guard !compareValues(data.currentValue, value) else {
                return false
            }
            data.savedValue.append(data.currentValue)
            data.currentValue = value
            return true
        }
        // TODO
    }
    
    override func projecting<P: Projection>(_ projection: P) -> AnyLocation<P.Projected> where Value == P.Base {
        data.cache.reference(for: projection, on: self)
    }
    
    override func update() -> (Value, Bool) {
        _wasRead = true
        return (updateValue, true)
    }
    
    // MARK: - final properties and methods
    
    deinit {
        $data.destroy()
    }
    
    final var updateValue: Value {
        $data.withMutableData { data in
            data.savedValue.first ?? data.currentValue
        }
    }
    
    private final func beginUpdate() {
        data.savedValue.removeFirst()
    }
}

// TODO
final class StoredLocation<Value>: StoredLocationBase<Value> {
    
}
