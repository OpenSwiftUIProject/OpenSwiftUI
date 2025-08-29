//
//  ValueActionModifier.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 4B528D9D60F208F316B29B7D53AC1FB9 (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - View + onChange

import Foundation
@available(OpenSwiftUI_v2_0, *)
extension View {
    /// Performs an action when a specified value changes.
    ///
    /// Use this modifier to run a closure when a value like
    /// an ``Environment`` value or a ``Binding`` changes.
    /// For example, you can clear a cache when you notice
    /// that the view's scene moves to the background:
    ///
    ///     struct ContentView: View {
    ///         @Environment(\.scenePhase) private var scenePhase
    ///         @StateObject private var cache = DataCache()
    ///
    ///         var body: some View {
    ///             MyView()
    ///                 .onChange(of: scenePhase) { newScenePhase in
    ///                     if newScenePhase == .background {
    ///                         cache.empty()
    ///                     }
    ///                 }
    ///         }
    ///     }
    ///
    /// OpenSwiftUI passes the new value into the closure. You can also capture the
    /// previous value to compare it to the new value. For example, in
    /// the following code example, `PlayerView` passes both the old and new
    /// values to the model.
    ///
    ///     struct PlayerView: View {
    ///         var episode: Episode
    ///         @State private var playState: PlayState = .paused
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Text(episode.title)
    ///                 Text(episode.showTitle)
    ///                 PlayButton(playState: $playState)
    ///             }
    ///             .onChange(of: playState) { [playState] newState in
    ///                 model.playStateDidChange(from: playState, to: newState)
    ///             }
    ///         }
    ///     }
    ///
    /// The system may call the action closure on the main actor, so avoid
    /// long-running tasks in the closure. If you need to perform such tasks,
    /// detach an asynchronous background task.
    ///
    /// Important: This modifier is deprecated and has been replaced with new
    /// versions that include either zero or two parameters within the closure,
    /// unlike this version that includes one parameter. This deprecated version
    /// and the new versions behave differently with respect to how they execute
    /// the action closure, specifically when the closure captures other values.
    /// Using the deprecated API, the closure is run with captured values that
    /// represent the "old" state. With the replacement API, the closure is run
    /// with captured values that represent the "new" state, which makes it
    /// easier to correctly perform updates that rely on supplementary values
    /// (that may or may not have changed) in addition to the changed value that
    /// triggered the action.
    ///
    /// - Important: This modifier is deprecated and has been replaced with new
    ///   versions that include either zero or two parameters within the
    ///   closure, unlike this version that includes one parameter. This
    ///   deprecated version and the new versions behave differently with
    ///   respect to how they execute the action closure, specifically when the
    ///   closure captures other values. Using the deprecated API, the closure
    ///   is run with captured values that represent the "old" state. With the
    ///   replacement API, the closure is run with captured values that
    ///   represent the "new" state, which makes it easier to correctly perform
    ///   updates that rely on supplementary values (that may or may not have
    ///   changed) in addition to the changed value that triggered the action.
    ///
    /// - Parameters:
    ///   - value: The value to check when determining whether to run the
    ///     closure. The value must conform to the
    ///     [Equatable](https://developer.apple.com/documentation/swift/equatable)
    ///     protocol.
    ///   - action: A closure to run when the value changes. The closure
    ///     takes a `newValue` parameter that indicates the updated
    ///     value.
    ///
    /// - Returns: A view that runs an action when the specified value changes.
    @available(*, deprecated, message: "Use `onChange` with a two or zero parameter action closure instead.")
    @inlinable
    nonisolated public func onChange<V>(
        of value: V,
        perform action: @escaping (_ newValue: V) -> Void
    ) -> some View where V: Equatable {
        modifier(_ValueActionModifier(value: value, action: action))
    }
}

// MARK: - ValueActionModifier

/// A modifier to dispatch an action when a value changes.
@available(OpenSwiftUI_v2_0, *)
@frozen
public struct _ValueActionModifier<Value>: ViewModifier, PrimitiveViewModifier, ValueActionModifierProtocol where Value: Equatable {
    public var value: Value

    public var action: (Value) -> Void

    @inlinable
    public init(value: Value, action: @escaping (Value) -> Void) {
        (self.value, self.action) = (value, action)
    }

    func sendAction(old: Self?) {
        let action = (old ?? self).action
        action(value)
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let dispatcher = Attribute(ValueActionDispatcher<Self>(
            modifier: modifier.value,
            phase: inputs.viewPhase
        ))
        dispatcher.flags = .transactional
        return body(_Graph(), inputs)
    }

