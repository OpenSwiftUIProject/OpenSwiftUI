//
//  VisualRendererEffectExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct VisualRendererEffectExample: View {
    enum Effect {
        case blur(opaque: Bool)
        case blendMode(BlendMode)
        case brightnessThenContrast
        case contrastThenBrightness
    }

    var effect: Effect = .blur(opaque: false)

    var body: some View {
        content
            .frame(width: 200, height: 160)
            .background(Color(red: 0.85, green: 0.75, blue: 0.45))
    }

    @ViewBuilder
    private var content: some View {
        switch effect {
        case let .blur(opaque):
            ColorEffectPattern()
                .background(Color.white)
                .compositingGroup()
                .visualEffect { content, _ in
                    content.blur(radius: 8, opaque: opaque)
                }
        case let .blendMode(mode):
            ColorEffectPattern().visualEffect { content, _ in
                content.blendMode(mode)
            }
        case .brightnessThenContrast:
            ColorEffectPattern().visualEffect { content, _ in
                content.brightness(0.2).contrast(0.5)
            }
        case .contrastThenBrightness:
            ColorEffectPattern().visualEffect { content, _ in
                content.contrast(0.5).brightness(0.2)
            }
        }
    }
}

#Preview("BlurTransparent") {
    VisualRendererEffectExample(effect: .blur(opaque: false))
}

#Preview("BlurOpaque") {
    VisualRendererEffectExample(effect: .blur(opaque: true))
}

#Preview("BlendMultiply") {
    VisualRendererEffectExample(effect: .blendMode(.multiply))
}

#Preview("BlendScreen") {
    VisualRendererEffectExample(effect: .blendMode(.screen))
}

#Preview("BrightnessThenContrast") {
    VisualRendererEffectExample(effect: .brightnessThenContrast)
}

#Preview("ContrastThenBrightness") {
    VisualRendererEffectExample(effect: .contrastThenBrightness)
}
