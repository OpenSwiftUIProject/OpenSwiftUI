//
//  TextOrphanAndPushOutExample.swift
//  Shared

#if OPENSWIFTUI
@_spi(Private) import OpenSwiftUI
#else
@_spi(Private) import SwiftUI_SPI
#endif

struct TextOrphanAndPushOutExample: View {
    private let text = "OpenSwiftUI 开发者"
    private let width = 150.0

    @ViewBuilder
    private func textView(avoidsOrphans: Bool? = nil) -> some View {
        if let avoidsOrphans {
            Text(text)
                .frame(width: width, alignment: .leading)
                .avoidsOrphans(avoidsOrphans)
        } else {
            Text(text)
                .frame(width: width, alignment: .leading)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            textView()
            textView(avoidsOrphans: true)
            textView(avoidsOrphans: false)
        }
    }
}
