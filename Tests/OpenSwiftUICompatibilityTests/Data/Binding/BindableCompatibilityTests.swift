//
//  BindableCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import OpenSwiftUITestsSupport
import Testing

@Observable
private final class Model {
    var value = 0

    init(value: Int = 0) {
        self.value = value
    }
}

@MainActor
struct BindableCompatibilityTests {
    @Test
    func bindableExample() async throws {
        struct ContentView: View {
            private let model = Model()

            var body: some View {
                let m = Bindable(model)
                Subview(value: m.value)
                    .onAppear {
                        #expect(model.value == 1)
                    }
            }
        }

        struct Subview: View {
            @Binding var value: Int

            var body: some View {
                Color.red
                    .onAppear {
                        value = 1
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
