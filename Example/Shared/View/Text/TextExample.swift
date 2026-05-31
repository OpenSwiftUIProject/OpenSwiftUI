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
            Text("Hello World")
            Text("From OpenSwiftUI")
                .foregroundStyle(.red)
        }
    }
}
