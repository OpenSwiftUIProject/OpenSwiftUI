//
//  BlendModeExample.swift
//  Shared

#if OPENSWIFTUI
@_spi(Private) import OpenSwiftUI
#else
@_spi(Private) import SwiftUI_SPI
#endif

struct BlendModeExample: View {
    var body: some View {
        BlendModeRectanglesExample(blendMode: .colorBurn)
    }
}

struct BlendModeRectanglesExample: View {
    var blendMode: BlendMode

    var body: some View {
        HStack {
            Color.yellow.frame(width: 50, height: 50, alignment: .center)
            Color.red.frame(width: 50, height: 50, alignment: .center)
                .rotationEffect(.degrees(45))
                .padding(-20)
                .blendMode(blendMode)
        }
    }
}

struct ExtendedBlendModeExample: View {
    var body: some View {
        ExtendedBlendModeRectanglesExample(blendMode: .clear)
    }
}

struct ExtendedBlendModeRectanglesExample: View {
    var blendMode: GraphicsContext.BlendMode

    var body: some View {
        HStack {
            Color.yellow.frame(width: 50, height: 50, alignment: .center)
            Color.red.frame(width: 50, height: 50, alignment: .center)
                .rotationEffect(.degrees(45))
                .padding(-20)
                .extendedBlendMode(blendMode)
        }
    }
}

#Preview {
    BlendModeExample()
}

#Preview {
    ExtendedBlendModeExample()
}
