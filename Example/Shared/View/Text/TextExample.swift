//
//  TextExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct TextExample: View {
    var body: some View {
        VStack {
            Text(verbatim: "Hello World")
            Text(verbatim: "From OpenSwiftUI")
                .foregroundStyle(.red)
        }
    }
}
