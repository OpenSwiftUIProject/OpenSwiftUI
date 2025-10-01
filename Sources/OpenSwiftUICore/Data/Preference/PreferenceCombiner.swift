//
//  PreferenceCombiner.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete
//  ID: 59D15989E597719355BF0EAE6CB41FF9 (SwiftUI)
//  ID: EAF68AEE5E08E2f44FEB886FE6A27001 (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - PreferenceCombiner

package struct PreferenceCombiner<K>: Rule, AsyncAttribute, CustomStringConvertible where K: PreferenceKey {
    package var attributes: [WeakAttribute<K.Value>]

    package init() {
        attributes = []
    }
    
    package init(attributes: [Attribute<K.Value>]) {
        self.attributes = attributes.map { WeakAttribute($0) }
    }
    
    package static var initialValue: K.Value? {
        K.defaultValue
    }
    
    package var value: K.Value {
        var value = K.defaultValue
        var initialValue = true
        for attribute in attributes {
            if initialValue {
                value = attribute.value ?? K.defaultValue
            } else {
                K.reduce(value: &value) {
                    attribute.value ?? K.defaultValue
                }
            }
            initialValue = false
        }
        return value
    }
    
    package var description: String {
        "∪ \(K.readableName)"
    }
}

// MARK: - PairwisePreferenceCombinerVisitor

package struct PairwisePreferenceCombinerVisitor: PreferenceKeyVisitor {
    package let outputs: (_ViewOutputs, _ViewOutputs)

    package var result: _ViewOutputs = _ViewOutputs()

    package init(outputs: (_ViewOutputs, _ViewOutputs)) {
        self.outputs = outputs
    }
    
    package mutating func visit<K>(key: K.Type) where K: PreferenceKey {
        let values = (outputs.0[key], outputs.1[key])
        if let first = values.0, let second = values.1 {
            result[key] = Attribute(PairPreferenceCombiner<K>(attributes: (first, second)))
        } else if let value = values.0 {
            result[key] = value
        } else if let value = values.1 {
            result[key] = value
        }
    }
}

// MARK: - MultiPreferenceCombinerVisitor

package struct MultiPreferenceCombinerVisitor: PreferenceKeyVisitor {
    package let outputs: [PreferencesOutputs]
    package var result: PreferencesOutputs

    init(outputs: [PreferencesOutputs], result: PreferencesOutputs) {
        self.outputs = outputs
        self.result = result
    }
    
    package mutating func visit<K>(key: K.Type) where K: PreferenceKey {
        let values = outputs.compactMap { $0[K.self] }
        switch values.count {
        case 0: break
        case 1: result[key] = values[0]
        case 2: result[key] = Attribute(PairPreferenceCombiner<K>(attributes: (values[0], values[1])))
        default: result[key] = Attribute(PreferenceCombiner<K>(attributes: values))
        }
    }
}

// MARK: - PairPreferenceCombiner

private struct PairPreferenceCombiner<K>: Rule, AsyncAttribute where K: PreferenceKey{
    private var attributes: (Attribute<K.Value>, Attribute<K.Value>)

    init(attributes: (Attribute<K.Value>, Attribute<K.Value>)) {
        self.attributes = attributes
    }

    var value: K.Value {
        var value = attributes.0.value
        K.reduce(value: &value) { attributes.1.value }
        return value
    }
}

// MARK: - PreferencesAggregator

package struct PreferencesAggregator<K>: Rule, AsyncAttribute where K: PreferenceKey {
    package var attributes: [WeakAttribute<K.Value>]

    package init(attributes: [Attribute<K.Value>]) {
        self.attributes = attributes.map { WeakAttribute($0) }
    }
    
    package var value: [K.Value] {
        attributes.map { $0.value ?? K.defaultValue }
    }
}

// MARK: - HostPreferencesCombiner

package struct HostPreferencesCombiner: Rule, AsyncAttribute {
    @Attribute var keys: PreferenceKeys
    @OptionalAttribute var values: PreferenceList?
    var children: [Child]

    package init(keys: Attribute<PreferenceKeys>, values: Attribute<PreferenceList>?) {
        _keys = keys
        _values = OptionalAttribute(values)
        children = []
    }
    
    struct Child {
        @WeakAttribute var keys: PreferenceKeys?
        @WeakAttribute var values: PreferenceList?
    }

    package mutating func addChild(keys: Attribute<PreferenceKeys>, values: WeakAttribute<PreferenceList>) {
        let child = Child(keys: WeakAttribute(keys), values: values)
        if let index = children.firstIndex(where: { $0.$keys == keys }) {
            children[index] = child
        } else {
            children.append(child)
        }
    }
    
    package mutating func removeChild(keys: Attribute<PreferenceKeys>) -> Bool {
        guard let index = children.firstIndex(where: { $0.$keys == keys }) else {
            return false
        }
        children.remove(at: index)
        return true
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
                      let listValue = values.value.valueIfPresent(for: key) else {
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

    package var value: PreferenceList {
        let values = values ?? PreferenceList()
        guard !children.isEmpty else {
            return values
        }
        var visitor = CombineValues(children: children, values: values)
        let keys = keys
        guard !keys.isEmpty else {
            return values
        }
        keys.forEach { $0.visitKey(&visitor) }
        return visitor.values
    }
}
