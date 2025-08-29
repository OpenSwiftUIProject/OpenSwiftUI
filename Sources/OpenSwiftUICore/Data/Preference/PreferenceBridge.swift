//
//  PreferenceBridge.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: A9FAE381E99529D5274BA37A9BC9B074 (SwiftUI)
//  ID: DF57A19C61B44C613EB77C1D47FC679A (SwiftUICore)

package import OpenAttributeGraphShims

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
        var key: any PreferenceKey.Type
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
        inputs.customInputs = bridgedViewInputs
        for key in requestedPreferences {
            inputs.preferences.keys.add(key)
        }
        inputs.preferences.hostKeys = Attribute(MergePreferenceKeys(lhs: inputs.preferences.hostKeys, rhs: _hostPreferenceKeys))
    }
    
    package func wrapOutputs(_ outputs: inout PreferencesOutputs, inputs: _ViewInputs) {
        bridgedViewInputs = inputs.customInputs
        for key in inputs.preferences.keys {
            if key == HostPreferencesKey.self {
                let combiner = Attribute(
                    HostPreferencesCombiner(
                        keys: inputs.preferences.hostKeys,
                        values: outputs[HostPreferencesKey.self]
                    )
                )
                outputs[HostPreferencesKey.self] = combiner
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
    
    package func addValue(_ src: AnyAttribute, for key: any PreferenceKey.Type) {
        guard let viewGraph,
              let bridgedPreference = bridgedPreferences.first(where: { $0.key == key }),
              let combiner = bridgedPreference.combiner.attribute
        else { return }
        func project<K>(_ key: K.Type) where K: PreferenceKey {
            combiner.mutateBody(
                as: PreferenceCombiner<K>.self,
                invalidating: true
            ) { combiner in
                combiner.attributes.append(WeakAttribute(base: AnyWeakAttribute(src)))
            }
        }
        project(key)
        viewGraph.graphInvalidation(from: src)
    }
    
    package func removeValue(_ src: AnyAttribute, for key: any PreferenceKey.Type, isInvalidating: Bool = false) {
        guard let viewGraph,
              let bridgedPreference = bridgedPreferences.first(where: { $0.key == key }),
              let combiner = bridgedPreference.combiner.attribute
        else { return }
        var changed = false
        func project<K>(_ key: K.Type) where K: PreferenceKey {
            combiner.mutateBody(
                as: PreferenceCombiner<K>.self,
                invalidating: true
            ) { combiner in
                guard let index = combiner.attributes.firstIndex(where: { $0.attribute?.identifier == src }) else {
                    return
                }
                combiner.attributes.remove(at: index)
                changed = true
            }
        }
        project(key)
        if changed {
            viewGraph.graphInvalidation(from: isInvalidating ? nil : src)
        }
    }

    package func updateHostValues(_ keys: Attribute<PreferenceKeys>) {
        guard let viewGraph else { return }
        viewGraph.graphInvalidation(from: keys.identifier)
    }
    
    package func addHostValues(_ values: WeakAttribute<PreferenceList>, for keys: Attribute<PreferenceKeys>) {
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
    }
    
    package func addHostValues(_ values: OptionalAttribute<PreferenceList>, for keys: Attribute<PreferenceKeys>) {
        guard let attribute = values.attribute else {
            return
        }
        addHostValues(WeakAttribute(attribute), for: keys)
    }
    
    package func removeHostValues(for keys: Attribute<PreferenceKeys>, isInvalidating: Bool = false) {
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
