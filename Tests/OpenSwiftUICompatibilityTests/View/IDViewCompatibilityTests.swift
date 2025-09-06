//
//  IDViewCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import OpenSwiftUITestsSupport
import Testing

@MainActor
struct IDViewCompatibilityTests {
    @Test("onAppear will be called again when the view's id changes if id modifier is applied after onAppear modifier")
    func idAfterOnAppear() async throws {
        struct ContentView: View {
            let confirmation: Confirmation
            var continuation: UnsafeContinuation<Void, Never>

            @State private var showRed = false

            var body: some View {
                Color(platformColor: showRed ? .red : .blue)
                    .onAppear {
                        let _ = confirmation()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            if showRed {
                                continuation.resume()
                            } else {
                                showRed.toggle()
                            }
                        }
                    }
                    .id(showRed)
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

    @Test("onAppear will not be called again when the view's id changes if id modifier is applied before onAppear modifier")
    func idBeforeOnAppear() async throws {
        struct ContentView: View {
            let confirmation: Confirmation
            var continuation: UnsafeContinuation<Void, Never>

            @State private var showRed = false

            var body: some View {
                Color(platformColor: showRed ? .red : .blue)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            if showRed {
                                continuation.resume()
                            } else {
                                showRed.toggle()
                            }
                        }
                    }
                    .id(showRed)
                    .onAppear {
                        let _ = confirmation()
                    }
            }
        }
        try await triggerLayoutWithWindow(expectedCount: 1) { confirmation, continuation in
            PlatformHostingController(
                rootView: ContentView(
                    confirmation: confirmation,
                    continuation: continuation
                )
            )
        }
    }
}
