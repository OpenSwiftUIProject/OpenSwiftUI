//
//  ToggleExample.swift
//  SharedExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct ToggleExample: View {
    @State private var toggle = false

    var body: some View {
        Toggle(isOn: $toggle) {
            Color.red
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                toggle.toggle()
            }
        }
    }
}
