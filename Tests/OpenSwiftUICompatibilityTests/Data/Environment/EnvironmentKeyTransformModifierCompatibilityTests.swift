//
//  EnvironmentKeyTransformModifierCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import OpenSwiftUITestsSupport
import Testing

extension EnvironmentValues {
    @Entry fileprivate var customValue = 0
    @Entry fileprivate var customValue2 = 0
}

@Observable
private final class Model {
    var value = 0
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

    @Test
    func environmentKeyTransformDifferentKeyPath() async throws {
        @MainActor
        enum Count {
            static var contentBody: Int = 0
            static var subviewBody: Int = 0
        }

        struct ContentView: View {
            @State private var model = Model()

            var body: some View {
                let _ = {
                    Count.contentBody += 1
                }()
                Subview()
                    .transformEnvironment(model.value == 0 ? \.customValue : \.customValue2) {
                        $0 = model.value
                    }
                    .onAppear {
                        model.value = 2
                    }
            }
        }

        struct Subview: View {
            @Environment(\.customValue) private var value
            @Environment(\.customValue2) private var value2

            var body: some View {
                let _ = {
                    Count.subviewBody += 1
                    switch Count.subviewBody {
                    case 1:
                        #expect(value == 0)
                        #expect(value2 == 0)
                    case 2:
                        #expect(value == 0)
                        #if OPENSWIFTUI
                        #expect(value2 == 2)
                        #else
                        // SwiftUI known implementation issue
                        withKnownIssue {
                            #expect(value2 == 2)
                        }
                        #expect(value2 == 0)
                        #endif
                    default:
                        Issue.record()
                    }
                }()
                Color.red
            }
        }
        try await triggerLayoutWithWindow(expectedCount: 0) { _ in
            PlatformHostingController(
                rootView: ContentView()
            )
        }
        #expect(Count.contentBody == 2)
        #expect(Count.subviewBody == 2)
    }
}
