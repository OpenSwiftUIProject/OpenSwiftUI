//
//  RepeatingEffectExample.swift
//  Shared

#if OPENSWIFTUI
@_spi(Private) import OpenSwiftUI
#else
@_spi(Private) import SwiftUI_SPI
#endif

struct RepeatingEffectExample: View {
    enum Effect {
        case scale
        case scaleSize
        case rotation
        case rotationRange
    }

    var effect: Effect = .scale

    var body: some View {
        animatedContent
            .background(Color.red.opacity(0.2))
    }

    @ViewBuilder
    private var animatedContent: some View {
        switch effect {
        case .scale:
            content.repeatingScaleEffect(
                from: 0.5,
                to: 1.25,
                anchor: .leading,
                animation: .linear(duration: 1)
            )
        case .scaleSize:
            content.repeatingScaleEffect(
                from: CGSize(width: 0.5, height: 0.8),
                to: CGSize(width: 1.25, height: 1.5),
                anchor: .topLeading,
                animation: .linear(duration: 1)
            )
        case .rotation:
            content.repeatingRotationEffect(anchor: .leading, duration: 1)
        case .rotationRange:
            content.repeatingRotationEffect(
                from: .degrees(-30),
                to: .degrees(120),
                anchor: .topLeading,
                animation: .linear(duration: 1)
            )
        }
    }

    private var content: some View {
        Color.blue
            .frame(width: 80, height: 40)
            .overlay(alignment: .topLeading) {
                Color.yellow.frame(width: 12, height: 12)
            }
    }
}

#Preview("Scale") {
    RepeatingEffectExample(effect: .scale)
        .frame(width: 200, height: 200)
}

#Preview("Scale Size") {
    RepeatingEffectExample(effect: .scaleSize)
        .frame(width: 200, height: 200)
}

#Preview("Rotation") {
    RepeatingEffectExample(effect: .rotation)
        .frame(width: 200, height: 200)
}

#Preview("Rotation Range") {
    RepeatingEffectExample(effect: .rotationRange)
        .frame(width: 200, height: 200)
}
