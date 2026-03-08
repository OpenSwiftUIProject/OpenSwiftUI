//
//  ValueActionSceneModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import OpenAttributeGraphShims
package import OpenSwiftUICore

// MARK: - Scene + onChange (deprecated)

@available(OpenSwiftUI_v2_0, *)
extension Scene {

    /// Adds an action to perform when the given value changes.
    ///
    /// Use this modifier to trigger a side effect when a value changes, like
    /// the value associated with an ``OpenSwiftUI/Environment`` value or a
    /// ``OpenSwiftUI/Binding``. For example, you can clear a cache when you notice
    /// that a scene moves to the background:
    ///
    ///     struct MyScene: Scene {
    ///         @Environment(\.scenePhase) private var scenePhase
    ///         @StateObject private var cache = DataCache()
    ///
    ///         var body: some Scene {
    ///             WindowGroup {
    ///                 MyRootView()
    ///             }
    ///             .onChange(of: scenePhase) { newScenePhase in
    ///                 if newScenePhase == .background {
    ///                     cache.empty()
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// The system may call the action closure on the main actor, so avoid
    /// long-running tasks in the closure. If you need to perform such tasks,
    /// detach an asynchronous background task:
    ///
    ///     .onChange(of: scenePhase) { newScenePhase in
    ///         if newScenePhase == .background {
    ///             Task.detached(priority: .background) {
    ///                 // ...
    ///             }
    ///         }
    ///     }
    ///
    /// The system passes the new value into the closure. If you need the old
    /// value, capture it in the closure.
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
    ///     provides a single `newValue` parameter that indicates the changed
    ///     value.
    ///
    /// - Returns: A scene that triggers an action in response to a change.
    @available(*, deprecated, message: "Use `onChange` with a two or zero parameter action closure instead.")
    @inlinable
    nonisolated public func onChange<V>(
        of value: V,
        perform action: @escaping (_ newValue: V) -> Void
    ) -> some Scene where V: Equatable {
        modifier(_ValueActionModifier(value: value, action: action))
    }
}

// MARK: - _ValueActionModifier + _SceneModifier

@available(OpenSwiftUI_v2_0, *)
extension _ValueActionModifier: PrimitiveSceneModifier {
    @MainActor
    @preconcurrency
    public static func _makeScene(
        modifier: _GraphValue<Self>,
        inputs: _SceneInputs,
        body: @escaping (_Graph, _SceneInputs) -> _SceneOutputs
    ) -> _SceneOutputs {
        let dispatcher = Attribute(ValueActionDispatcher<Self>(
            modifier: modifier.value,
            phase: inputs.base.phase
        ))
        dispatcher.flags = .transactional
        return body(_Graph(), inputs)
    }
}

// MARK: - Scene + onChange

@available(OpenSwiftUI_v5_0, *)
extension Scene {

