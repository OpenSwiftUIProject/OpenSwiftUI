//
//  CancellableGesture.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - Gesture + cancellable

extension Gesture {
    package func cancellable() -> some Gesture<Self.Value> {
        truePreference(IsCancellableGestureKey.self)
    }
}

// MARK: - IsCancellableGestureKey

package struct IsCancellableGestureKey: PreferenceKey {
    package typealias Value = Bool

    package static let defaultValue = false

    package static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}
