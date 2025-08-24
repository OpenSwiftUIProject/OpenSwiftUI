//
//  GeometryEffectExample.swift
//  SharedExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct GeometryEffectExample: View {
    var body: some View {
        VStack(spacing: 50) {
            OffsetEffectExample()
            RotationEffectExample()
            Rotation3DEffectExample()
        }
    }
}

struct OffsetEffectExample: View {
    var body: some View {
        Color.blue
            .offset(x: 20, y: 15)
            .frame(width: 80, height: 60)
            .background(Color.red)
            .overlay(Color.green.offset(x: 40, y: 30))
    }
}

struct RotationEffectExample: View {
    var body: some View {
        Color.blue
            .frame(width: 80, height: 60)
            .rotationEffect(.degrees(30))
            .background(Color.red)
            .overlay(
                Color.green
                    .frame(width: 40, height: 30)
                    .rotationEffect(.degrees(-30))
            )
    }
}

struct Rotation3DEffectExample: View {
    var body: some View {
        Color.blue
            .frame(width: 80, height: 60)
            .rotation3DEffect(
                .degrees(45),
                axis: (x: 0, y: 1, z: 0),
                anchor: .center,
                anchorZ: 0,
                perspective: 1
            )
            .background(Color.red)
            .overlay(
                Color.green
                    .frame(width: 40, height: 30)
                    .rotation3DEffect(
                        .degrees(-45),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .center,
                        anchorZ: 0,
                        perspective: 1
                    )
            )
    }
}
