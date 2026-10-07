//
//  BlendModeExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct BlendModeExample: View {
    var body: some View {
        BlendModeColorBurnExample()
    }
}

struct BlendModeColorBurnExample: View {
    var body: some View {
        HStack {
            Color.yellow.frame(width: 50, height: 50, alignment: .center)
            Color.red.frame(width: 50, height: 50, alignment: .center)
                .rotationEffect(.degrees(45))
                .padding(-20)
                .blendMode(.colorBurn)
        }
    }
}

#Preview {
    BlendModeExample()
}
