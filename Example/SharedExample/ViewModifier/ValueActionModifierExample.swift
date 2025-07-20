//
//  ValueActionModifier.swift
//  SharedExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct ValueActionModifierExample: View {
    @State private var value = 0
    var body: some View {
        Color.red
            .onAppear {
                value = 1
                DispatchQueue.main.async {
                    value = 2
                }
            }
            .onChange(of: value) { newValue in
                print(newValue)
            }
    }
}
