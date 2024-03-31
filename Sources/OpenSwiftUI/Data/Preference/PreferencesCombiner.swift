//
//  PreferencesCombiner.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: 59D15989E597719355BF0EAE6CB41FF9

internal import OpenGraphShims

struct HostPreferencesCombiner: Rule, AsyncAttribute {
    @Attribute var keys: PreferenceKeys
    @OptionalAttribute var values: PreferenceList?
    var children: [Child]
    
    struct Child {
        @WeakAttribute var keys: PreferenceKeys?
        @WeakAttribute var values: PreferenceList?
    }
    
    mutating func addChild(keys: Attribute<PreferenceKeys>, values: Attribute<PreferenceList>) {
        let weakKeys = OGWeakAttribute(keys.identifier)
        let weakValues = OGWeakAttribute(values.identifier)
        let child = Child(keys: .init(base: weakKeys), values: .init(base: weakValues))
        if let index = children.firstIndex(where: { $0.$keys == keys }) {
            children[index] = child
        } else {
            children.append(child)
        }
    }
    
    private struct CombineValues: PreferenceKeyVisitor {
        var children: [Child]
        var values: PreferenceList
        
        mutating func visit<Key: PreferenceKey>(key: Key.Type) {
            guard !values.contains(key) else {
                return
            }
            var value = Key.defaultValue
            var seed = VersionSeed.empty
            guard !children.isEmpty else {
                return
            }            
            var initialValue = true
            for child in children {
                guard let keys = child.$keys,
                      !keys.value.contains(key) else {
                    continue
                }
                guard let values = child.$values,
                      let listValue = values.value.valueIfPresent(key) else {
                    continue
                }
                if initialValue {
                    value = listValue.value
                    seed = listValue.seed
                } else {
                    Key.reduce(value: &value) {
                        seed.merge(listValue.seed)
                        return listValue.value
                    }
                }
                initialValue = false
            }
            if !initialValue {
                values[key] = PreferenceList.Value(value: value, seed: seed)
            }
        }
    }
    
    var value: PreferenceList {
        let values = values ?? PreferenceList()
        guard !children.isEmpty else {
            return values
        }
        var visitor = CombineValues(children: children, values: values)
        let keys = keys
        for key in keys {
            key.visitKey(&visitor)
        }
        return visitor.values
    }
}
