//
//  EnvironmentObjectCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import OpenSwiftUITestsSupport
import Testing

@MainActor
struct EnvironmentObjectCompatibilityTests {
    final class Model: ObservableObject {
        var value: Int = 0

        init(value: Int) {
            self.value = value
        }
    }

    @Test
    func environmentObject() async throws {
        struct ContentView: View {
            @State private var model = Model(value: 1)

            var body: some View {
                Subview()
                    .environmentObject(model)
            }
        }

        struct Subview: View {
            @EnvironmentObject private var model: Model

            var body: some View {
                Color.red
                    .onAppear {
                        #expect(model.value == 1)
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
