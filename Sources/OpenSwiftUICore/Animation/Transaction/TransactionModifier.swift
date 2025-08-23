//
//  TransactionModifier.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: A1B10B5AB036C34AB7DD2EE8825FCA93 (SwiftUICore)

package import OpenGraphShims

// MARK: View + transaction

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Applies the given transaction mutation function to all animations used
    /// within the view.
    ///
    /// Use this modifier to change or replace the animation used in a view.
    /// Consider three identical animations controlled by a
    /// button that executes all three animations simultaneously:
    ///
    ///  * The first animation rotates the "Rotation" ``Text`` view by 360
    ///    degrees.
    ///  * The second uses the `transaction(_:)` modifier to change the
    ///    animation by adding a delay to the start of the animation
    ///    by two seconds and then increases the rotational speed of the
    ///    "Rotation\nModified" ``Text`` view animation by a factor of 2.
    ///  * The third animation uses the `transaction(_:)` modifier to
    ///    replace the rotation animation affecting the "Animation\nReplaced"
    ///    ``Text`` view with a spring animation.
    ///
    /// The following code implements these animations:
    ///
    ///     struct TransactionExample: View {
    ///         @State private var flag = false
    ///
    ///         var body: some View {
    ///             VStack(spacing: 50) {
    ///                 HStack(spacing: 30) {
    ///                     Text("Rotation")
    ///                         .rotationEffect(Angle(degrees:
    ///                                                 self.flag ? 360 : 0))
    ///
    ///                     Text("Rotation\nModified")
    ///                         .rotationEffect(Angle(degrees:
    ///                                                 self.flag ? 360 : 0))
    ///                         .transaction { view in
    ///                             view.animation =
    ///                                 view.animation?.delay(2.0).speed(2)
    ///                         }
    ///
    ///                     Text("Animation\nReplaced")
    ///                         .rotationEffect(Angle(degrees:
    ///                                                 self.flag ? 360 : 0))
    ///                         .transaction { view in
    ///                             view.animation = .interactiveSpring(
    ///                                 response: 0.60,
    ///                                 dampingFraction: 0.20,
    ///                                 blendDuration: 0.25)
    ///                         }
    ///                 }
    ///
    ///                 Button("Animate") {
    ///                     withAnimation(.easeIn(duration: 2.0)) {
    ///                         self.flag.toggle()
    ///                     }
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// Use this modifier on leaf views such as ``Image`` or ``Button`` rather
    /// than container views such as ``VStack`` or ``HStack``. The
    /// transformation applies to all child views within this view; calling
    /// `transaction(_:)` on a container view can lead to unbounded scope of
    /// execution depending on the depth of the view hierarchy.
    ///
    /// - Parameter transform: The transformation to apply to transactions
    ///   within this view.
    ///
    /// - Returns: A view that wraps this view and applies a transformation to
    ///   all transactions used within the view.
    @inlinable
    nonisolated public func transaction(
        _ transform: @escaping (inout Transaction) -> Void
    ) -> some View {
        modifier(_TransactionModifier(transform: transform))
    }

    /// Applies the given transaction mutation function to all animations used
    /// within the view.
    ///
    /// Use this modifier to change or replace the animation used in a view.
    /// Consider three identical views controlled by a
    /// button that changes all three simultaneously:
    ///
    ///  * The first view animates rotating the "Rotation" ``Text`` view by 360
    ///    degrees.
    ///  * The second uses the `transaction(_:)` modifier to change the
    ///    animation by adding a delay to the start of the animation
    ///    by two seconds and then increases the rotational speed of the
    ///    "Rotation\nModified" ``Text`` view animation by a factor of 2.
    ///  * The third uses the `transaction(_:)` modifier to disable animations
    ///    affecting the "Animation\nReplaced" ``Text`` view.
    ///
    /// The following code implements these animations:
    ///
    ///     struct TransactionExample: View {
    ///         @State var flag = false
    ///
    ///         var body: some View {
    ///             VStack(spacing: 50) {
    ///                 HStack(spacing: 30) {
    ///                     Text("Rotation")
    ///                         .rotationEffect(Angle(degrees: flag ? 360 : 0))
    ///
    ///                     Text("Rotation\nModified")
    ///                         .rotationEffect(Angle(degrees: flag ? 360 : 0))
    ///                         .transaction(value: flag) { t in
    ///                             t.animation =
    ///                                 t.animation?.delay(2.0).speed(2)
    ///                         }
    ///
    ///                     Text("Animation\nReplaced")
    ///                         .rotationEffect(Angle(degrees: flag ? 360 : 0))
    ///                         .transaction(value: flag) { t in
    ///                             t.disableAnimations = true
    ///                         }
    ///                 }
    ///
    ///                 Button("Animate") {
    ///                     withAnimation(.easeIn(duration: 2.0)) {
    ///                         flag.toggle()
    ///                     }
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - value: A value to monitor for changes.
    ///   - transform: The transformation to apply to transactions
    ///     within this view.
    ///
    /// - Returns: A view that wraps this view and applies a transformation to
    ///   all transactions used within the view whenever `value` changes.
    @available(OpenSwiftUI_v5_0, *)
    @_alwaysEmitIntoClient
    nonisolated public func transaction(
        value: some Equatable,
        _ transform: @escaping (inout Transaction) -> Void
    ) -> some View {
        modifier(_ValueTransactionModifier(value: value, transform: transform))
    }

    /// Applies the given animation to all animatable values within this view.
    ///
    /// Use this modifier on leaf views rather than container views. The
    /// animation applies to all child views within this view; calling
    /// `animation(_:)` on a container view can lead to unbounded scope.
    ///
    /// - Parameter animation: The animation to apply to animatable values
    ///   within this view.
    ///
    /// - Returns: A view that wraps this view and applies `animation` to all
    ///   animatable values used within the view.
    @available(OpenSwiftUI_v1_0, *)
    @available(*, deprecated, message: "Use withAnimation or animation(_:value:) instead.")
    @_disfavoredOverload
    @inlinable
    nonisolated public func animation(_ animation: Animation?) -> some View {
        return transaction { t in
            if !t.disablesAnimations {
                t.animation = animation
            }
        }
    }

    @_spi(DoNotImport)
    @available(OpenSwiftUI_v3_0, *)
    @_alwaysEmitIntoClient
    nonisolated public func ignoresAnimation() -> some View {
        transaction { t in
            if !t.disablesAnimations {
                t.animation = nil
            }
        }
    }
}