    /// Adds an action to perform when the given value changes.
    ///
    /// Use this modifier to trigger a side effect when a value changes, like
    /// the value associated with an ``OpenSwiftUI/Environment`` key or a
    /// ``OpenSwiftUI/Binding``. For example, you can clear a cache when you notice
    /// that a scene moves to the background:
    ///
    ///     struct MyScene: Scene {
    ///         @Environment(\.scenePhase) private var scenePhase
    ///         @StateObject private var cache = DataCache()
    ///
    ///         var body: some Scene {
    ///             WindowGroup {
    ///                 MyRootView(cache: cache)
    ///             }
    ///             .onChange(of: scenePhase) { oldScenePhase, newScenePhase in
    ///                 if newScenePhase == .background {
    ///                     cache.empty()
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// The system may call the action closure on the main actor, so avoid
    /// long-running tasks in the closure. If you need to perform such tasks,
    /// detach an asynchronous background task:
    ///
    ///     .onChange(of: scenePhase) { oldScenePhase, newScenePhase in
    ///         if newScenePhase == .background {
    ///             Task.detached(priority: .background) {
    ///                 // ...
    ///             }
    ///         }
    ///     }
    ///
    /// When the value changes, the new version of the closure will be called,
    /// so any captured values will have their values from the time that the
    /// observed value has its new value. The system passes the old and new
    /// observed values into the closure.
    ///
    /// - Parameters:
    ///   - value: The value to check when determining whether to run the
    ///     closure. The value must conform to the
    ///     [Equatable](https://developer.apple.com/documentation/swift/equatable)
    ///     protocol.
    ///   - initial: Whether the action should be run when this scene initially
    ///     appears.
    ///   - action: A closure to run when the value changes.
    ///   - oldValue: The old value that failed the comparison check (or the
    ///     initial value when requested).
    ///   - newValue: The new value that failed the comparison check.
    ///
    /// - Returns: A scene that triggers an action in response to a change.
    nonisolated public func onChange<V>(
        of value: V,
        initial: Bool = false,
        _ action: @escaping (_ oldValue: V, _ newValue: V) -> Void
    ) -> some Scene where V: Equatable {
        let s = modifier(_ValueActionModifier2(value: value, action: action))
        let appear = initial ? { action(value, value) } : nil
        return s.modifier(_AppearanceActionModifier(appear: appear, disappear: nil))
    }

    /// Adds an action to perform when the given value changes.
    ///
    /// Use this modifier to trigger a side effect when a value changes, like
    /// the value associated with an ``OpenSwiftUI/Environment`` key or a
    /// ``OpenSwiftUI/Binding``. For example, you can clear a cache when you notice
    /// that a scene moves to the background:
    ///
    ///     struct MyScene: Scene {
    ///         @Environment(\.locale) private var locale
    ///         @StateObject private var cache = LocalizationDataCache()
    ///
    ///         var body: some Scene {
    ///             WindowGroup {
    ///                 MyRootView(cache: cache)
    ///             }
    ///             .onChange(of: locale) {
    ///                 cache.empty()
    ///             }
    ///         }
    ///     }
    ///
    /// The system may call the action closure on the main actor, so avoid
    /// long-running tasks in the closure. If you need to perform such tasks,
    /// detach an asynchronous background task:
    ///
    ///     .onChange(of: locale) {
    ///         Task.detached(priority: .background) {
    ///             // ...
    ///         }
    ///     }
    ///
    /// When the value changes, the new version of the closure will be called,
    /// so any captured values will have their values from the time that the
    /// observed value has its new value.
    ///
    /// - Parameters:
    ///   - value: The value to check when determining whether to run the
    ///     closure. The value must conform to the
    ///     [Equatable](https://developer.apple.com/documentation/swift/equatable)
    ///     protocol.
    ///   - initial: Whether the action should be run when this scene initially
    ///     appears.
    ///   - action: A closure to run when the value changes.
    ///
    /// - Returns: A scene that triggers an action in response to a change.
    nonisolated public func onChange<V>(
        of value: V,
        initial: Bool = false,
        _ action: @escaping () -> Void
    ) -> some Scene where V: Equatable {
        let s = modifier(_ValueActionModifier2(value: value, action: { _, _ in action() }))
        let appear = initial ? action : nil
        return s.modifier(_AppearanceActionModifier(appear: appear, disappear: nil))
    }
}

// MARK: - _ValueActionModifier2 + _SceneModifier

@available(OpenSwiftUI_v2_0, *)
extension _ValueActionModifier2: PrimitiveSceneModifier {
    @MainActor
    @preconcurrency
    package static func _makeScene(
        modifier: _GraphValue<Self>,
        inputs: _SceneInputs,
        body: @escaping (_Graph, _SceneInputs) -> _SceneOutputs
    ) -> _SceneOutputs {
        let dispatcher = Attribute(ValueActionDispatcher<Self>(
            modifier: modifier.value,
            phase: inputs.base.phase
        ))
        dispatcher.flags = .transactional
        return body(_Graph(), inputs)
    }
}
