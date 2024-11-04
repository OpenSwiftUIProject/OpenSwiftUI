//
//  PreferenceBridge.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: TO BE AUDITED
//  ID: A9FAE381E99529D5274BA37A9BC9B074 (SwiftUI)
//  ID: DF57A19C61B44C613EB77C1D47FC679A (SwiftUICore)

import OpenGraphShims

package final class PreferenceBridge {
    weak var viewGraph: ViewGraph?
    var isValid: Bool = true
    private(set) var children: [Unmanaged<ViewGraph>] = []
    var requestedPreferences = PreferenceKeys()
    var bridgedViewInputs = PropertyList()
    @WeakAttribute var hostPreferenceKeys: PreferenceKeys?
    @WeakAttribute var hostPreferencesCombiner: PreferenceList?
    private var bridgedPreferences: [BridgedPreference] = []

    struct BridgedPreference {
        var key: AnyPreferenceKey.Type
        var combiner: AnyWeakAttribute
    }

    init() {
        viewGraph = ViewGraph.current
    }
    
    deinit {
        if isValid { invalidate() }
    }
    
    // FIXME: TO BE AUDITED
    
    #if canImport(Darwin) // FIXME: See #39
    func addValue(_ value: AnyAttribute, for keyType: AnyPreferenceKey.Type) {
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
        guard let bridgedPreference = bridgedPreferences.first(where: { $0.key == keyType }) else {
            return
        }
        guard let combiner = bridgedPreference.combiner.attribute else {
            return
        }
        var visitor = AddValue(combiner: combiner, value: value)
        keyType.visitKey(&visitor)
        viewGraph?.graphInvalidation(from: value)
    }

    func removeValue(_ value: AnyAttribute, for keyType: AnyPreferenceKey.Type, isInvalidating: Bool) {
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
        guard let bridgedPreference = bridgedPreferences.first(where: { $0.key == keyType }) else {
            return
        }
        guard let combiner = bridgedPreference.combiner.attribute else {
            return
        }
        var visitor = RemoveValue(combiner: combiner, value: value)
        keyType.visitKey(&visitor)
        if visitor.changed {
            viewGraph?.graphInvalidation(from: isInvalidating ? nil : value)
        }
    }
    
    package func updateHostValues(_ keys: Attribute<PreferenceKeys>) {
        fatalError("TODO")
    }
    
    package func addHostValue(_ values: WeakAttribute<PreferenceList>, for keys: Attribute<PreferenceKeys>) {
        fatalError("TODO")
    }
    
    package func addHostValue(_ values: OptionalAttribute<PreferenceList>, for keys: Attribute<PreferenceKeys>) {
        fatalError("TODO")
    }

//    package func addHostValue(_ values: Attribute<PreferenceList>, for keys: Attribute<PreferenceKeys>) {
//        guard let combiner = $hostPreferencesCombiner else {
//            return
//        }
//        combiner.mutateBody(
//            as: HostPreferencesCombiner.self,
//            invalidating: true
//        ) { combiner in
//            combiner.addChild(keys: keys, values: WeakAttribute(values))
//        }
//        viewGraph?.graphInvalidation(from: combiner.identifier)
//    }

    func removeHostValue(for keys: Attribute<PreferenceKeys>, isInvalidating: Bool = false) {
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
            viewGraph?.graphInvalidation(from: isInvalidating ? nil : keys.identifier)
        }
    }
    #endif
}

private struct MergePreferenceKeys: Rule, AsyncAttribute {
    @Attribute var lhs: PreferenceKeys
    @WeakAttribute var rhs: PreferenceKeys?

    var value: PreferenceKeys {
//        var result = lhs
//        guard let rhs else {
//            return result
//        }
//        result.merge(rhs)
//        return result
        fatalError("TODO")
    }
}
