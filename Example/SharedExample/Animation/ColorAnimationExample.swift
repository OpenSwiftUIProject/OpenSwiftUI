//
//  ColorAnimationExample.swift
//  SharedExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct ColorAnimationExample: View {
    @State private var showRed = false
    var body: some View {
        VStack {
            Color(platformColor: showRed ? .red : .blue)
                .frame(width: showRed ? 200 : 400, height: showRed ? 200 : 400)
        }
        .animation(.easeInOut(duration: 5), value: showRed)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showRed.toggle()
            }
        }
    }
}
