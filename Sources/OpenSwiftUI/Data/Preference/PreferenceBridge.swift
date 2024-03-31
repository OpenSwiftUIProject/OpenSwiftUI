//
//  PreferenceBridge.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: A9FAE381E99529D5274BA37A9BC9B074

internal import OpenGraphShims

class PreferenceBridge {
    unowned let viewGraph: ViewGraph
    private var children: [Unmanaged<ViewGraph>] = []
    var requestedPreferences: PreferenceKeys = PreferenceKeys()
    var bridgedViewInputs: PropertyList = PropertyList()
    @WeakAttribute var hostPreferenceKeys: PreferenceKeys?
    @WeakAttribute var hostPreferencesCombiner: PreferenceList?
    private var bridgedPreferences: [PreferenceBridge.BridgedPreference] = []
    
    init() {
        viewGraph = GraphHost.currentHost as! ViewGraph
    }
    
    func addValue(_ value: OGAttribute, for keyType: AnyPreferenceKey.Type) {
        struct AddValue: PreferenceKeyVisitor {
            var combiner: OGAttribute
            var value: OGAttribute
            func visit<Key: PreferenceKey>(key: Key.Type) {
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
    
    func addHostValue(_ value: Attribute<PreferenceList>, for: Attribute<PreferenceKeys>) {
        
    }
    
    func addChild(_ child: ViewGraph) {
        
    }
    
    func removeValue(_ value: OGAttribute, for keyType: AnyPreferenceKey.Type, isInvalidating: Bool) {
        struct RemoveValue: PreferenceKeyVisitor {
            var combiner: OGAttribute
            var value: OGAttribute
            var changed = false
            mutating func visit<Key: PreferenceKey>(key: Key.Type) {
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
    
//    func removeHostValue
//    func removeChild
    
    func removedStateDidChange() {
        for child in children {
            child.takeUnretainedValue().updateRemovedState()
        }
    }
    
    func invalidate() {
        requestedPreferences = PreferenceKeys()
        bridgedViewInputs = PropertyList()
        for child in children {
            child.takeRetainedValue().preferenceBridge = nil
            child.release()
        }
    }
    
    func wrapInputs(_ inputs: inout _ViewInputs) {
        inputs.base.customInputs = bridgedViewInputs
        requestedPreferences.merge(inputs.preferences.keys) // Blocked by PreferenceInputs
        // WIP
//        requestedPreferences
        // TODO
    }
    
    func wrapOutputs(_ outputs: inout PreferencesOutputs, inputs: _ViewInputs) {
        struct MakeCombiner: PreferenceKeyVisitor {
            var result: OGAttribute?
            
            func visit<Key>(key: Key.Type) where Key : PreferenceKey {
                // TODO
            }
        }
        // TODO
    }
}

extension PreferenceBridge {
    struct BridgedPreference {
        var key: AnyPreferenceKey.Type
        var combiner: OGWeakAttribute
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

struct PreferenceCombiner<Key: PreferenceKey> {
    var attributes: [WeakAttribute<Key.Value>]
}
