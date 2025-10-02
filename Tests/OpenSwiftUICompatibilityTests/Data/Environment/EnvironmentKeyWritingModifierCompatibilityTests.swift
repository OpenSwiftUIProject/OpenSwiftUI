//
//  EnvironmentKeyWritingModifierCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import OpenSwiftUITestsSupport
import Testing

extension EnvironmentValues {
    @Entry fileprivate var customValue = 0
}

@MainActor
struct EnvironmentKeyWritingModifierCompatibilityTests {
    @Test
    func environmentKeyWriting() async throws {
        struct ContentView: View {
            var body: some View {
                Subview()
                    .environment(\.customValue, 1)
            }
        }

        struct Subview: View {
            @Environment(\.customValue) private var value

            var body: some View {
                Color.red
                    .onAppear {
                        #expect(value == 1)
                    }
            }
        }
        try await triggerLayoutWithWindow(expectedCount: 0) { _ in
            PlatformHostingController(
                rootView: ContentView()
            )
        }
    }
}
