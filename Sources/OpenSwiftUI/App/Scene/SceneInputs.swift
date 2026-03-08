//
//  SceneInputs.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - _SceneInputs

/// Inputs used for creating attributes of a scene hierarchy.
@available(OpenSwiftUI_v2_0, *)
public struct _SceneInputs {
    package var base: _GraphInputs
    package var preferences: PreferencesInputs

    package mutating func append<T, U>(_ newValue: U, to _: T.Type) where T: SceneInput, T.Value == Stack<U> {
        base.append(newValue, to: T.self)
    }

    package mutating func popLast<T, U>(_ key: T.Type) -> U? where T: SceneInput, T.Value == Stack<U> {
        base.popLast(key)
    }
}

@available(*, unavailable)
extension _SceneInputs: Sendable {}

// MARK: - SceneInput

package protocol SceneInput: GraphInput {}