@available(OpenSwiftUI_v1_0, *)
extension ViewModifier {
    /// Returns a new version of the modifier that will apply the
    /// transaction mutation function `transform` to all transactions
    /// within the modifier.
    @inlinable
    nonisolated public func transaction(
        _ transform: @escaping (inout Transaction) -> Void
    ) -> some ViewModifier {
        return _PushPopTransactionModifier(content: self, transform: transform)
    }

    @inlinable
    @MainActor
    @preconcurrency
    public func animation(_ animation: Animation?) -> some ViewModifier {
        return transaction { t in
            if !t.disablesAnimations {
                t.animation = animation
            }
        }
    }
}

@available(OpenSwiftUI_v5_0, *)
extension View {
    /// Applies the given transaction mutation function to all animations used
    /// within the `body` closure.
    ///
    /// Any modifiers applied to the content of `body` will be applied to this
    /// view, and the changes to the transaction performed in the `transform`
    /// will only affect the modifiers defined in the `body`.
    ///
    /// The following code animates the opacity changing with a faster
    /// animation, while the contents of MyView are animated with the implicit
    /// transaction:
    ///
    ///     MyView(isActive: isActive)
    ///         .transaction { transaction in
    ///             transaction.animation = transaction.animation?.speed(2)
    ///         } body: { content in
    ///             content.opacity(isActive ? 1.0 : 0.0)
    ///         }
    ///
    /// - See Also: `Transaction.disablesAnimations`
    nonisolated public func transaction<V>(
        _ transform: @escaping (inout Transaction) -> Void,
        @ViewBuilder body: (PlaceholderContentView<Self>) -> V
    ) -> some View where V: View {
        modifier(
            PlaceholderContentView
                .withPlaceholderContent(result: body)
                .transaction(transform)
        )
    }

