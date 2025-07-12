//
//  NamespaceExample.swift
//  SharedExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif
import Foundation

struct NamespaceExample: View {
    @State private var first = true
    @Namespace private var id

    var color: Color {
        #if os(macOS)
        Color.red
        #else

        Color(uiColor: first ? .red : .blue)
        #endif
    }

    var body: some View {
        color
            .onAppear {
                print("View appear \(id)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    first.toggle()
                }
            }
            .onDisappear {
                print("View disappear \(id)")
            }
            .id(first)
    }
}
