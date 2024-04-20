//
//  StoredLocation.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: EBDC911C9EE054BAE3D86F947C24B7C3

class StoredLocationBase<Value>: AnyLocation<Value> {
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
    
    deinit {
        $data.destroy()
    }
    
    private func beginUpdate() {
        // TODO
    }
}

// TODO
final class StoredLocation<Value>: StoredLocationBase<Value> {
    
}
