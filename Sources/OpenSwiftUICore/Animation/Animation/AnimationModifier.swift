//
//  AnimationModifier.swift
//  OpenSwiftUICore
//
//  Audited: 6.5.4
//  Status: Complete
//  ID: 530459AF10BEFD7ED901D8CE93C1E289 (SwiftUICore)

import OpenAttributeGraphShims
import OpenCoreGraphicsShims

// MARK: - _AnimationModifier

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _AnimationModifier<Value>: ViewModifier, PrimitiveViewModifier where Value: Equatable {
    public var animation: Animation?

    public var value: Value

    @inlinable
    public init(animation: Animation?, value: Value) {
        self.animation = animation
        self.value = value
    }

    nonisolated static func _makeInputs(
        modifier: _GraphValue<Self>,
        inputs: inout _GraphInputs
    ) {
        let transactionSeed = GraphHost.currentHost.data.$transactionSeed
        let seed  = Attribute(
            ValueTransactionSeed(
                value: modifier.value[offset: { .of(&$0.value) }],
                transactionSeed: transactionSeed
            )
        )
        seed.flags = .transactional
        inputs.transaction = Attribute(
            ChildTransaction(
                valueTransactionSeed: seed,
                animation: modifier.value[offset: { .of(&$0.animation) }],
                transaction: inputs.transaction,
                transactionSeed: transactionSeed
            )
        )
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let archivedView = inputs.archivedView
        if archivedView.isArchived {
            return makeArchivedView(
                modifier: modifier,
                inputs: inputs,
                body: body
            )
        } else {
            var inputs = inputs
            _makeInputs(modifier: modifier, inputs: &inputs.base)
            return body(_Graph(), inputs)
        }
    }

    nonisolated public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        let archivedView = inputs.archivedView
        if archivedView.isArchived {
            return makeArchivedViewList(
                modifier: modifier,
                inputs: inputs,
                body: body
            )
        } else {
            var inputs = inputs
            _makeInputs(modifier: modifier, inputs: &inputs.base)
            return body(_Graph(), inputs)
        }
    }

    nonisolated private static func makeArchivedView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var inputs = inputs
        func project<T>(type: T.Type) -> _ViewOutputs where T: Encodable & Equatable {
            let modifier = modifier.value.unsafeBitCast(to: _AnimationModifier<T>.self)
            inputs.displayListOptions.formUnion(.disableCanonicalization)
            let effect = Attribute(
                ArchivedAnimationModifier(modifier: modifier)
            )
            return ArchivedAnimationModifier.Effect
                ._makeRendererEffect(
                    effect: .init(effect),
                    inputs: inputs,
                    body: body
                )
        }
        guard let type = Value.self as? (any (Encodable & Equatable).Type) else {
            return body(_Graph(), inputs)
        }
        return project(type: type)
    }

    nonisolated private static func makeArchivedViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        var inputs = inputs
        func project<T>(type: T.Type) where T: Encodable & Equatable {
            let modifier = modifier.value.unsafeBitCast(to: _AnimationModifier<T>.self)
            inputs.traits = Attribute(
                ArchivedAnimationTrait(
                    modifier: modifier,
                    traits: .init(inputs.traits)
                )
            )
            inputs.addTraitKey(ArchivedAnimationTraitKey.self)
        }
        if inputs.options.contains(.needsArchivedAnimationTraits),
           let type = Value.self as? (any (Encodable & Equatable).Type) {
            project(type: type)
        }
        return Self.makeMultiViewList(
            modifier: modifier,
            inputs: inputs,
            body: body
        )
    }
}

@available(*, unavailable)
extension _AnimationModifier: Sendable {}

// MARK: - _AnimationView

@available(OpenSwiftUI_v3_0, *)
@frozen
public struct _AnimationView<Content>: View, PrimitiveView where Content: Equatable, Content: View {
    public var content: Content

    public var animation: Animation?

    @inlinable
    public init(content: Content, animation: Animation?) {
        self.content = content
        self.animation = animation
    }

    nonisolated static func _makeInputs(
        view: _GraphValue<Self>,
        inputs: inout _GraphInputs
    ) -> _GraphValue<Content> {
        let value = view.value[offset: { .of(&$0.content) }]
        let transactionSeed = GraphHost.currentHost.data.$transactionSeed
        let seed = Attribute(
            ValueTransactionSeed(
                value: value,
                transactionSeed: transactionSeed
            )
        )
        seed.flags = .transactional
        inputs.transaction = Attribute(
            ChildTransaction(
                valueTransactionSeed: seed,
                animation: view.value[offset: { .of(&$0.animation) }],
                transaction: inputs.transaction,
                transactionSeed: transactionSeed
            )
        )
        return _GraphValue(value)
    }

