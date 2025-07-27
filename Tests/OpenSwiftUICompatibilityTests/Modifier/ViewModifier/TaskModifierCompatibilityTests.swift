//
//  TaskModifierCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import OpenSwiftUITestsSupport
import Testing

@MainActor
struct TaskModifierCompatibilityTests {
    @Test
    func taskWithoutID() async throws {
        struct ContentView: View {
            let confirmation: Confirmation
            var continuation: UnsafeContinuation<Void, Never>

            var body: some View {
                Color.red
                    .task {
                        confirmation()
                        continuation.resume()
                    }
            }
        }

        try await triggerLayoutWithWindow { confirmation, continuation in
            PlatformHostingController(
                rootView: ContentView(
                    confirmation: confirmation,
                    continuation: continuation
                )
            )
        }
    }

    @Test
    func taskWithID() async throws {
        struct ContentView: View {
            @State private var value = 0
            let confirmation: Confirmation
            var continuation: UnsafeContinuation<Void, Never>

            var body: some View {
                Color.red
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            value += 1
                        }
                    }
                    .task(id: value) {
                        confirmation()
                        if value == 1 {
                            continuation.resume()
                        }
                    }
            }
        }
        
        try await triggerLayoutWithWindow(expectedCount: 2) { confirmation, continuation in
            PlatformHostingController(
                rootView: ContentView(
                    confirmation: confirmation,
                    continuation: continuation
                )
            )
        }
    }
}
