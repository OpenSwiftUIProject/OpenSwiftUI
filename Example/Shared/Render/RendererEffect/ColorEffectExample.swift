//
//  ColorEffectExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct ColorEffectExample: View {
    enum Effect {
        case brightness
        case contrast
        case grayscale
        case hueRotation
        case saturation
    }

    var effect: Effect = .hueRotation
    var amount: Double = 90
    var usesVisualEffect = false

    var body: some View {
        Group {
            if usesVisualEffect {
                visualContent
            } else {
                viewContent
            }
        }
        .frame(width: 200, height: 160)
        .background(Color(white: 0.9))
    }

    @ViewBuilder
    private var viewContent: some View {
        switch effect {
        case .brightness:
            ColorEffectPattern().brightness(amount)
        case .contrast:
            ColorEffectPattern().contrast(amount)
        case .grayscale:
            ColorEffectPattern().grayscale(amount)
        case .hueRotation:
            ColorEffectPattern().hueRotation(.degrees(amount))
        case .saturation:
            ColorEffectPattern().saturation(amount)
        }
    }

    @ViewBuilder
    private var visualContent: some View {
        let amount = amount
        switch effect {
        case .brightness:
            ColorEffectPattern().visualEffect { content, _ in
                content.brightness(amount)
            }
        case .contrast:
            ColorEffectPattern().visualEffect { content, _ in
                content.contrast(amount)
            }
        case .grayscale:
            ColorEffectPattern().visualEffect { content, _ in
                content.grayscale(amount)
            }
        case .hueRotation:
            ColorEffectPattern().visualEffect { content, _ in
                content.hueRotation(.degrees(amount))
            }
        case .saturation:
            ColorEffectPattern().visualEffect { content, _ in
                content.saturation(amount)
            }
        }
    }
}

struct ColorEffectPattern: View {
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Color(red: 0.8, green: 0.2, blue: 0.25)
                .frame(width: 48, height: 80)
            VStack(alignment: .leading, spacing: 0) {
                Color(red: 0.15, green: 0.65, blue: 0.3)
                    .frame(width: 72, height: 30)
                Color(red: 0.2, green: 0.35, blue: 0.8)
                    .frame(width: 46, height: 50)
            }
        }
    }
}

#Preview("ViewBrightnessNegative") {
    ColorEffectExample(effect: .brightness, amount: -0.25, usesVisualEffect: false)
}

#Preview("ViewBrightnessPositive") {
    ColorEffectExample(effect: .brightness, amount: 0.25, usesVisualEffect: false)
}

#Preview("ViewContrastZero") {
    ColorEffectExample(effect: .contrast, amount: 0, usesVisualEffect: false)
}

#Preview("ViewContrastNegative") {
    ColorEffectExample(effect: .contrast, amount: -1, usesVisualEffect: false)
}

#Preview("ViewGrayscalePartial") {
    ColorEffectExample(effect: .grayscale, amount: 0.5, usesVisualEffect: false)
}

#Preview("ViewGrayscaleFull") {
    ColorEffectExample(effect: .grayscale, amount: 1, usesVisualEffect: false)
}

#Preview("ViewHuePositive") {
    ColorEffectExample(effect: .hueRotation, amount: 90, usesVisualEffect: false)
}

#Preview("ViewHueNegative") {
    ColorEffectExample(effect: .hueRotation, amount: -90, usesVisualEffect: false)
}

#Preview("ViewSaturationZero") {
    ColorEffectExample(effect: .saturation, amount: 0, usesVisualEffect: false)
}

#Preview("ViewSaturationIncreased") {
    ColorEffectExample(effect: .saturation, amount: 1.5, usesVisualEffect: false)
}

#Preview("VisualBrightnessNegative") {
    ColorEffectExample(effect: .brightness, amount: -0.25, usesVisualEffect: true)
}

#Preview("VisualBrightnessPositive") {
    ColorEffectExample(effect: .brightness, amount: 0.25, usesVisualEffect: true)
}

#Preview("VisualContrastZero") {
    ColorEffectExample(effect: .contrast, amount: 0, usesVisualEffect: true)
}

#Preview("VisualContrastNegative") {
    ColorEffectExample(effect: .contrast, amount: -1, usesVisualEffect: true)
}

#Preview("VisualGrayscalePartial") {
    ColorEffectExample(effect: .grayscale, amount: 0.5, usesVisualEffect: true)
}

#Preview("VisualGrayscaleFull") {
    ColorEffectExample(effect: .grayscale, amount: 1, usesVisualEffect: true)
}

#Preview("VisualHuePositive") {
    ColorEffectExample(effect: .hueRotation, amount: 90, usesVisualEffect: true)
}

#Preview("VisualHueNegative") {
    ColorEffectExample(effect: .hueRotation, amount: -90, usesVisualEffect: true)
}

#Preview("VisualSaturationZero") {
    ColorEffectExample(effect: .saturation, amount: 0, usesVisualEffect: true)
}

#Preview("VisualSaturationIncreased") {
    ColorEffectExample(effect: .saturation, amount: 1.5, usesVisualEffect: true)
}
