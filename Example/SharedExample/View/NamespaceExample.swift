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

    var body: some View {
        Color(platformColor: first ? .red : .blue)
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
