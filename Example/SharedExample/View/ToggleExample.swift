//
//  ToggleExample.swift
//  SharedExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct ToggleExample: View {
    // FIXME: Fix Representable update logic and add test case
    @State var toggle = false
    
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
