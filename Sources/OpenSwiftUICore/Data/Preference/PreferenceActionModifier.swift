//
//  PreferenceActionModifier.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 264234112339315C9A664F0B7F8B50C1 (SwiftUICore)

import OpenAttributeGraphShims

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

@frozen
public struct _PreferenceActionModifier<K>: MultiViewModifier, PrimitiveViewModifier where K: PreferenceKey, K.Value: Equatable {
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
        var inputs = inputs
        inputs.preferences.add(K.self)
        let outputs = body(_Graph(), inputs)
        guard let keyValue = outputs[K.self] else {
            return outputs
        }
        let binder = Attribute(PreferenceBinder<K>(
            modifier: modifier.value,
            keyValue: keyValue,
            phase: inputs.viewPhase,
            lastResetSeed: .zero,
            lastValue: nil
        ))
        binder.flags = .transactional
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
        let (newValue, changed) = $keyValue.changedValue()
        guard changed || (lastValue == nil && _SemanticFeature_v6_1.isEnabled) else {
            return
        }
        guard lastValue != newValue else {
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
