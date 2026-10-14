//
//  TransformEffectExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct TransformEffectExample: View {
    nonisolated static var transform: CGAffineTransform {
        CGAffineTransform(a: 1, b: 0.15, c: 0.35, d: 1, tx: 12, ty: -10)
    }

    var body: some View {
        GeometryEffectSample()
            .transformEffect(Self.transform)
            .background(Color(white: 0.8))
    }
}

struct GeometryEffectSample: View {
    var body: some View {
        Color(red: 0.1, green: 0.3, blue: 0.8)
            .frame(width: 80, height: 60)
            .overlay(alignment: .topLeading) {
                Color(red: 1, green: 0.65, blue: 0.1)
                    .frame(width: 24, height: 18)
            }
            .overlay(alignment: .bottomTrailing) {
                Color.white
                    .frame(width: 12, height: 30)
            }
    }
}

#Preview {
    TransformEffectExample()
        .frame(width: 200, height: 200)
}