    nonisolated public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        var inputs = inputs
        let value = _makeInputs(view: view, inputs: &inputs.base)
        return Content.makeDebuggableView(view: value, inputs: inputs)
    }

    nonisolated public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        var inputs = inputs
        let value = _makeInputs(view: view, inputs: &inputs.base)
        return Content.makeDebuggableViewList(view: value, inputs: inputs)
    }

    nonisolated public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        Content._viewListCount(inputs: inputs)
    }
}

@available(*, unavailable)
extension _AnimationView: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension _AnimationModifier: Equatable {}

@available(OpenSwiftUI_v1_0, *)
extension View {
    @inlinable
    nonisolated public func animation<V>(_ animation: Animation?, value: V) -> some View where V: Equatable {
        modifier(_AnimationModifier(animation: animation, value: value))
    }
}

@available(OpenSwiftUI_v3_0, *)
extension View where Self: Equatable {
    @available(OpenSwiftUI_v3_0, *)
    @inlinable
    nonisolated public func animation(_ animation: Animation?) -> some View {
        _AnimationView(content: self, animation: animation)
    }
}

/// A stateful rule that tracks value changes to determine when to update transactions.
///
/// This structure maintains state about a value being monitored, comparing new values
/// with the previous ones to detect changes.
struct ValueTransactionSeed<V>: StatefulRule, AsyncAttribute where V: Equatable {
    @Attribute var value: V
    @Attribute var transactionSeed: UInt32
    var oldValue: V?

    init(value: Attribute<V>, transactionSeed: Attribute<UInt32>, oldValue: V? = nil) {
        self._value = value
        self._transactionSeed = transactionSeed
        self.oldValue = oldValue
    }

    typealias Value = UInt32

    mutating func updateValue() {
        let newValue = value
        if let oldValue {
            guard oldValue != newValue else {
                return
            }
            value = Graph.withoutUpdate { transactionSeed }
        } else {
            value = .max
        }
        oldValue = newValue
    }
}

// MARK: - ArchivedAnimationModifier

private struct ArchivedAnimationModifier<Value>: Rule, AsyncAttribute where Value: Encodable, Value: Equatable {
    struct Effect: _RendererEffect {
        var animation: Animation?
        var value: StrongHash

        func effectValue(size: CGSize) -> DisplayList.Effect {
            .interpolatorAnimation(.init(value: value, animation: animation))
        }
    }

    @Attribute var modifier: _AnimationModifier<Value>

    var value: Effect {
        let value = (try? StrongHash(encodable: modifier.value)) ?? .random()
        return Effect(animation: modifier.animation, value: value)
    }
}

// MARK: - ArchivedAnimationTraitKey

struct ArchivedAnimationTraitKey: _ViewTraitKey {
    var animation: Animation?
    var hash: StrongHash

    static var defaultValue: ArchivedAnimationTraitKey? {
        nil
    }
}

extension ViewTraitCollection {
    @inline(__always)
    var archivedAnimationTrait: ArchivedAnimationTraitKey? {
        get { self[ArchivedAnimationTraitKey.self] }
        set { self[ArchivedAnimationTraitKey.self] = newValue }
    }
}

// MARK: - ArchivedAnimationTrait

private struct ArchivedAnimationTrait<Value>: Rule, AsyncAttribute where Value: Encodable, Value: Equatable {
    @Attribute var modifier: _AnimationModifier<Value>
    @OptionalAttribute var traits: ViewTraitCollection?

    var value: ViewTraitCollection {
        let value = (try? StrongHash(encodable: modifier.value)) ?? .random()
        var traits = traits ?? .init()
        traits.archivedAnimationTrait = .init(animation: modifier.animation, hash: value)
        return traits
    }
}

// MARK: - ChildTransaction

private struct ChildTransaction: Rule, AsyncAttribute {
    @Attribute var valueTransactionSeed: UInt32
    @Attribute var animation: Animation?
    @Attribute var transaction: Transaction
    @Attribute var transactionSeed: UInt32

    var value: Transaction {
        var transaction = transaction
        guard !transaction.disablesAnimations else {
            return transaction
        }
        let oldTransactionSeed = Graph.withoutUpdate { transactionSeed }
        guard valueTransactionSeed == oldTransactionSeed else {
            return transaction
        }
        transaction.animation = animation
        Swift.assert(transactionSeed == oldTransactionSeed)
        return transaction
    }
}
