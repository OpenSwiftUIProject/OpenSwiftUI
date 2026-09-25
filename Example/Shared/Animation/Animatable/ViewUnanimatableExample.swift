//
//  ViewUnanimatableExample.swift
//  Shared

#if OPENSWIFTUI
@_spi(Private) import OpenSwiftUI
#else
@_spi(Private) import SwiftUI_SPI
#endif

struct ViewUnanimatableExample: View {
    @State private var toggle = false

    var body: some View {
        HStack {
            Color.red
                .frame(height: toggle ? 200 : 50)
            Color.blue
                .frame(height: toggle ? 200 : 50)
                .unanimatable()
        }
        .onTapGesture {
            withAnimation(.linear(duration: 10)) {
                toggle.toggle()
            }
        }
    }
}

#Preview {
    ViewUnanimatableExample()
}
