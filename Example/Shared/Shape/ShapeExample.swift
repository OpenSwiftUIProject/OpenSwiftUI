//
//  ShapeExample.swift
//  Shared

import Foundation
#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct BuiltInShapeExample: View {
    enum Kind: String, CaseIterable {
        case rectangle
        case circle
        case ellipse
        case capsuleCircular
        case capsuleContinuous
        case roundedRectangleCircular
        case roundedRectangleContinuous
        case unevenRoundedRectangle
    }

    var kind: Kind = .roundedRectangleContinuous

    var body: some View {
        Group {
            switch kind {
            case .rectangle:
                Rectangle()
                    .fill(.teal)
            case .circle:
                Circle()
                    .fill(.red)
            case .ellipse:
                Ellipse()
                    .fill(.orange)
            case .capsuleCircular:
                Capsule(style: .circular)
                    .fill(.green)
            case .capsuleContinuous:
                Capsule(style: .continuous)
                    .fill(.mint)
            case .roundedRectangleCircular:
                RoundedRectangle(cornerRadius: 24, style: .circular)
                    .fill(.blue)
            case .roundedRectangleContinuous:
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.indigo)
            case .unevenRoundedRectangle:
                UnevenRoundedRectangle(
                    cornerRadii: RectangleCornerRadii(
                        topLeading: 30,
                        bottomLeading: 10,
                        bottomTrailing: 30,
                        topTrailing: 10
                    ),
                    style: .continuous
                )
                .fill(.purple)
            }
        }
        .frame(width: 150, height: 100)
    }
}

struct ShapeStrokeExample: View {
    enum Variant: String, CaseIterable {
        case circleLineWidth
        case roundedRectMint
        case dashedCapsule
        case filledAndStrokedCapsule
    }

    var variant: Variant = .dashedCapsule

    var body: some View {
        Group {
            switch variant {
            case .circleLineWidth:
                Circle()
                    .stroke(Color.purple, lineWidth: 5)
                    .frame(width: 120, height: 120)
            case .roundedRectMint:
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.mint, lineWidth: 10)
                    .frame(width: 160, height: 50)
            case .dashedCapsule:
                Capsule()
                    .stroke(
                        Color.purple,
                        style: StrokeStyle(
                            lineWidth: 5,
                            lineCap: .round,
                            lineJoin: .miter,
                            miterLimit: 0,
                            dash: [5, 10],
                            dashPhase: 0
                        )
                    )
                    .frame(width: 150, height: 80)
            case .filledAndStrokedCapsule:
                Capsule()
                    .fill(.yellow)
                    .stroke(.blue, lineWidth: 8)
                    .frame(width: 150, height: 80)
            }
        }
    }
}

struct ShapeStrokeBorderExample: View {
    enum Variant: String, CaseIterable {
        case roundedRectangle
        case insetCircle
        case unevenRoundedRectangle
    }

    var variant: Variant = .unevenRoundedRectangle

    var body: some View {
        Group {
            switch variant {
            case .roundedRectangle:
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.mint.opacity(0.25))
                    .strokeBorder(.mint, lineWidth: 8)
                    .frame(width: 150, height: 100)
            case .insetCircle:
                Circle()
                    .inset(by: 12)
                    .fill(.orange.opacity(0.2))
                    .strokeBorder(.orange, lineWidth: 8)
                    .frame(width: 140, height: 140)
            case .unevenRoundedRectangle:
                UnevenRoundedRectangle(
                    cornerRadii: RectangleCornerRadii(
                        topLeading: 30,
                        bottomLeading: 10,
                        bottomTrailing: 30,
                        topTrailing: 10
                    ),
                    style: .continuous
                )
                .fill(.blue.opacity(0.2))
                .strokeBorder(.blue, lineWidth: 5)
                .frame(width: 160, height: 100)
            }
        }
    }
}

#Preview("Built-in Shapes") {
    VStack(spacing: 12) {
        ForEach(BuiltInShapeExample.Kind.allCases, id: \.rawValue) { kind in
            BuiltInShapeExample(kind: kind)
        }
    }
    .padding()
}

#Preview("Strokes") {
    VStack(spacing: 20) {
        ForEach(ShapeStrokeExample.Variant.allCases, id: \.rawValue) { variant in
            ShapeStrokeExample(variant: variant)
        }
    }
    .padding()
}

#Preview("Stroke Borders") {
    VStack(spacing: 20) {
        ForEach(ShapeStrokeBorderExample.Variant.allCases, id: \.rawValue) { variant in
            ShapeStrokeBorderExample(variant: variant)
        }
    }
    .padding()
}
