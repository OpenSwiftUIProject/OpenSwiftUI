//
//  StoredLocation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: EBDC911C9EE054BAE3D86F947C24B7C3 (SwiftUI)
//  ID: 4F21368B1C1680817451AC25B55A8D48 (SwiftUICore)

package import OpenAttributeGraphShims
import OpenSwiftUI_SPI

// MARK: - StoredLocationBase

package class StoredLocationBase<Value>: AnyLocation<Value>, Location, @unchecked Sendable {
    private struct Data {
        var currentValue: Value
        var savedValue: [Value]
        var cache: LocationProjectionCache
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
                _ = data.savedValue.removeLast()
            }
            return true
        }
    }

    @AtomicBox
    private var data: Data

    var _wasRead: Bool

    package init(initialValue value: Value) {
        _wasRead = false
        _data = AtomicBox(wrappedValue: Data(currentValue: value, savedValue: [], cache: .init()))
        super.init()
    }

    // MARK: - final properties and methods

    final package var updateValue: Value {
        $data.access { data in
            data.savedValue.first ?? data.currentValue
        }
    }

    final var binding: Binding<Value> {
        Binding(value: updateValue, location: self)
    }

    final private func beginUpdate() {
        $data.access { data in
            _ = data.savedValue.removeFirst()
        }
        notifyObservers()
    }

    final package func invalidate() {
        $data.access { data in
            data.cache.reset()
        }
    }

    // MARK: - non-final methods

    fileprivate var isValid: Bool {
        true
    }

    // MARK: - abstract method

    fileprivate var isUpdating: Bool {
        _openSwiftUIBaseClassAbstractMethod()
    }

    fileprivate func commit(transaction: Transaction, id: Transaction.ID, mutation: BeginUpdate) {
        _openSwiftUIBaseClassAbstractMethod()
    }

    fileprivate func notifyObservers() {
        _openSwiftUIBaseClassAbstractMethod()
    }

    // MARK: - AnyLocation

    override final package var wasRead: Bool {
        get { _wasRead }
        set { _wasRead = newValue }
    }

    override final package func get() -> Value {
        data.currentValue
    }

    override final package func projecting<P: Projection>(
        _ projection: P
    ) -> AnyLocation<P.Projected> where Value == P.Base {
        $data.access { data in
            data.cache.reference(for: projection, on: self)
        }
    }

    override final package func set(_ value: Value, transaction: Transaction) {
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
        let transaction = transaction.current
        let id = Transaction.id
        onMainThread { [weak self] in
            guard let self else {
                return
            }
            let update = BeginUpdate(box: self)
            commit(transaction: transaction, id: id, mutation: update)
        }
    }

    override package func update() -> (Value, Bool) {
        _wasRead = true
        return (updateValue, true)
    }
}

// MARK: - StoredLocation

final package class StoredLocation<Value>: StoredLocationBase<Value>, @unchecked Sendable {
    weak var host: GraphHost?
    @WeakAttribute var signal: Void?

    package init(initialValue value: Value, host: GraphHost?, signal: WeakAttribute<Void>) {
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

    override fileprivate func commit(
        transaction: Transaction,
        id: Transaction.ID,
        mutation: StoredLocationBase<Value>.BeginUpdate
    ) {
        host?.asyncTransaction(
            transaction,
            id: id,
            mutation: mutation
        )
    }

    override fileprivate func notifyObservers() {
        $signal?.invalidateValue()
    }
}

// MARK: - ObservableLocation

final package class ObservableLocation<Value>: StoredLocationBase<Value>, TransactionHostProvider, @unchecked Sendable {
    private struct Observer {
        weak var host: GraphHost?
        var signal: WeakAttribute<Void>
    }

    private var observers: [Observer] = []

    package func addObserver(host: GraphHost, signal: WeakAttribute<Void>) {
        observers.append(Observer(host: host, signal: signal))
    }

    package func removeObserver(signal: WeakAttribute<Void>) {
        if let index = observers.firstIndex(where: { $0.signal == signal }) {
            observers.remove(at: index)
        }
    }

    override fileprivate var isUpdating: Bool {
        GraphHost.isUpdating
    }

    override fileprivate func commit(
        transaction: Transaction,
        id: Transaction.ID,
        mutation: StoredLocationBase<Value>.BeginUpdate
    ) {
        GraphHost.globalTransaction(
            transaction,
            id: id,
            mutation: mutation,
            hostProvider: self
        )
    }

    override fileprivate func notifyObservers() {
        var index = 0
        var count = observers.count
        while index < count {
            if let signal = observers[index].signal.attribute {
                signal.invalidateValue()
                index += 1
            } else {
                count -= 1
                if index != count {
                    observers.swapAt(index, count)
                }
                observers.remove(at: count)
            }
        }
    }

    package var mutationHost: GraphHost? {
        observers.reduce(nil) { $0 ?? $1.host }
    }
}
