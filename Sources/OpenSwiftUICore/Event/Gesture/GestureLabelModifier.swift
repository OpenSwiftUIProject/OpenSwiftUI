//
//  GestureLabelModifier.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import OpenAttributeGraphShims

// MARK: - Gesture + debugLabel

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension Gesture {
    public func debugLabel(_ l: String?) -> some Gesture<Self.Value> {
        modifier(GestureLabelModifier(label: l))
    }
}

// MARK: - GestureLabelModifier

struct GestureLabelModifier<Value>: GestureModifier {
    var label: String?

    static func _makeGesture(
        modifier: _GraphValue<GestureLabelModifier<Value>>,
        inputs: _GestureInputs,
        body: (_GestureInputs) -> _GestureOutputs<Value>
    ) -> _GestureOutputs<Value> {
        var outputs = body(inputs)
        guard inputs.preferences.containsGestureLabel else {
            return outputs
        }
        outputs.preferences.gestureLabel = modifier[offset: { .of(&$0.label) }].value
        return outputs
    }

    typealias BodyValue = Value
}

// MARK: - GestureLabelKey

struct GestureLabelKey: PreferenceKey {
    typealias Value = String?

    static func reduce(value: inout String?, nextValue: () -> String?) {
        value = value ?? nextValue()
    }
}

// MARK: - PreferencesInputs + GestureLabel

extension PreferencesInputs {
    @inline(__always)
    var containsGestureLabel: Bool {
        contains(GestureLabelKey.self)
    }
}

// MARK: - PreferencesOutputs + GestureLabel

extension PreferencesOutputs {
    @inline(__always)
    var gestureLabel: Attribute<String?>? {
        get { self[GestureLabelKey.self] }
        set { self[GestureLabelKey.self] = newValue }
    }
}
