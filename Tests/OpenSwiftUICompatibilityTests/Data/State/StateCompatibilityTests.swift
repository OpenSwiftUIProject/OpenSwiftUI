//
//  StateCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import Testing
import OpenSwiftUITestsSupport

struct StateCompatibilityTests {
    @Test
    func appear() async throws {
        struct ContentView: View {
            var confirmation: Confirmation

            @State private var toggle = false
            
            var body: some View {
                AnyView(EmptyView())
                    .onAppear {
                        toggle.toggle()
                        if toggle {
                            confirmation()
                        }
                    }
            }
        }
        
        try await triggerLayoutWithWindow { confirmation in
            PlatformHostingController(
                rootView: ContentView(
                    confirmation: confirmation
                )
            )
        }
    }
}
