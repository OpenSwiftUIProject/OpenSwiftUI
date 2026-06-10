//
//  LazyState.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: D23E5900647091DC07D54FF9E7D1D688 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore

// MARK: - LazyState

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
@propertyWrapper
@frozen
public struct LazyState<Value>: DynamicProperty {
    @usableFromInline
    enum Storage {
        case thunk(() -> Value)
        case value(Value)

        @usableFromInline
        var value: Value {
            switch self {
            case let .thunk(thunk):
                thunk()
            case let .value(value):
                value
            }
        }
    }

    @usableFromInline
    var _storage: Storage

    @usableFromInline
    var _location: AnyLocation<Value>?

    public init(wrappedValue thunk: @autoclosure @escaping () -> Value) {
        _storage = .thunk(thunk)
        _location = nil
    }

    public var wrappedValue: Value {
        get {
            getValue(forReading: true)
        }
        nonmutating set {
            guard let _location else {
                return
            }
            _location.set(newValue, transaction: Transaction())
        }
    }

    public var projectedValue: Binding<Value> {
        let value = getValue(forReading: false)
        guard let _location else {
            Log.runtimeIssues("Accessing State's value outside of being installed on a View. This will result in a constant Binding of the initial value and will not update.")
            return .constant(value)
        }
        return Binding(value: value, location: _location)
    }

    private func getValue(forReading: Bool) -> Value {
        guard let _location else {
            return _storage.value
        }
        if GraphHost.isUpdating {
            if forReading {
                _location.wasRead = true
            }
            return _storage.value
        } else {
            return _location.get()
        }
    }

    public static func _makeProperty<V>(
        in buffer: inout _DynamicPropertyBuffer,
        container: _GraphValue<V>,
        fieldOffset: Int,
        inputs: inout _GraphInputs
    ) {
        let attribute = Attribute(value: ())
        let box = LazyStatePropertyBox<Value>(signal: WeakAttribute(attribute))
        buffer.append(box, fieldOffset: fieldOffset)
        addTreeValue(
            attribute,
            as: Value.self,
            at: fieldOffset,
            in: V.self,
            flags: .stateSignal
        )
    }
}

@_spi(Private)
@available(*, unavailable)
extension LazyState: Sendable {}

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
extension LazyState where Value: ExpressibleByNilLiteral {
    @inlinable
    public init() {
        self.init(wrappedValue: nil)
    }
}

@_spi(Private)
@available(*, unavailable)
extension LazyState.Storage: Sendable {}

// MARK: - LazyStatePropertyBox

private struct LazyStatePropertyBox<Value>: DynamicPropertyBox {
    let signal: WeakAttribute<Void>

    var location: StoredLocation<Value>?

    typealias Property = LazyState<Value>

    func destroy() {
        location?.invalidate()
    }

    mutating func reset() {
        location?.invalidate()
        location = nil
    }

    mutating func update(property: inout LazyState<Value>, phase: _GraphInputs.Phase) -> Bool {
        let oldLocation = location
        var changed = oldLocation == nil
        let newLocation: StoredLocation<Value>
        if let oldLocation {
            newLocation = oldLocation
        } else {
            newLocation = property._location as? StoredLocation ?? StoredLocation(
                initialValue: property._storage.value,
                host: .currentHost,
                signal: signal
            )
            location = newLocation
        }
        let signalChanged = signal.changedValue()?.changed ?? false
        property._storage = .value(newLocation.updateValue)
        property._location = newLocation
        if signalChanged {
            changed = oldLocation == nil || newLocation.wasRead
        }
        return changed
    }
}
