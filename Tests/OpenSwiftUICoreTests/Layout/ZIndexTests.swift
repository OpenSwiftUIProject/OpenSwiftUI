//
//  ZIndexTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing
import OpenGraphShims

@MainActor
struct ZIndexTests {
    @Test
    func indexOrder() {
        struct ContentView: View {
            var body: some View {
                Color.red
                    .zIndex(0.5)
            }
        }
        // TODO: Add a test helper to hook into makeViewList and retrieve the zIndex value to verify it
    }
}
