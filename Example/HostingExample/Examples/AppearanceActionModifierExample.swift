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

    var body: some View {
        Color(uiColor: first ? .red : .blue)
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
