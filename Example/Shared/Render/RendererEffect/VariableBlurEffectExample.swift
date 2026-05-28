//
//  VariableBlurEffectExample.swift
//  Shared

#if OPENSWIFTUI
@_spi(Private) import OpenSwiftUI
#else
import SwiftUI_SPI
#endif

struct VariableBlurEffectExample: View {
    var body: some View {
        Color.blue
            .frame(width: 100, height: 100)
            .variableBlur(maxRadius: 10, mask: Image(systemName: "plus"))
    }
}
