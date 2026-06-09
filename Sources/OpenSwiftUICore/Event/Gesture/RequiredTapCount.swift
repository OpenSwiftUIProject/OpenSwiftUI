//
//  RequiredTapCount.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 7C0ADFDC1D38FCDDCFDE5CE8530A0B2E (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - Gesture + requiredTapCount

extension Gesture {
    package func requiredTapCount(_ count: Int?) -> some Gesture<Value> {
        modifier(RequiredTapCountWriter<Value>(count: count))
    }
}

// MARK: - RequiredTapCountWriter

private struct RequiredTapCountWriter<GestureValue>: GestureModifier {
    private struct Child: Rule {
        @Attribute var modifier: RequiredTapCountWriter<GestureValue>

        typealias Value = (inout Int?) -> Void

        var value: (inout Int?) -> Void {
            let count = modifier.count
            return { value in
                if let currentValue = value {
                    value = max(currentValue, count ?? currentValue)
                } else {
                    value = count
                }
            }
        }
    }

    var count: Int?

    static func _makeGesture(
        modifier: _GraphValue<RequiredTapCountWriter<GestureValue>>,
        inputs: _GestureInputs,
        body: (_GestureInputs) -> _GestureOutputs<GestureValue>
    ) -> _GestureOutputs<GestureValue> {
        var outputs = body(inputs)
        outputs.preferences.makePreferenceTransformer(
            inputs: inputs.preferences,
            key: RequiredTapCountKey.self,
            transform: Attribute(Child(modifier: modifier.value))
        )
        return outputs
    }

    typealias Value = GestureValue

    typealias BodyValue = GestureValue
}

// MARK: - RequiredTapCountKey

struct RequiredTapCountKey: PreferenceKey {
    typealias Value = Int?

    static func reduce(value: inout Int?, nextValue: () -> Int?) {
        if let currentValue = value {
            value = max(currentValue, nextValue() ?? currentValue)
        } else {
            value = nextValue()
        }
    }
}
