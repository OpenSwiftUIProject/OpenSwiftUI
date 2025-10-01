//
//  StateCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import Testing
import OpenSwiftUITestsSupport

struct StateCompatibilityTests {
    @Test
    func appear() async throws {
        struct ContentView: View {
            var continuation: UnsafeContinuation<Void, Never>

            @State private var toggle = false
            
            var body: some View {
                AnyView(EmptyView())
                    .onAppear {
                        toggle.toggle()
                        if toggle {
                            continuation.resume()
                        }
                    }
            }
        }
        
        try await triggerLayoutWithWindow { continuation in
            PlatformHostingController(
                rootView: ContentView(
                    continuation: continuation
                )
            )
        }
    }
}
