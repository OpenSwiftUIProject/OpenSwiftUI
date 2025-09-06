//
//  ObservationUtilsCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import OpenSwiftUITestsSupport
import Testing

@MainActor
struct ObservationUtilsCompatibilityTests {
    @Observable
    class Model {
        var showRed = false
    }

    struct ContentView: View {
        let confirmation: Confirmation
        var continuation: UnsafeContinuation<Void, Never>

        @State private var model = Model()

        private var showRed: Bool {
            get { model.showRed }
            nonmutating set { model.showRed = newValue }
        }

        var body: some View {
            let _ = confirmation()
            Color(platformColor: showRed ? .red : .blue)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        if model.showRed {
                            continuation.resume()
                        } else {
                            showRed.toggle()
                        }
                    }
                }
                .id(showRed)
        }
    }

    @Test
    func bodyTrigger() async throws {
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
