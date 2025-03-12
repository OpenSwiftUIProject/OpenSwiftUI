//
//  NamespaceTests.swift
//  OpenSwiftUICoreTests

import Testing
import OpenSwiftUICore
import Foundation

struct NamespaceTests {
    @Test
    func example() {
        struct ContentView: View {
            @State private var first = false
            @Namespace private var id

            var body: some View {
                Color(uiColor: first ? .red : .blue)
                    .onAppear {
                        print("View appear")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            first.toggle()
                        }
                    }
                    .onDisappear {
                        print("Red disappear")
                    }
                    .id(first)
            }
        }
    }
}
