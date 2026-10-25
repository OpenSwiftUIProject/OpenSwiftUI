//
//  SliderExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct SliderExample: View {
    @State private var speed: Double
    @State private var isEditing = false

    init(speed: Double = 50) {
        _speed = State(initialValue: speed)
    }

    var body: some View {
        VStack(spacing: 16) {
            Slider(
                value: $speed,
                in: 0...100,
                onEditingChanged: { isEditing = $0 }
            )
            Text("\(speed, specifier: "%.0f")")
                .foregroundColor(isEditing ? .red : .blue)
        }
        .padding()
    }
}

struct SteppedSliderExample: View {
    @State private var speed = 85.0
    @State private var isEditing = false

    var body: some View {
        VStack(spacing: 16) {
            Slider(
                value: $speed,
                in: 0...100,
                step: 5
            ) {
                Text("Speed")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("100")
            } onEditingChanged: {
                isEditing = $0
            }
            Text("\(speed, specifier: "%.0f")")
                .foregroundColor(isEditing ? .red : .blue)
        }
        .padding()
    }
}

#Preview("Continuous") {
    SliderExample()
}

#Preview("Stepped with labels") {
    SteppedSliderExample()
}

#Preview("Tint and disabled") {
    VStack {
        SteppedSliderExample()
            .tint(.purple)
        SteppedSliderExample()
            .tint(.purple)
            .disabled(true)
    }
}
