//
//  DragGestureExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct DragGestureExample: View {
    @State private var position: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero

    var drag: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                position.width += value.translation.width
                position.height += value.translation.height
            }
    }

    var body: some View {
        Circle()
            .fill(dragOffset == .zero ? Color.blue : Color.green)
            .frame(width: 100, height: 100)
            .offset(
                x: position.width + dragOffset.width,
                y: position.height + dragOffset.height
            )
            .gesture(drag)
    }
}

#Preview {
    DragGestureExample()
}
