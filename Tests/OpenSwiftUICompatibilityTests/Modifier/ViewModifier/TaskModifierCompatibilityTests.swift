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

        var vc: PlatformViewController!
        await confirmation(expectedCount: 1) { @MainActor confirmation in
            await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
                vc = PlatformHostingController(
                    rootView: ContentView(
                        confirmation: confirmation,
                        continuation: continuation
                    )
                )
                vc.triggerLayout()
            }
        }
        withExtendedLifetime(vc) {}
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

        var vc: PlatformViewController!
        await confirmation(expectedCount: 2) { @MainActor confirmation in
            await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
                vc = PlatformHostingController(
                    rootView: ContentView(
                        confirmation: confirmation,
                        continuation: continuation
                    )
                )
                vc.triggerLayout()
            }
        }
        withExtendedLifetime(vc) {}
    }
}
