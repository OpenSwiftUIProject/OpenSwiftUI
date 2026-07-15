//
//  PreferenceActionModifier.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 264234112339315C9A664F0B7F8B50C1 (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - View + onPreferenceChange

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Adds an action to perform when the specified preference key's value
    /// changes.
    ///
    /// - Parameters:
    ///   - key: The key to monitor for value changes.
    ///   - action: The action to perform when the value for `key` changes. The
    ///     `action` closure passes the new value as its parameter.
    ///
    /// - Returns: A view that triggers `action` when the value for `key`
    ///   changes.
    @inlinable
    nonisolated public func onPreferenceChange<K>(
        _ key: K.Type = K.self,
        perform action: @escaping (K.Value) -> Void
    ) -> some View where K: PreferenceKey, K.Value: Equatable {
        return modifier(_PreferenceActionModifier<K>(action: action))
    }
}

// MARK: - PreferenceActionModifier

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _PreferenceActionModifier<K>: ViewModifier, MultiViewModifier, PrimitiveViewModifier where K: PreferenceKey, K.Value: Equatable {
    public var action: (_ value: K.Value) -> Void
    
    @inlinable
    public init(action: @escaping (_ value: K.Value) -> Void) {
        self.action = action
    }
    
    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var newInputs = inputs
        newInputs.preferences.add(K.self)
        let outputs = body(_Graph(), newInputs)
        if let keyValue = outputs[K.self] {
            let binder = Attribute(PreferenceBinder<K>(
                modifier: modifier.value,
                keyValue: keyValue,
                phase: inputs.viewPhase,
                lastResetSeed: .zero,
                lastValue: nil
            ))
            binder.setFlags(.transactional, mask: .all)
        }
        return outputs        
    }
}

@available(*, unavailable)
extension _PreferenceActionModifier: Sendable {}

// MARK: - PreferenceBinder

private struct PreferenceBinder<K>: StatefulRule, AsyncAttribute where K: PreferenceKey, K.Value: Equatable {
    @Attribute var modifier: _PreferenceActionModifier<K>
    @Attribute var keyValue: K.Value
    @Attribute var phase: _GraphInputs.Phase
    var cycleDetector: UpdateCycleDetector
    var lastResetSeed: UInt32
    var lastValue: K.Value?

    init(
        modifier: Attribute<_PreferenceActionModifier<K>>,
        keyValue: Attribute<K.Value>,
        phase: Attribute<_GraphInputs.Phase>,
        cycleDetector: UpdateCycleDetector = .init(),
        lastResetSeed: UInt32,
        lastValue: K.Value?
    ) {
        self._modifier = modifier
        self._keyValue = keyValue
        self._phase = phase
        self.cycleDetector = cycleDetector
        self.lastResetSeed = lastResetSeed
        self.lastValue = lastValue
    }
    
    typealias Value = Void
    
    mutating func updateValue() {
        if lastResetSeed != phase.resetSeed {
            lastResetSeed = phase.resetSeed
            cycleDetector.reset()
            lastValue = nil
        }
        let (newValue, valueChanged) = $keyValue.changedValue()
        guard (lastValue == nil && _SemanticFeature_v6_1.isEnabled) || (valueChanged && lastValue != newValue) else {
            return
        }
        lastValue = newValue
        guard cycleDetector.dispatch(
            label: "Bound preference \(K.self)",
            isDebug: true
        ) else {
            return
        }
        let action = Graph.withoutUpdate {
            modifier.action
        }
        Update.enqueueAction(reason: nil) {
            action(newValue)
        }
    }
}

// MARK: - TransactionalPreferenceActionModifier

// Added in OpenSwiftUI_v6_2 (6.2.16)
package struct TransactionalPreferenceActionModifier<K>: ViewModifier, MultiViewModifier, PrimitiveViewModifier where K: PreferenceKey, K.Value: Equatable {
    var action: (_ value: K.Value, _ transaction: Transaction) -> Void

    package init(action: @escaping (_ value: K.Value, _ transaction: Transaction) -> Void) {
        self.action = action
    }

    nonisolated package static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var newInputs = inputs
        newInputs.preferences.add(K.self)
        let outputs = body(_Graph(), newInputs)
        if let keyValue = outputs[K.self] {
            let binder = Attribute(TransactionalPreferenceBinder<K>(
                modifier: modifier.value,
                keyValue: keyValue,
                phase: inputs.viewPhase,
                transaction: inputs.transaction,
                lastResetSeed: .zero,
                lastValue: nil
            ))
            binder.setFlags(.transactional, mask: .all)
        }
        return outputs
    }
}

// MARK: - TransactionalPreferenceBinder

private struct TransactionalPreferenceBinder<K>: StatefulRule, AsyncAttribute where K: PreferenceKey, K.Value: Equatable {
    @Attribute var modifier: TransactionalPreferenceActionModifier<K>
    @Attribute var keyValue: K.Value
    @Attribute var phase: _GraphInputs.Phase
    @Attribute var transaction: Transaction
    var cycleDetector: UpdateCycleDetector
    var lastResetSeed: UInt32
    var lastValue: K.Value?

    init(
        modifier: Attribute<TransactionalPreferenceActionModifier<K>>,
        keyValue: Attribute<K.Value>,
        phase: Attribute<_GraphInputs.Phase>,
        transaction: Attribute<Transaction>,
        cycleDetector: UpdateCycleDetector = .init(),
        lastResetSeed: UInt32,
        lastValue: K.Value?
    ) {
        self._modifier = modifier
        self._keyValue = keyValue
        self._phase = phase
        self._transaction = transaction
        self.cycleDetector = cycleDetector
        self.lastResetSeed = lastResetSeed
        self.lastValue = lastValue
    }

    typealias Value = Void

    mutating func updateValue() {
        if lastResetSeed != phase.resetSeed {
            lastResetSeed = phase.resetSeed
            cycleDetector.reset()
            lastValue = nil
        }
        let (newValue, valueChanged) = $keyValue.changedValue()
        guard lastValue == nil || (valueChanged && lastValue != newValue) else {
            return
        }
        lastValue = newValue
        guard cycleDetector.dispatch(
            label: "Bound preference \(K.self)",
            isDebug: true
        ) else {
            return
        }
        let action = Graph.withoutUpdate {
            modifier.action
        }
        let transaction = Graph.withoutUpdate {
            self.transaction
        }
        Update.enqueueAction(reason: nil) {
            action(newValue, transaction)
        }
    }
}
