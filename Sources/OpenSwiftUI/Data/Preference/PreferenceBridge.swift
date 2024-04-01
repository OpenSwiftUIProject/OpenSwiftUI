//
//  PreferenceBridge.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete
//  ID: A9FAE381E99529D5274BA37A9BC9B074

internal import OpenGraphShims

final class PreferenceBridge {
    unowned let viewGraph: ViewGraph
    private var children: [Unmanaged<ViewGraph>] = []
    var requestedPreferences = PreferenceKeys()
    var bridgedViewInputs = PropertyList()
    @WeakAttribute var hostPreferenceKeys: PreferenceKeys?
    @WeakAttribute var hostPreferencesCombiner: PreferenceList?
    private var bridgedPreferences: [BridgedPreference] = []

    struct BridgedPreference {
        var key: AnyPreferenceKey.Type
        var combiner: OGWeakAttribute
    }

    init() {
        viewGraph = GraphHost.currentHost as! ViewGraph
    }

    func addValue(_ value: OGAttribute, for keyType: AnyPreferenceKey.Type) {
        struct AddValue: PreferenceKeyVisitor {
            var combiner: OGAttribute
            var value: OGAttribute
            func visit<Key: PreferenceKey>(key _: Key.Type) {
                combiner.mutateBody(
                    as: PreferenceCombiner<Key>.self,
                    invalidating: true
                ) { combiner in
                    combiner.attributes.append(WeakAttribute(base: OGWeakAttribute(value)))
                }
            }
        }
        guard let bridgedPreference = bridgedPreferences.first(where: { $0.key == keyType }) else {
            return
        }
        guard let combiner = bridgedPreference.combiner.attribute else {
            return
        }
        var visitor = AddValue(combiner: combiner, value: value)
        keyType.visitKey(&visitor)
        viewGraph.graphInvalidation(from: value)
    }

    func removeValue(_ value: OGAttribute, for keyType: AnyPreferenceKey.Type, isInvalidating: Bool) {
        struct RemoveValue: PreferenceKeyVisitor {
            var combiner: OGAttribute
            var value: OGAttribute
            var changed = false
            mutating func visit<Key: PreferenceKey>(key _: Key.Type) {
                combiner.mutateBody(
                    as: PreferenceCombiner<Key>.self,
                    invalidating: true
                ) { combiner in
                    guard let index = combiner.attributes.firstIndex(where: { $0.attribute?.identifier == value }) else {
                        return
                    }
                    combiner.attributes.remove(at: index)
                    changed = true
                }
            }
        }
        guard let bridgedPreference = bridgedPreferences.first(where: { $0.key == keyType }) else {
            return
        }
        guard let combiner = bridgedPreference.combiner.attribute else {
            return
        }
        var visitor = RemoveValue(combiner: combiner, value: value)
        keyType.visitKey(&visitor)
        if visitor.changed {
            viewGraph.graphInvalidation(from: isInvalidating ? nil : value)
        }
    }

    func addHostValue(_ values: Attribute<PreferenceList>, for keys: Attribute<PreferenceKeys>) {
        guard let combiner = $hostPreferencesCombiner else {
            return
        }
        combiner.mutateBody(
            as: HostPreferencesCombiner.self,
            invalidating: true
        ) { combiner in
            combiner.addChild(keys: keys, values: values)
        }
    }

    func removeHostValue(for keys: Attribute<PreferenceKeys>, isInvalidating: Bool) {
        guard let combiner = $hostPreferencesCombiner else {
            return
        }
        var hasRemoved = false
        combiner.mutateBody(
            as: HostPreferencesCombiner.self,
            invalidating: true
        ) { combiner in
            guard let index = combiner.children.firstIndex(where: { $0.$keys == keys }) else {
                hasRemoved = false
                return
            }
            combiner.children.remove(at: index)
            hasRemoved = true
        }
        if hasRemoved {
            viewGraph.graphInvalidation(from: isInvalidating ? nil : keys.identifier)
        }
    }

    /// Append `child` to `children` property if `child` has not been on `children`.
    /// - Parameter child: The ``ViewGraph`` instance to be added
    func addChild(_ child: ViewGraph) {
        guard !children.contains(where: { $0.takeUnretainedValue() === child }) else {
            return
        }
        children.append(.passUnretained(child))
    }

    /// Remove `child` from `children` property if `child` has been on `children`
    /// - Parameter child: The ``ViewGraph`` instance to be removed
    func removeChild(_ child: ViewGraph) {
        guard let index = children.firstIndex(where: { $0.takeUnretainedValue() === child }) else {
            return
        }
        children.remove(at: index)
    }

    func removedStateDidChange() {
        for child in children {
            let viewGraph = child.takeUnretainedValue()
            viewGraph.updateRemovedState()
        }
    }

    func invalidate() {
        requestedPreferences = PreferenceKeys()
        bridgedViewInputs = PropertyList()
        for child in children {
            let viewGraph = child.takeRetainedValue()
            viewGraph.preferenceBridge = nil
            child.release()
        }
    }

    func wrapInputs(_ inputs: inout _ViewInputs) {
        inputs.base.customInputs = bridgedViewInputs
        inputs.preferences.merge(requestedPreferences)
        inputs.preferences.hostKeys = Attribute(MergePreferenceKeys(lhs: inputs.preferences.hostKeys, rhs: _hostPreferenceKeys))
    }

    func wrapOutputs(_ outputs: inout PreferencesOutputs, inputs: _ViewInputs) {
        struct MakeCombiner: PreferenceKeyVisitor {
            var result: OGAttribute?

            mutating func visit<Key>(key _: Key.Type) where Key: PreferenceKey {
                result = Attribute(PreferenceCombiner<Key>(attributes: [])).identifier
            }
        }
        bridgedViewInputs = inputs.base.customInputs
        for key in inputs.preferences.keys {
            if key == _AnyPreferenceKey<HostPreferencesKey>.self {
                let combiner = Attribute(HostPreferencesCombiner(
                    keys: inputs.preferences.hostKeys,
                    values: OptionalAttribute(base: AnyOptionalAttribute(outputs[anyKey: key])),
                    children: []
                ))
                outputs[anyKey: key] = combiner.identifier
                $hostPreferenceKeys = inputs.preferences.hostKeys
                $hostPreferencesCombiner = combiner
            } else {
                guard !outputs.contains(key) else {
                    continue
                }
                var visitor = MakeCombiner()
                key.visitKey(&visitor)
                guard let combiner = visitor.result else {
                    continue
                }
                if !requestedPreferences.contains(key) {
                    requestedPreferences.add(key)
                }
                bridgedPreferences.append(BridgedPreference(key: key, combiner: OGWeakAttribute(combiner)))
                outputs[anyKey: key] = combiner
            }
        }
    }
}

private struct MergePreferenceKeys: Rule, AsyncAttribute {
    @Attribute var lhs: PreferenceKeys
    @WeakAttribute var rhs: PreferenceKeys?

    var value: PreferenceKeys {
        var result = lhs
        guard let rhs else {
            return result
        }
        result.merge(rhs)
        return result
    }
}
