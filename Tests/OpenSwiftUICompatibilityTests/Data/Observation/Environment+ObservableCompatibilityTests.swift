//
//  Environment+ObservableCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import OpenSwiftUITestsSupport
import Testing

@MainActor
struct Environment_ObservableCompatibilityTests {
    @Observable
    class Model {
        var value: Int = 0

        init(value: Int) {
            self.value = value
        }
    }

    @Test
    func environmentObservableObject() async throws {
        struct ContentView: View {
            @State private var model = Model(value: 1)

            var body: some View {
                Subview()
                    .environment(model)
            }
        }

        struct Subview: View {
            @Environment(Model.self) var model

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

    @Test
    func environmentOptionalObservableObject() async throws {
        struct ContentView: View {
            @State private var model: Model? = nil

            var body: some View {
                Subview()
                    .environment(model)
            }
        }

        struct Subview: View {
            @Environment(Model.self) var model: Model?

            var body: some View {
                Color.red
                    .onAppear {
                        #expect(model == nil)
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
