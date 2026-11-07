//
//  MaterialExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

// Examples from the Material documentation.

struct MaterialExample: View {
    var body: some View {
        ZStack {
            Color.teal
            Label("Flag", systemImage: "flag.fill")
                .padding()
                .background(.regularMaterial)
        }
    }
}

struct MaterialImageBackgroundExample: View {
    var body: some View {
        ZStack {
            // Use the bundled logo in place of the documentation's chili_peppers image.
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
            Label("Flag", systemImage: "flag.fill")
                .padding()
                .background(.regularMaterial)
        }
    }
}

struct MaterialShapeBackgroundExample: View {
    var body: some View {
        ZStack {
            Color.teal
            Label("Flag", systemImage: "flag.fill")
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview("Material: Color Background") {
    MaterialExample()
        .frame(width: 320, height: 240)
}

#Preview("Material: Image Background") {
    MaterialImageBackgroundExample()
        .frame(width: 320, height: 240)
}

#Preview("Material: Shape Background") {
    MaterialShapeBackgroundExample()
        .frame(width: 320, height: 240)
}
