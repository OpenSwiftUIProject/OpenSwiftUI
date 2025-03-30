//
//  AppearanceActionModifierExample.swift
//  HostingExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif
import Foundation

struct AppearanceActionModifierExample: View {
    @State private var first = true

    var color: Color {
        #if os(macOS) // TODO:
        Color.red
        #else
        Color(uiColor: first ? .red : .blue)
        #endif
    }

    var body: some View {
        color
            .onAppear {
                print("View appear")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    first.toggle()
                }
            }
            .onDisappear {
                print("View disappear")
            }
            .id(first)
    }
}
