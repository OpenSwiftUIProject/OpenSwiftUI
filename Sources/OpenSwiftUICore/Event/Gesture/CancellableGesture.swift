//
//  CancellableGesture.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import OpenAttributeGraphShims

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

// MARK: - PreferencesInputs + IsCancellable

extension PreferencesInputs {
    @inline(__always)
    var requiresIsCancellable: Bool {
        get {
            contains(IsCancellableGestureKey.self)
        }
        set {
            if newValue {
                add(IsCancellableGestureKey.self)
            } else {
                remove(IsCancellableGestureKey.self)
            }
        }
    }
}

// MARK: - PreferencesOutputs + IsCancellable

extension PreferencesOutputs {
    @inline(__always)
    var isCancellable: Attribute<Bool>? {
        get { self[IsCancellableGestureKey.self] }
        set { self[IsCancellableGestureKey.self] = newValue }
    }
}
