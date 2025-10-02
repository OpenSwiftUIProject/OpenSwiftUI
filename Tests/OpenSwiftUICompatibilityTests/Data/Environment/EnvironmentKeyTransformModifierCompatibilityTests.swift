//
//  EnvironmentKeyTransformModifierCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import OpenSwiftUITestsSupport
import Testing

extension EnvironmentValues {
    @Entry fileprivate var customValue = 0
}

@MainActor
struct EnvironmentKeyTransformModifierCompatibilityTests {
    @Test
    func environmentKeyTransform() async throws {
        struct ContentView: View {
            var body: some View {
                Subview()
                    .transformEnvironment(\.customValue) { $0 = 1 }
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
