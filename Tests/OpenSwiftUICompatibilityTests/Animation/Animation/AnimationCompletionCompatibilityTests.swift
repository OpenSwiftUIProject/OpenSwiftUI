//
//  AnimationCompletionCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import Testing
import OpenSwiftUITestsSupport

@MainActor
struct AnimationCompletionCompatibilityTests {
    @Test
    func logicalAndRemovedComplete() async throws {
        @MainActor
        enum Helper {
            static var values: [Int] = []
        }

        struct ContentView: View {
            let confirmation: Confirmation
            var continuation: UnsafeContinuation<Void, Never>

            var body: some View {
                VStack {
                    LogicalCompletionView(confirmation: confirmation, continuation: continuation)
                    RemovedCompletionView(confirmation: confirmation, continuation: continuation)
                }
            }

            struct LogicalCompletionView: View {
                @State private var showRed = false

                let confirmation: Confirmation
                var continuation: UnsafeContinuation<Void, Never>

                var body: some View {
                    VStack {
                        Color(platformColor: showRed ? .red : .blue)
                            .onAppear {
                                let animation = Animation.linear(duration: 3)
                                    .logicallyComplete(after: 1)
                                withAnimation(animation, completionCriteria: .logicallyComplete) {
                                    showRed.toggle()
                                } completion: {
                                    Helper.values.append(1)
                                    confirmation()
                                }
                            }
                    }
                }
            }
            struct RemovedCompletionView: View {
                @State private var showRed = false

                let confirmation: Confirmation
                var continuation: UnsafeContinuation<Void, Never>

                var body: some View {
                    VStack {
                        Color(platformColor: showRed ? .red : .blue)
                            .onAppear {
                                let animation = Animation.linear(duration: 2)
                                withAnimation(animation, completionCriteria: .removed) {
                                    showRed.toggle()
                                } completion: {
                                    Helper.values.append(2)
                                    confirmation()
                                    continuation.resume()
                                }
                            }
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
