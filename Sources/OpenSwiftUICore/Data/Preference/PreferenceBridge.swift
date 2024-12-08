//
//  PreferenceBridge.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: A9FAE381E99529D5274BA37A9BC9B074 (SwiftUI)
//  ID: DF57A19C61B44C613EB77C1D47FC679A (SwiftUICore)

package import OpenGraphShims

package final class PreferenceBridge {
    package weak var viewGraph: ViewGraph?
    private var isValid: Bool = true
    private var children: [Unmanaged<ViewGraph>] = []
    var requestedPreferences = PreferenceKeys()
    var bridgedViewInputs = PropertyList()
    @WeakAttribute private var hostPreferenceKeys: PreferenceKeys?
    @WeakAttribute private var hostPreferencesCombiner: PreferenceList?
    private var bridgedPreferences: [BridgedPreference] = []

    struct BridgedPreference {
        var key: AnyPreferenceKey.Type
        var combiner: AnyWeakAttribute
    }

    package init() {
        viewGraph = ViewGraph.current
    }
    
    package func invalidate() {
        requestedPreferences = PreferenceKeys()
        bridgedViewInputs = PropertyList()
        for child in children {
            let viewGraph = child.takeRetainedValue()
            viewGraph.invalidatePreferenceBridge()
            child.release()
        }
        viewGraph = nil
        isValid = false
    }
    
    deinit {
        if isValid { invalidate() }
    }
    
    package func wrapInputs(_ inputs: inout _ViewInputs) {
        #if canImport(Darwin)
        inputs.customInputs = bridgedViewInputs
        for key in requestedPreferences {
            inputs.preferences.keys.add(key)
        }
        inputs.preferences.hostKeys = Attribute(MergePreferenceKeys(lhs: inputs.preferences.hostKeys, rhs: _hostPreferenceKeys))
        #endif
    }
    
    package func wrapOutputs(_ outputs: inout PreferencesOutputs, inputs: _ViewInputs) {
        #if canImport(Darwin)
        bridgedViewInputs = inputs.customInputs
        for key in inputs.preferences.keys {
            if key == _AnyPreferenceKey<HostPreferencesKey>.self {
                let combiner = Attribute(
                    HostPreferencesCombiner(
                        keys: inputs.preferences.hostKeys,
                        values: Attribute(identifier: outputs[anyKey: _AnyPreferenceKey<HostPreferencesKey>.self] ?? .nil)
                    )
                )
                outputs[anyKey: key] = combiner.identifier
                _hostPreferenceKeys = WeakAttribute(inputs.preferences.hostKeys)
                _hostPreferencesCombiner = WeakAttribute(combiner)
            } else {
                struct MakeCombiner: PreferenceKeyVisitor {
                    var result: AnyAttribute?
                    
                    mutating func visit<K>(key: K.Type) where K : PreferenceKey {
                        let combiner = PreferenceCombiner<K>(attributes: [])
                        result = Attribute(combiner).identifier
                    }
                }
                guard outputs[anyKey: key] == nil else {
                    break
                }
                var combiner = MakeCombiner()
                key.visitKey(&combiner)
                guard let result = combiner.result else {
                    break
                }
                requestedPreferences.add(key)
                bridgedPreferences.append(BridgedPreference(key: key, combiner: AnyWeakAttribute(result)))
                outputs[anyKey: key] = result
            }
        }
        #endif
        
    }
    
    package func addChild(_ child: ViewGraph) {
        guard !children.contains(where: { $0.takeUnretainedValue() === child }) else {
            return
        }
        children.append(Unmanaged.passUnretained(child))
    }
    
    package func removeChild(_ child: ViewGraph) {
        guard let index = children.firstIndex(where: { $0.takeUnretainedValue() === child }) else {
            return
        }
        children.remove(at: index)
    }
    
    package func removedStateDidChange() {
        for child in children {
            let viewGraph = child.takeUnretainedValue()
            viewGraph.updateRemovedState()
            child.release()
        }
    }
    
    #if canImport(Darwin)
    package func addValue(_ src: AnyAttribute, for key: any AnyPreferenceKey.Type) {
        struct AddValue: PreferenceKeyVisitor {
            var combiner: AnyAttribute
            var value: AnyAttribute
            func visit<Key: PreferenceKey>(key _: Key.Type) {
                combiner.mutateBody(
                    as: PreferenceCombiner<Key>.self,
                    invalidating: true
                ) { combiner in
                    combiner.attributes.append(WeakAttribute(base: AnyWeakAttribute(value)))
                }
            }
        }
        guard let viewGraph,
              let bridgedPreference = bridgedPreferences.first(where: { $0.key == key }),
              let combiner = bridgedPreference.combiner.attribute
        else { return }
        var visitor = AddValue(combiner: combiner, value: src)
        key.visitKey(&visitor)
        viewGraph.graphInvalidation(from: src)
    }
    
    package func removeValue(_ src: AnyAttribute, for key: any AnyPreferenceKey.Type, isInvalidating: Bool = false) {
        struct RemoveValue: PreferenceKeyVisitor {
            var combiner: AnyAttribute
            var value: AnyAttribute
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
        guard let viewGraph,
              let bridgedPreference = bridgedPreferences.first(where: { $0.key == key }),
              let combiner = bridgedPreference.combiner.attribute
        else { return }
        var visitor = RemoveValue(combiner: combiner, value: src)
        key.visitKey(&visitor)
        if visitor.changed {
            viewGraph.graphInvalidation(from: isInvalidating ? nil : src)
        }
    }
    #endif
    
    package func updateHostValues(_ keys: Attribute<PreferenceKeys>) {
        #if canImport(Darwin)
        guard let viewGraph else { return }
        viewGraph.graphInvalidation(from: keys.identifier)
        #endif
    }
    
    package func addHostValues(_ values: WeakAttribute<PreferenceList>, for keys: Attribute<PreferenceKeys>) {
        #if canImport(Darwin)
        guard let viewGraph,
              let combiner = $hostPreferencesCombiner
        else { return }
        combiner.mutateBody(
            as: HostPreferencesCombiner.self,
            invalidating: true
        ) { combiner in
            combiner.addChild(keys: keys, values: values)
        }
        viewGraph.graphInvalidation(from: keys.identifier)
        #endif
    }
    
    package func addHostValues(_ values: OptionalAttribute<PreferenceList>, for keys: Attribute<PreferenceKeys>) {
        #if canImport(Darwin)
        guard let attribute = values.attribute else {
            return
        }
        addHostValues(WeakAttribute(attribute), for: keys)
        #endif
    }
    
    package func removeHostValues(for keys: Attribute<PreferenceKeys>, isInvalidating: Bool = false) {
        #if canImport(Darwin)
        guard let viewGraph,
              let combiner = $hostPreferencesCombiner
        else { return }
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
        #endif
    }
}

// MARK: - MergePreferenceKeys

private struct MergePreferenceKeys: Rule, AsyncAttribute {
    @Attribute var lhs: PreferenceKeys
    @WeakAttribute var rhs: PreferenceKeys?

    var value: PreferenceKeys {
        var result = lhs
        guard let rhs else {
            return lhs
        }
        for key in rhs.keys {
            result.add(key)
        }
        return result
    }
}
