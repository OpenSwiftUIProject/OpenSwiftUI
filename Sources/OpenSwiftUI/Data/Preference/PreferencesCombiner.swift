//
//  PreferencesCombiner.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete
//  ID: 59D15989E597719355BF0EAE6CB41FF9

internal import OpenGraphShims

struct PreferenceCombiner<Key: PreferenceKey>: Rule, AsyncAttribute {
    var attributes: [WeakAttribute<Key.Value>]

    init(attributes: [Attribute<Key.Value>]) {
        self.attributes = attributes.map { WeakAttribute($0) }
    }

    var value: Key.Value {
        var value = Key.defaultValue
        var initialValue = true
        for attribute in attributes {
            if initialValue {
                value = attribute.value ?? Key.defaultValue
            } else {
                Key.reduce(value: &value) {
                    attribute.value ?? Key.defaultValue
                }
            }
            initialValue = false
        }
        return value
    }
}

struct HostPreferencesCombiner: Rule, AsyncAttribute {
    @Attribute var keys: PreferenceKeys
    @OptionalAttribute var values: PreferenceList?
    var children: [Child]

    struct Child {
        @WeakAttribute var keys: PreferenceKeys?
        @WeakAttribute var values: PreferenceList?

        init(keys: Attribute<PreferenceKeys>, values: Attribute<PreferenceList>) {
            _keys = WeakAttribute(keys)
            _values = WeakAttribute(values)
        }
    }

    #if canImport(Darwin) // FIXME: See #39
    mutating func addChild(keys: Attribute<PreferenceKeys>, values: Attribute<PreferenceList>) {
        let child = Child(keys: keys, values: values)
        if let index = children.firstIndex(where: { $0.$keys == keys }) {
            children[index] = child
        } else {
            children.append(child)
        }
    }
    #endif

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

private struct PairPreferenceCombiner<Key: PreferenceKey>: Rule, AsyncAttribute {
    private var attributes: (Attribute<Key.Value>, Attribute<Key.Value>)

    init(attributes: (Attribute<Key.Value>, Attribute<Key.Value>)) {
        self.attributes = attributes
    }

    var value: Key.Value {
        var value = attributes.0.value
        Key.reduce(value: &value) { attributes.1.value }
        return value
    }
}

struct PairwisePreferenceCombinerVisitor: PreferenceKeyVisitor {
    let outputs: (_ViewOutputs, _ViewOutputs)
    var result: _ViewOutputs

    mutating func visit<Key: PreferenceKey>(key _: Key.Type) {
        let values = (outputs.0[Key.self], outputs.1[Key.self])

        if let value1 = values.0, let value2 = values.1 {
            result[Key.self] = Attribute(PairPreferenceCombiner<Key>(attributes: (value1, value2)))
        } else if let value = values.0 {
            result[Key.self] = value
        } else if let value = values.1 {
            result[Key.self] = value
        }
    }
}

struct MultiPreferenceCombinerVisitor: PreferenceKeyVisitor {
    let outputs: [PreferencesOutputs]
    var result: PreferencesOutputs

    mutating func visit<Key: PreferenceKey>(key _: Key.Type) {
        let values = outputs.compactMap { $0[Key.self] }
        switch values.count {
        case 0: break
        case 1: result[Key.self] = values[0]
        case 2: result[Key.self] = Attribute(PairPreferenceCombiner<Key>(attributes: (values[0], values[1])))
        default: result[Key.self] = Attribute(PreferenceCombiner<Key>(attributes: values))
        }
    }
}
