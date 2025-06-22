//
//  ConditionalContentExample.swift
//  HostingExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif
import Foundation

// FIXME
struct ConditionalContentExample: View {
    @State private var first = true

    var body: some View {
        if first {
            Color.red
            .onAppear {
                print("Red appear")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    first.toggle()
                }
            }
            .onDisappear {
                print("Red disappear")
            }
            .id(first)
        } else {
            Color.blue
                .onAppear {
                    print("Blue appear")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        first.toggle()
                    }
                }
                .onDisappear {
                    print("Blue disappear")
                }
        }
    }
}
