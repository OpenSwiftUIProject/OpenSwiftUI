//
//  ViewTrait.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 9929B476764059557433A108298EE66F (SwiftUI)
//  ID: 48526BA25CDCBF890FA91D018A5421B4 (SwiftUICore)

import OpenGraphShims

// MARK: - ViewTraitKey

/// A type of key for a trait associated with the content of a
/// container view.
@available(OpenSwiftUI_v1_0, *)
public protocol _ViewTraitKey {
    /// The type of value produced by the trait.
    associatedtype Value
    
    /// The default value of the trait.
    static var defaultValue: Value { get }
}

// MARK: - _TraitWritingModifier

/// A view content adapter that associates a trait with its base content.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _TraitWritingModifier<Trait>: PrimitiveViewModifier where Trait: _ViewTraitKey {
    public let value: Trait.Value

    @inlinable
    public init(value: Trait.Value) {
        self.value = value
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        if Trait.self == LayoutPriorityTraitKey.self {
            LayoutPriorityLayout.makeViewImpl(
                modifier: modifier.unsafeCast(),
                inputs: inputs,
                body: body
            )
        } else {
            body(_Graph(), inputs)
        }
    }

    nonisolated public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        var inputs = inputs
        if Trait.self == LayoutPriorityTraitKey.self,
           !inputs.options.contains(.layoutPriorityIsTrait) {
            let attribute = modifier.value.unsafeBitCast(to: _TraitWritingModifier<LayoutPriorityTraitKey>.self)
            var outputs = body(_Graph(), inputs)
            outputs.multiModifier(_GraphValue(attribute), inputs: inputs)
            return outputs
        } else {
            let addTrait = AddTrait(modifier: modifier.value, traits: OptionalAttribute(inputs.traits))
            let attribute = Attribute(addTrait)
            inputs.addTraitKey(Trait.self)
            inputs.traits = attribute
            return body(_Graph(), inputs)
        }
    }

    private struct AddTrait: Rule {
        @Attribute var modifier: _TraitWritingModifier
        @OptionalAttribute var traits: ViewTraitCollection?

        var value: ViewTraitCollection {
            var traits = traits ?? ViewTraitCollection()
            traits[Trait.self] = modifier.value
            return traits
        }
    }
}

@available(*, unavailable)
extension _TraitWritingModifier: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Associate a trait `value` for the given `key` for this view content.
    @inlinable
    nonisolated public func _trait<K>(_ key: K.Type, _ value: K.Value) -> some View where K: _ViewTraitKey {
        modifier(_TraitWritingModifier<K>(value: value))
    }
}

// MARK: - _ConditionalTraitWritingModifier

/// Conditionally writes a trait.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _ConditionalTraitWritingModifier<Trait>: PrimitiveViewModifier where Trait : _ViewTraitKey {
    public var value: Trait.Value

    public var isEnabled: Bool
    
    @_alwaysEmitIntoClient
    public init(traitKey: Trait.Type = Trait.self, value: Trait.Value, isEnabled: Bool) {
        self.value = value
        self.isEnabled = isEnabled
    }
     
    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        _TraitWritingModifier<Trait>._makeView(
            modifier: _GraphValue(Attribute(identifier: AnyAttribute.nil)),
            inputs: inputs,
            body: body
        )
    }

    nonisolated public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        var inputs = inputs
        if Trait.self == LayoutPriorityTraitKey.self,
           !inputs.options.contains(.layoutPriorityIsTrait) {
            let attribute = modifier.value.unsafeBitCast(to: _TraitWritingModifier<LayoutPriorityTraitKey>.self)
            var outputs = body(_Graph(), inputs)
            outputs.multiModifier(_GraphValue(attribute), inputs: inputs)
            return outputs
        } else {
            let addTrait = ConditionalAddTrait(modifier: modifier.value, traits: OptionalAttribute(inputs.traits))
            let attribute = Attribute(addTrait)
            inputs.addTraitKey(Trait.self)
            inputs.traits = attribute
            return body(_Graph(), inputs)
        }
    }

    private struct ConditionalAddTrait: Rule {
        @Attribute var modifier: _ConditionalTraitWritingModifier
        @OptionalAttribute var traits: ViewTraitCollection?

        var value: ViewTraitCollection {
            var traits = traits ?? ViewTraitCollection()
            if modifier.isEnabled {
                traits[Trait.self] = modifier.value
            }
            return traits
        }
    }
}

@available(*, unavailable)
extension _ConditionalTraitWritingModifier: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Conditionally writes a trait.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public func _trait<K>(_ key: K.Type = K.self, _ value: K.Value, isEnabled: Bool) -> some View where K: _ViewTraitKey {
        modifier(_ConditionalTraitWritingModifier<K>(
            value: value,
            isEnabled: isEnabled
        ))
    }
}

