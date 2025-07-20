//
//  ValueActionSceneModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

package import OpenSwiftUICore

@available(OpenSwiftUI_v2_0, *)
extension Scene {
    @available(*, deprecated, message: "Use `onChange` with a two or zero parameter action closure instead.")
    @inlinable
    nonisolated public func onChange<V>(
        of value: V,
        perform action: @escaping (_ newValue: V) -> Void
    ) -> some Scene where V: Equatable {
        // modifier(_ValueActionModifier(value: value, action: action))
        return self
    }
}

@available(OpenSwiftUI_v2_0, *)
extension _ValueActionModifier: _SceneModifier {
    @MainActor
    @preconcurrency
    public static func _makeScene(
        modifier: _GraphValue<_ValueActionModifier<Value>>,
        inputs: _SceneInputs,
        body: @escaping (_Graph, _SceneInputs) -> _SceneOutputs
    ) -> _SceneOutputs {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(OpenSwiftUI_v5_0, *)
extension Scene {
    nonisolated public func onChange<V>(
        of value: V,
        initial: Bool = false,
        _ action: @escaping (_ oldValue: V, _ newValue: V) -> Void
    ) -> some Scene where V: Equatable {
        _openSwiftUIUnimplementedFailure()
    }

    nonisolated public func onChange<V>(
        of value: V,
        initial: Bool = false,
        _ action: @escaping () -> Void
    ) -> some Scene where V: Equatable {
        _openSwiftUIUnimplementedFailure()
    }
}
