//
//  RepeatAnimationExample.swift
//  SharedExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct RepeatAnimationExample: View {
    @State var yOffset = 0.0
    
    var body: some View {
        Color.blue
            .frame(width: 80, height: 50)
            .offset(y: yOffset)
            .onAppear {
                withAnimation(
                    .linear
                    .speed(0.1)
                    .repeatCount(2, autoreverses: false)
                ) {
                    yOffset = 100
                }
            }
    }
}