// MARK: - TraitTransformerModifier

struct TraitTransformerModifier<Trait>: PrimitiveViewModifier where Trait: _ViewTraitKey {
    var transform: (inout Trait.Value) -> Void

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        body(_Graph(), inputs)
    }

    nonisolated public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        var inputs = inputs
        let trait = TransformTrait(modifier: modifier.value, traits: OptionalAttribute(inputs.traits))
        let attribute = Attribute(trait)
        inputs.traits = attribute
        return body(_Graph(), inputs)
    }

    private struct TransformTrait: Rule {
        @Attribute var modifier: TraitTransformerModifier
        @OptionalAttribute var traits: ViewTraitCollection?

        var value: ViewTraitCollection {
            var traits = traits ?? ViewTraitCollection()
            let transform = modifier.transform
            var value = traits.value(for: Trait.self)
            transform(&value)
            traits[Trait.self] = value
            return traits
        }
    }
}

extension View {
    package func transformTrait<K>(_ key: K.Type = K.self, transform: @escaping (inout K.Value) -> Void) -> some View where K: _ViewTraitKey {
        modifier(TraitTransformerModifier<K>(transform: transform))
    }
}

// MARK: - ViewTraitCollection

private protocol AnyViewTrait {
    var id: ObjectIdentifier { get }
    subscript<V>() -> V { get set }
}

package struct ViewTraitCollection {
    package init() {
        self.storage = []
    }
    
    package func contains<Trait>(_ key: Trait.Type) -> Bool where Trait: _ViewTraitKey {
        storage.contains { $0.id == ObjectIdentifier(key) }
    }
    
    package func value<Trait>(for key: Trait.Type, defaultValue: Trait.Value) -> Trait.Value where Trait: _ViewTraitKey {
        storage.first { $0.id == ObjectIdentifier(key) }?[] ?? defaultValue
    }
    
    package func value<Trait>(for key: Trait.Type) -> Trait.Value where Trait: _ViewTraitKey {
        value(for: key, defaultValue: key.defaultValue)
    }
        
    package mutating func setValueIfUnset<Trait>(_ value: Trait.Value, for key: Trait.Type) where Trait: _ViewTraitKey {
        guard !storage.contains(where: { $0.id == ObjectIdentifier(key) }) else {
            return
        }
        storage.append(AnyTrait<Trait>(value: value))
    }
    
    package subscript<Trait>(key: Trait.Type) -> Trait.Value where Trait : _ViewTraitKey {
        get {
            value(for: key)
        }
        set {
            if let index = storage.firstIndex(where: { $0.id == ObjectIdentifier(key) }) {
                storage[index][] = newValue
            } else {
                storage.append(AnyTrait<Trait>(value: newValue))
            }
        }
    }
    
    package mutating func mergeValues(_ traits: ViewTraitCollection) {
        for trait in traits.storage {
            setErasedValue(trait: trait)
        }
    }
    
    private mutating func setErasedValue<ViewTrait>(trait: ViewTrait) where ViewTrait: AnyViewTrait {
        if let index = storage.firstIndex(where: { $0.id == trait.id }) {
            let value: Any = trait[]
            storage[index][] = value
        } else {
            storage.append(trait)
        }
    }
    
    private var storage: [any AnyViewTrait]
    
    private struct AnyTrait<Trait>: AnyViewTrait where Trait: _ViewTraitKey {
        typealias Value = Trait.Value
        
        var value: Value
        
        init(value: Trait.Value) {
            self.value = value
        }
        
        var id: ObjectIdentifier { ObjectIdentifier(Trait.self) }
        
        subscript<V>() -> V {
            get { value as! V }
            set { value = newValue as! Value }
        }
    }
}

// MARK: - ViewTraitKeys

package struct ViewTraitKeys {
    package var types: Set<ObjectIdentifier>
    package var isDataDependent: Bool
    
    package init() {
        types = []
        isDataDependent = false
    }
    
    package func contains<T>(_ type: T.Type) -> Bool where T: _ViewTraitKey{
        types.contains(ObjectIdentifier(type))
    }
    
    package mutating func insert<T>(_ type: T.Type) where T: _ViewTraitKey {
        types.insert(ObjectIdentifier(type))
    }
    
    package mutating func formUnion(_ other: ViewTraitKeys) {
        types.formUnion(other.types)
        isDataDependent = isDataDependent || other.isDataDependent
    }

    package func withDataDependent() -> ViewTraitKeys {
        var copy = self
        copy.isDataDependent = true
        return copy
    }
}
