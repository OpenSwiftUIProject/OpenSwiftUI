//
//  AnimationCompletionCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import Testing
import OpenSwiftUITestsSupport

@MainActor
struct AnimationCompletionCompatibilityTests {
    @Test(.disabled {
        #if os(macOS)
        // FIXME: macOS Animation is not supported yet
        true
        #else
        false
        #endif
    })
    func logicalAndRemovedComplete() async throws {
        @MainActor
        enum Helper {
            static var values: [Int] = []
        }

        struct ContentView: View {
            let confirmation: Confirmation
            var continuation: UnsafeContinuation<Void, Never>

            @State private var showRed = false
            @State private var scale = 1.0

            var body: some View {
                Color(platformColor: showRed ? .red : .blue)
                    .frame(width: 100 * scale, height: 100 * scale)
                    .onAppear {
                        let animation = Animation.linear(duration: 5)
                            .logicallyComplete(after: 1)
                        withAnimation(animation, completionCriteria: .logicallyComplete) {
                            showRed.toggle()
                        } completion: {
                            Helper.values.append(1)
                            confirmation()
                        }
                        withAnimation(animation, completionCriteria: .removed) {
                            scale = 2.0
                        } completion: {
                            Helper.values.append(2)
                            confirmation()
                            continuation.resume()
                        }
                    }
            }
        }
        // Sometimes CI will fail for this test
        await withKnownIssue(isIntermittent: true) {
            try await triggerLayoutWithWindow(expectedCount: 2) { confirmation, continuation in
                PlatformHostingController(
                    rootView: ContentView(
                        confirmation: confirmation,
                        continuation: continuation
                    )
                )
            }
            #expect(Helper.values == [1, 2])
        }
    }
}
