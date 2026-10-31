//
//  NumericTextTransitionExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

// Tap to compare the numeric transition with the default text transition.
// FIXME: OpenSwiftUI currently replaces both values directly. Text does not
// yet attach its interpolator group, and content interpolation is incomplete.
struct NumericTextTransitionExample: View {
    @State private var counter = 0

    var body: some View {
        VStack {
            Text("\(counter)")
                .contentTransition(.numericText())
                .font(.title)
            Text("\(counter)")
                .font(.title)
        }
        .padding()
        .onTapGesture {
            withAnimation(.interactiveSpring) {
                counter += 1
            }
        }
    }
}

#Preview {
    NumericTextTransitionExample()
}
