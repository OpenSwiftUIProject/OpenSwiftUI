//
//  RepeatAnimationExample.swift
//  SharedExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct RepeatAnimationExample: View {
    @State private var smaller = false

    var body: some View {
        VStack {
            HStack {
                Color.red
                    .frame(width: smaller ? 50 : 100, height: smaller ? 50 : 100)
                    .animation(
                        .linear(duration: 1).repeatCount(2, autoreverses: false),
                        value: smaller,
                    )
                Color.green
                    .frame(width: smaller ? 50 : 100, height: smaller ? 50 : 100)
                    .animation(
                        .linear(duration: 1).repeatCount(2, autoreverses: true),
                        value: smaller,
                    )
            }
            HStack {
                Color.red
                    .frame(width: smaller ? 50 : 100, height: smaller ? 50 : 100)
                    .animation(
                        .linear(duration: 1).repeatForever(autoreverses: false),
                        value: smaller,
                    )
                Color.green
                    .frame(width: smaller ? 50 : 100, height: smaller ? 50 : 100)
                    .animation(
                        .linear(duration: 1).repeatForever(autoreverses: true),
                        value: smaller,
                    )
            }
        }
        .onAppear {
            smaller.toggle()
        }
    }
}
