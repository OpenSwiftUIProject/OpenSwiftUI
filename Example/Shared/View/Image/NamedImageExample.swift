//
//  NamedImageExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct NamedImageDecorativeExample: View {
    var body: some View {
        Image(decorative: "logo")
            .resizable()
            .frame(width: 100, height: 100)
    }
}

struct NamedImageRenderingModeOriginalExample: View {
    var body: some View {
        Image(decorative: "logo")
            .renderingMode(.original)
            .resizable()
            .frame(width: 100, height: 100)
    }
}

struct NamedImageRenderingModeTemplateExample: View {
    var body: some View {
        HStack(spacing: .zero) {
            Image(decorative: "logo")
                .renderingMode(.template)
                .resizable()
            Image(decorative: "logo")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.red)
        }
        .frame(width: 200, height: 100)
    }
}
