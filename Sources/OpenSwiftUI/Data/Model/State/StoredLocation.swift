//
//  StoredLocation.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: EBDC911C9EE054BAE3D86F947C24B7C3

internal import OpenGraphShims
internal import COpenSwiftUI
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore

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
    
    fileprivate struct BeginUpdate: GraphMutation {
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
            
            box.$data.access { data in
                _ = data.savedValue.removeFirst()
            }
            return true
        }
    }
    
    @AtomicBox
    private var data: LockedData
    
    var _wasRead: Bool
    
    init(initialValue value: Value) {
        _wasRead = false
        _data = AtomicBox(wrappedValue: LockedData(currentValue: value, savedValue: []))
        super.init()
    }
    
    fileprivate var isValid: Bool { true }
    
    // MARK: - abstract method
    
    fileprivate var isUpdating: Bool {
        fatalError("abstract")
    }
    
    fileprivate func commit(transaction: Transaction, mutation: BeginUpdate) {
        fatalError("abstract")
    }
    
    fileprivate func notifyObservers() {
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
            $data.access { data in
                data.savedValue.removeAll()
            }
            return
        }
        let shouldCommit = $data.access { data in
            guard !compareValues(data.currentValue, value) else {
                return false
            }
            data.savedValue.append(data.currentValue)
            data.currentValue = value
            return true
        }
        guard shouldCommit else {
            return
        }
        var newTransaction = transaction
        newTransaction.override(.current)
        onMainThread { [weak self] in
            guard let self else {
                return
            }
            let update = BeginUpdate(box: self)
            commit(transaction: newTransaction, mutation: update)
        }
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
    }
    
    final var updateValue: Value {
        $data.access { data in
            data.savedValue.first ?? data.currentValue
        }
    }
    
    private final func beginUpdate() {
        data.savedValue.removeFirst()
        notifyObservers()
    }
}

final class StoredLocation<Value>: StoredLocationBase<Value> {
    weak var host: GraphHost?
    @WeakAttribute var signal: Void?
    
    init(initialValue value: Value, host: GraphHost?, signal: WeakAttribute<Void>) {
        self.host = host
        _signal = signal
        super.init(initialValue: value)
    }
    
    override fileprivate var isValid: Bool {
        host?.isValid ?? false
    }
    
    override fileprivate var isUpdating: Bool {
        host?.isUpdating ?? false
    }
    
    override fileprivate func commit(transaction: Transaction, mutation: StoredLocationBase<Value>.BeginUpdate) {
        host?.asyncTransaction(
            transaction,
            mutation: mutation,
            style: ._1,
            mayDeferUpdate: true
        )
    }
    
    override fileprivate func notifyObservers() {
        $signal?.invalidateValue()
    }
}
