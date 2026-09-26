//
//  ObservationExample.swift
//  Shared

#if OPENSWIFTUI
import OpenObservation
import OpenSwiftUI
#else
import Observation
import SwiftUI
#endif

struct ObservationExample: View {
    var body: some View {
        VStack {
            ObservationColorExample()
            Divider()
            ObservationCounterExample()
        }
    }
}

@Observable
private class ColorModel {
    var showRed = false
}

struct ObservationColorExample: View {
    @State private var model = ColorModel()

    var body: some View {
        VStack {
            Color(model.showRed ? .red : .blue)
            Text("Toggle")
                .onTapGesture {
                    model.showRed.toggle()
                }
        }
    }
}

#Preview {
    ObservationColorExample()
}

@Observable
private final class CounterModel {
    var count = 0
}

struct ObservationCounterExample: View {
    @State private var model = CounterModel()

    var body: some View {
        Text("Tap to increase: \(model.count)")
            .onTapGesture {
                model.count += 1
            }
    }
}

#Preview {
    ObservationCounterExample()
}
