//
//  MatchedGeometryEffectExample.swift
//  Shared

#if OPENSWIFTUI
@_spi(Private) import OpenSwiftUI
#else
import SwiftUI_SPI
extension MatchedGeometryProperties {
    // NOTE: SwiftUI_SPI somehow not work here
    fileprivate static var clipRect: MatchedGeometryProperties {
        .init(rawValue: 1 << 2)
    }
}
#endif

struct MatchedGeometryEffectExample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("matchedGeometryEffect")
            MatchedGeometryEffectModifierExample()
            Text("matchedGeometryEffect with clipShape")
            MatchedGeometryEffectClipShapeModifierExample()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Source: https://swiftui-lab.com/matchedgeometryeffect-part1/
struct MatchedGeometryEffectModifierExample: View {
    @Namespace var nspace
    @State private var flag: Bool = true

    var body: some View {
        HStack {
            if flag {
                Rectangle().fill(Color.green)
                    .matchedGeometryEffect(id: "geoeffect1", in: nspace)
                    .frame(width: 100, height: 100)
            }
            Spacer()
            // FIXME: change to button
            // Button("Switch") { withAnimation(.easeInOut(duration: 2.0)) { flag.toggle() } }
            Text("Switch")
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.0)) { flag.toggle() }
                }
            Spacer()
            if !flag {
                Circle()
                    .fill(Color.blue)
                    .matchedGeometryEffect(id: "geoeffect1", in: nspace)
                    .frame(width: 50, height: 50)
            }
        }
        .frame(width: 250).padding(10)
        // TODO: strokePath not implemented
//        .border(Color.gray, width: 3)
    }
}

struct MatchedGeometryEffectClipShapeModifierExample: View {
    @Namespace var nspace
    @State private var flag: Bool = true

    var body: some View {
        HStack {
            if flag {
                Rectangle().fill(Color.green)
                    .matchedGeometryEffect(
                        id: "clipped-frame",
                        in: nspace,
                        clipShape: RoundedRectangle(cornerRadius: 12),
                        properties: [.frame, .clipRect]
                    )
                    .frame(width: 100, height: 100)
            }
            Spacer()
            // FIXME: change to button
            // Button("Switch") { withAnimation(.easeInOut(duration: 2.0)) { flag.toggle() } }
            Text("Switch")
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.0)) { flag.toggle() }
                }
            Spacer()
            if !flag {
                Circle()
                    .fill(Color.blue)
                    .matchedGeometryEffect(
                        id: "clipped-frame",
                        in: nspace,
                        clipShape: RoundedRectangle(cornerRadius: 32),
                        properties: [.frame, .clipRect]
                    )
                    .frame(width: 50, height: 50)
            }
        }
        .frame(width: 250).padding(10)
        // TODO: strokePath not implemented
//        .border(Color.gray, width: 3)
    }
}
