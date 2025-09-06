//
//  ObservationExample.swift
//  SharedExample

#if OPENSWIFTUI
import OpenObservation
import OpenSwiftUI
#else
import Observation
import SwiftUI
#endif

@Observable
private class Model {
    var showRed = false
}

struct ObservationExample: View {
    @State private var model = Model()

    private var showRed: Bool {
        get { model.showRed }
        nonmutating set { model.showRed = newValue }
    }

    var body: some View {
        VStack {
            Color(platformColor: showRed ? .red : .blue)
                .frame(width: showRed ? 200 : 400, height: showRed ? 200 : 400)
        }
        .animation(.spring, value: showRed)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showRed.toggle()
            }
        }
    }
}
