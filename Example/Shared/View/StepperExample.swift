//
//  StepperExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct StepperExample: View {
    @State private var value: Int
    @State private var isEditing = false

    init(value: Int = 4) {
        _value = State(initialValue: value)
    }

    var body: some View {
        VStack(spacing: 16) {
            Stepper(
                "Count: \(value)",
                value: $value,
                in: 0...10,
                step: 2,
                onEditingChanged: { isEditing = $0 }
            )
            Text(isEditing ? "Editing" : "Ready")
                .foregroundColor(isEditing ? .red : .blue)
        }
        .padding()
    }
}

struct ActionStepperExample: View {
    @State private var value = 0

    var canIncrement = true
    var canDecrement = true

    var body: some View {
        Stepper(
            label: { Text("Count: \(value)") },
            onIncrement: canIncrement ? { value += 1 } : nil,
            onDecrement: canDecrement ? { value -= 1 } : nil
        )
        .padding()
    }
}

struct FractionalStepperExample: View {
    @State private var value = 1.25

    var body: some View {
        Stepper(value: $value, step: 0.25) {
            Text("Value: \(value, specifier: "%.2f")")
        }
        .padding()
    }
}

#Preview("Bounded") {
    StepperExample()
}

#Preview("Custom actions") {
    ActionStepperExample()
}

#Preview("Fractional steps") {
    FractionalStepperExample()
}

#Preview("Hidden labels and disabled") {
    VStack {
        StepperExample().labelsHidden()
        StepperExample().disabled(true)
    }
}
