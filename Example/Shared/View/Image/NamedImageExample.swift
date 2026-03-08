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