    nonisolated public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        guard isLinkedOnOrAfter(.v3) else {
            return makeMultiViewList(
                modifier: modifier,
                inputs: inputs,
                body: body
            )
        }
        let dispatcher = Attribute(ValueActionDispatcher<Self>(
            modifier: modifier.value,
            phase: inputs.base.phase
        ))
        dispatcher.flags = .transactional
        return body(_Graph(), inputs)
    }
}

@available(*, unavailable)
extension _ValueActionModifier: Sendable {}

// MARK: - ValueActionModifierProtocol

protocol ValueActionModifierProtocol {
    associatedtype Value: Equatable

    var value: Value { get }

    func sendAction(old: Self?)
}

// MARK: - ValueActionDispatcher

struct ValueActionDispatcher<Modifier>: StatefulRule, AsyncAttribute where Modifier: ValueActionModifierProtocol {
    @Attribute var modifier: Modifier
    @Attribute var phase: _GraphInputs.Phase
    var oldValue: Modifier?
    var lastResetSeed: UInt32 = .zero
    var cycleDetector: UpdateCycleDetector = .init()

    init(
        modifier: Attribute<Modifier>,
        phase: Attribute<_GraphInputs.Phase>
    ) {
        self._modifier = modifier
        self._phase = phase
    }

    typealias Value = Void

    mutating func updateValue() {
        if lastResetSeed != phase.resetSeed {
            lastResetSeed = phase.resetSeed
            oldValue = nil
            cycleDetector.reset()
        }
        let newValue = modifier
        defer { oldValue = newValue }
        guard oldValue.map({ $0.value != newValue.value }) == true else {
            return
        }
        guard cycleDetector.dispatch(
            label: "onChange(of: \(Modifier.self)) action",
            isDebug: true
        ) else {
            return
        }
        let oldValue = oldValue
        Update.enqueueAction { // FIXME: Update.enqueueAction(reason:)
            newValue.sendAction(old: oldValue)
        }
    }
}

// MARK: - View + onChange2

@available(OpenSwiftUI_v5_0, *)
extension View {
    /// Adds a modifier for this view that fires an action when a specific
    /// value changes.
    ///
    /// You can use `onChange` to trigger a side effect as the result of a
    /// value changing, such as an `Environment` key or a `Binding`.
    ///
    /// The system may call the action closure on the main actor, so avoid
    /// long-running tasks in the closure. If you need to perform such tasks,
    /// detach an asynchronous background task.
    ///
    /// When the value changes, the new version of the closure will be called,
    /// so any captured values will have their values from the time that the
    /// observed value has its new value. The old and new observed values are
    /// passed into the closure. In the following code example, `PlayerView`
    /// passes both the old and new values to the model.
    ///
    ///     struct PlayerView: View {
    ///         var episode: Episode
    ///         @State private var playState: PlayState = .paused
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Text(episode.title)
    ///                 Text(episode.showTitle)
    ///                 PlayButton(playState: $playState)
    ///             }
    ///             .onChange(of: playState) { oldState, newState in
    ///                 model.playStateDidChange(from: oldState, to: newState)
    ///             }
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - value: The value to check against when determining whether
    ///     to run the closure.
    ///   - initial: Whether the action should be run when this view initially
    ///     appears.
    ///   - action: A closure to run when the value changes.
    ///   - oldValue: The old value that failed the comparison check (or the
    ///     initial value when requested).
    ///   - newValue: The new value that failed the comparison check.
    ///
    /// - Returns: A view that fires an action when the specified value changes.
    nonisolated public func onChange<V>(
        of value: V,
        initial: Bool = false,
        _ action: @escaping (_ oldValue: V, _ newValue: V) -> Void
    ) -> some View where V: Equatable {
        let v = modifier(_ValueActionModifier2(value: value, action: action))
        let appear: (() -> Void)?
        if initial {
            appear = { action(value, value) }
        } else {
            appear = nil
        }
        return v.modifier(_AppearanceActionModifier(appear: appear, disappear: nil))

    }