    /// Applies the given animation to all animatable values within the `body`
    /// closure.
    ///
    /// Any modifiers applied to the content of `body` will be applied to this
    /// view, and the `animation` will only be used on the modifiers defined in
    /// the `body`.
    ///
    /// The following code animates the opacity changing with an easeInOut
    /// animation, while the contents of MyView are animated with the implicit
    /// transaction's animation:
    ///
    ///     MyView(isActive: isActive)
    ///         .animation(.easeInOut) { content in
    ///             content.opacity(isActive ? 1.0 : 0.0)
    ///         }
    @available(OpenSwiftUI_v5_0, *)
    nonisolated public func animation<V>(
        _ animation: Animation?,
        @ViewBuilder body: (PlaceholderContentView<Self>) -> V
    ) -> some View where V: View {
        transaction(
            { if !$0.disablesAnimations { $0.animation = animation }},
            body: body,
        )
    }
}

@_spi(ForSwiftChartsOnly)
@available(OpenSwiftUI_v5_0, *)
extension PlaceholderContentView {
    @_spi(ForSwiftChartsOnly)
    @MainActor
    @preconcurrency
    public static func withPlaceholderContent<V>(
        @ViewBuilder result: (PlaceholderContentView<Value>) -> V
    ) -> some ViewModifier where V: View {
        CustomModifer<Value, V>(result: result(.init()))
    }
}

// MARK: - TransactionModifier

/// Modifier to set a transaction adjustment.
@frozen
public struct _TransactionModifier: ViewModifier, _GraphInputsModifier, PrimitiveViewModifier {
    /// A closure that transforms the current transaction.
    ///
    /// This closure receives the current transaction and can modify it in place.
    public var transform: (inout Transaction) -> ()

    /// Creates a transaction modifier with the specified transform closure.
    ///
    /// - Parameter transform: A closure that modifies the transaction in place.
    public init(transform: @escaping (inout Transaction) -> ()) {
        self.transform = transform
    }

    public static func _makeInputs(modifier: _GraphValue<Self>, inputs: inout _GraphInputs) {
        let child = ChildTransaction(modifier: modifier.value, transaction: inputs.transaction)
        inputs.transaction = Attribute(child)
    }
}

@available(*, unavailable)
extension _TransactionModifier: Sendable {}

// MARK: - ValueTransactionModifier

/// Modifier to set a transaction adjustment with a value constraint.
@frozen
public struct _ValueTransactionModifier<Value>: ViewModifier, _GraphInputsModifier, PrimitiveViewModifier where Value: Equatable {
    /// The value to monitor for changes.
    ///
    /// When this value changes (as determined by `Equatable` conformance),
    /// the transaction modifier will be applied.
    public var value: Value

    /// A closure that transforms the current transaction.
    ///
    /// This closure receives the current transaction and can modify it in place.
    public var transform: (inout Transaction) -> ()

    /// Creates a value transaction modifier with the specified value and transform closure.
    ///
    /// - Parameters:
    ///   - value: The value to monitor for changes.
    ///   - transform: A closure that modifies the transaction in place.
    public init(value: Value, transform: @escaping (inout Transaction) -> Void) {
        self.value = value
        self.transform = transform
    }

    public static func _makeInputs(modifier: _GraphValue<_ValueTransactionModifier<Value>>, inputs: inout _GraphInputs) {
        let value = modifier[offset: { .of(&$0.value) }]
        let host = GraphHost.currentHost
        let transactionSeed = host.data.$transactionSeed
        let seed = ValueTransactionSeed(
            value: value.value,
            transactionSeed: transactionSeed
        )
        let seedAttribute = Attribute(seed)
        seedAttribute.flags = .transactional
        let child = ChildValueTransaction(
            valueTransactionSeed: seedAttribute,
            transform: modifier.value[keyPath: \.transform],
            transaction: inputs.transaction,
            transactionSeed: transactionSeed
        )
        inputs.transaction = Attribute(child)
    }
}

