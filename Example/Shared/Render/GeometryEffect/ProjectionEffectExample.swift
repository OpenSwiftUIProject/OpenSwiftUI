//
//  ProjectionEffectExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct ProjectionEffectExample: View {
    nonisolated static var transform: ProjectionTransform {
        var transform = ProjectionTransform(TransformEffectExample.transform)
        transform.m13 = 0.004
        transform.m23 = 0.002
        return transform
    }

    var body: some View {
        GeometryEffectSample()
            .projectionEffect(Self.transform)
            .background(Color(white: 0.8))
    }
}

#Preview {
    ProjectionEffectExample()
        .frame(width: 200, height: 200)
}