    /// Adds a modifier for this view that fires an action when a specific
    /// value changes.
    ///
    /// You can use `onChange` to trigger a side effect as the result of a
    /// value changing, such as an `Environment` key or a `Binding`.
    ///
    /// The system may call the action closure on the main actor, so avoid
    /// long-running tasks in the closure. If you need to perform such tasks,
    /// detach an asynchronous background task.
    ///
    /// When the value changes, the new version of the closure will be called,
    /// so any captured values will have their values from the time that the
    /// observed value has its new value. In the following code example,
    /// `PlayerView` calls into its model when `playState` changes model.
    ///
    ///     struct PlayerView: View {
    ///         var episode: Episode
    ///         @State private var playState: PlayState = .paused
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Text(episode.title)
    ///                 Text(episode.showTitle)
    ///                 PlayButton(playState: $playState)
    ///             }
    ///             .onChange(of: playState) {
    ///                 model.playStateDidChange(state: playState)
    ///             }
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - value: The value to check against when determining whether
    ///     to run the closure.
    ///   - initial: Whether the action should be run when this view initially
    ///     appears.
    ///   - action: A closure to run when the value changes.
    ///
    /// - Returns: A view that fires an action when the specified value changes.
    nonisolated public func onChange<V>(
        of value: V,
        initial: Bool = false,
        _ action: @escaping () -> Void
    ) -> some View where V: Equatable {
        let v = modifier(_ValueActionModifier2(value: value, action: { _, _ in action() }))
        let appear = initial ? action : nil
        return v.modifier(_AppearanceActionModifier(appear: appear, disappear: nil))
    }
}

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension View {
    @_spi(Private)
    public func _transactionalOnChange<V>(
        of value: V,
        _ action: @escaping (_ oldValue: V, _ newValue: V, Transaction) -> Void
    ) -> some View where V: Equatable {
        modifier(_ValueActionModifier3(value: value, action: action))
    }
}

// MARK: - ValueActionModifier2

struct _ValueActionModifier2<Value>: ViewModifier, PrimitiveViewModifier, ValueActionModifierProtocol where Value: Equatable {
    var value: Value

    var action: (Value, Value) -> ()

    init(value: Value, action: @escaping (Value, Value) -> Void) {
        self.value = value
        self.action = action
    }

    func sendAction(old: Self?) {
        action((old ?? self).value, value)
    }

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let dispatcher = Attribute(ValueActionDispatcher<Self>(
            modifier: modifier.value,
            phase: inputs.viewPhase
        ))
        dispatcher.flags = .transactional
        return body(_Graph(), inputs)
    }

    nonisolated static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        let dispatcher = Attribute(ValueActionDispatcher<Self>(
            modifier: modifier.value,
            phase: inputs.base.phase
        ))
        dispatcher.flags = .transactional
        return body(_Graph(), inputs)
    }
}

// MARK: - ValueActionModifier3

struct _ValueActionModifier3<Value>: ViewModifier, PrimitiveViewModifier where Value: Equatable {
    var value: Value
    var action: (Value, Value, Transaction) -> ()

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let dispatcher = Attribute(ValueActionDispatcher3<Value>(
            modifier: modifier.value,
            phase: inputs.viewPhase,
            transaction: inputs.transaction,
            oldValue: nil,
            lastResetSeed: .zero
        ))
        dispatcher.flags = .transactional
        return body(_Graph(), inputs)
    }

    nonisolated static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        let dispatcher = Attribute(ValueActionDispatcher3<Value>(
            modifier: modifier.value,
            phase: inputs.base.phase,
            transaction: inputs.base.transaction,
            oldValue: nil,
            lastResetSeed: .zero
        ))
        dispatcher.flags = .transactional
        return body(_Graph(), inputs)
    }
}

// MARK: - ValueActionDispatcher3

private struct ValueActionDispatcher3<Value>: StatefulRule, AsyncAttribute where Value: Equatable {
    @Attribute var modifier: _ValueActionModifier3<Value>
    @Attribute var phase: _GraphInputs.Phase
    @Attribute var transaction: Transaction
    var oldValue: Value?
    var lastResetSeed: UInt32
    var cycleDetector: UpdateCycleDetector

    init(
        modifier: Attribute<_ValueActionModifier3<Value>>,
        phase: Attribute<_GraphInputs.Phase>,
        transaction: Attribute<Transaction>,
        oldValue: Value?,
        lastResetSeed: UInt32,
        cycleDetector: UpdateCycleDetector = .init()
    ) {
        self._modifier = modifier
        self._phase = phase
        self._transaction = transaction
        self.oldValue = oldValue
        self.lastResetSeed = lastResetSeed
        self.cycleDetector = cycleDetector
    }

    typealias Value = Void

    mutating func updateValue() {
        if lastResetSeed != phase.resetSeed {
            lastResetSeed = phase.resetSeed
            oldValue = nil
            cycleDetector.reset()
        }
        let modifier = modifier
        let newValue = modifier.value
        defer { oldValue = newValue }
        guard let oldValue, oldValue != newValue else {
            return
        }
        guard cycleDetector.dispatch(
            label: "onChange(of: \(Value.self)) action",
            isDebug: true
        ) else {
            return
        }
        let transaction = Graph.withoutUpdate { self.transaction }
        Update.enqueueAction { // FIXME: Update.enqueueAction(reason:)
            modifier.action(oldValue, newValue, transaction)
        }
    }
}