@available(*, unavailable)
extension _ValueTransactionModifier: Sendable {}

// MARK: - PushPopTransactionModifier

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _PushPopTransactionModifier<Content>: ViewModifier, MultiViewModifier, PrimitiveViewModifier where Content: ViewModifier {
    /// The content to which the transaction modification applies.
    public var content: Content

    /// The base transaction modifier to apply.
    public var base: _TransactionModifier

    /// Creates a push-pop transaction modifier with the specified content and transform closure.
    ///
    /// - Parameters:
    ///   - content: The content to which the transaction modification applies.
    ///   - transform: A closure that modifies the transaction in place.
    public init(content: Content, transform: @escaping (inout Transaction) -> Void) {
        self.content = content
        self.base = .init(transform: transform)
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var inputs = inputs
        let transaction = inputs.transaction
        inputs.savedTransactions.append(transaction)
        let child = ChildTransaction(
            modifier: modifier.value[offset: { .of(&$0.base) }],
            transaction: transaction
        )
        inputs.transaction = Attribute(child)
        return Content.makeDebuggableView(
            modifier: modifier[offset: { .of(&$0.content) }],
            inputs: inputs
        ) { graph, inputs in
            var inputs = inputs
            inputs.savedTransactions.removeLast()
            return body(graph, inputs)
        }
    }
}

@available(*, unavailable)
extension _PushPopTransactionModifier: Sendable {}

// MARK: _GraphInputs + savedTransactions

extension _GraphInputs {
    private struct SavedTransactionKey: ViewInput {
        /// The default value for saved transactions.
        static let defaultValue: [Attribute<Transaction>] = []
    }

    /// The stack of saved transactions.
    ///
    /// This property maintains a stack of transaction contexts that can be restored
    /// after temporary modifications.
    package var savedTransactions: [Attribute<Transaction>] {
        get { self[SavedTransactionKey.self] }
        set { self[SavedTransactionKey.self] = newValue }
    }
}

// MARK: _ViewInputs + savedTransactions

extension _ViewInputs {
    /// The stack of saved transactions.
    ///
    /// This property provides access to the transaction stack from view inputs.
    package var savedTransactions: [Attribute<Transaction>] {
        get { base.savedTransactions }
        set { base.savedTransactions = newValue }
    }

    /// Gets the transaction to use for geometry calculations.
    ///
    /// This method returns the first saved transaction if available, or the current
    /// transaction otherwise.
    ///
    /// - Returns: The transaction attribute to use for geometry calculations.
    package func geometryTransaction() -> Attribute<Transaction> {
        savedTransactions.first ?? transaction
    }
}

// MARK: - ChildValueTransaction

private struct ChildValueTransaction: Rule, AsyncAttribute {
    @Attribute var valueTransactionSeed: UInt32
    @Attribute var transform: (inout Transaction) -> ()
    @Attribute var transaction: Transaction
    @Attribute var transactionSeed: UInt32

    var value: Transaction {
        var transaction = transaction
        let seed = Graph.withoutUpdate({ transactionSeed })
        if valueTransactionSeed == seed  {
            $transform.syncMainIfReferences { transform in
                transform(&transaction)
            }
            Swift.precondition(transactionSeed == seed)
        }
        return transaction
    }
}

// MARK: - ChildTransaction

private struct ChildTransaction: Rule, AsyncAttribute {
    @Attribute var modifier: _TransactionModifier
    @Attribute var transaction: Transaction

    var value: Transaction {
        var transaction = transaction
        $modifier.syncMainIfReferences { modifier in
            modifier.transform(&transaction)
        }
        return transaction
    }
}

// MARK: - CustomModifer

private struct CustomModifer<Value, V>: MultiViewModifier, PrimitiveViewModifier where V: View {
    var result: V

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var inputs = inputs
        inputs.pushModifierBody(PlaceholderContentView<Value>.self, body: body)
        let view = modifier[offset: { .of(&$0.result) }]
        let outputs = V._makeView(view: view, inputs: inputs)
        return outputs
    }
}
