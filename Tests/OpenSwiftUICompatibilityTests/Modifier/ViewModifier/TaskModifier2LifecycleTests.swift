//
//  TaskModifier2LifecycleTests.swift
//  OpenSwiftUICompatibilityTests

import OpenSwiftUITestsSupport
import Testing

@MainActor
@available(OpenSwiftUI_v7_0, *)
struct TaskModifier2LifecycleTests {
    @Test
    func taskStartsOnAppear() async throws {
        struct ContentView: View {
            let confirmation: Confirmation
            var continuation: UnsafeContinuation<Void, Never>

            var body: some View {
                Color.red.modifier(_TaskModifier2(
                    name: "start",
                    executorPreference: nil,
                    priority: .userInitiated,
                    action: {
                        confirmation()
                        continuation.resume()
                    }
                ))
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
    func taskCancelsAndRestartsOnIDChange() async throws {
        // Resumes the continuation only after the id-0 task has observed
        // cancellation and the id-1 task has started, so a missing cancel()
        // hangs the test instead of passing it.
        final class Gate: @unchecked Sendable {
            private let lock = NSLock()
            private var firstCancelled = false
            private var secondStarted = false
            func mark(firstCancelled f: Bool = false, secondStarted s: Bool = false, then resume: () -> Void) {
                lock.lock()
                firstCancelled = firstCancelled || f
                secondStarted = secondStarted || s
                let done = firstCancelled && secondStarted
                lock.unlock()
                if done { resume() }
            }
        }

        struct ContentView: View {
            @State private var value = 0
            let gate = Gate()
            let confirmation: Confirmation
            var continuation: UnsafeContinuation<Void, Never>

            var body: some View {
                Color.red
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            value += 1
                        }
                    }
                    .modifier(_TaskValueModifier2(
                        id: value,
                        name: "restart",
                        executorPreference: nil,
                        priority: .userInitiated,
                        action: { [value, gate] in
                            confirmation()
                            if value == 0 {
                                // Stays alive until the id change cancels it.
                                while !Task.isCancelled {
                                    try? await Task.sleep(nanoseconds: 10_000_000)
                                }
                                gate.mark(firstCancelled: true) { continuation.resume() }
                            } else {
                                gate.mark(secondStarted: true) { continuation.resume() }
                            }
                        }
                    ))
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
