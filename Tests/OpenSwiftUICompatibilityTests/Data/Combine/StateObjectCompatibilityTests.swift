//
//  StateObjectCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import Testing
import OpenSwiftUITestsSupport

@MainActor
struct StateObjectCompatibilityTests {
    @MainActor
    enum Count {
        static var contentBody: Int = 0
        static var subviewBody: Int = 0
    }

    class Model: ObservableObject {
        @Published var t1 = false
        var t2 = false
    }

    @Observable
    class Model2 {
        var t1 = false
        @ObservationIgnored var t2 = false
    }

    struct Subview: View {
        var condition: Bool

        var body: some View {
            let _ = {
                Count.subviewBody += 1
            }()
            Color(condition ? .red : .blue)
        }
    }

    @Test
    func stateObjectChangePublishValue() async throws {
        defer {
            Count.contentBody = 0
            Count.subviewBody = 0
        }
        struct ContentView: View {
            @StateObject private var model = Model()
            var body: some View {
                let _ = {
                    Count.contentBody += 1
                }()
                VStack {
                    Subview(condition: model.t1)
                    Subview(condition: model.t2)
                }.onAppear {
                    model.t1.toggle()
                }
            }
        }
        try await triggerLayoutWithWindow(expectedCount: 0) { _ in
            PlatformHostingController(
                rootView: ContentView()
            )
        }
        #expect(Count.contentBody == 2)
        #expect(Count.subviewBody == 3)
    }

    @Test
    func stateObjectChangeNonPublishValue() async throws {
        defer {
            Count.contentBody = 0
            Count.subviewBody = 0
        }
        struct ContentView: View {
            @StateObject private var model = Model()
            var body: some View {
                let _ = {
                    Count.contentBody += 1
                }()
                VStack {
                    Subview(condition: model.t1)
                    Subview(condition: model.t2)
                }.onAppear {
                    model.t2.toggle()
                }
            }
        }
        try await triggerLayoutWithWindow(expectedCount: 0) { _ in
            PlatformHostingController(
                rootView: ContentView()
            )
        }
        #expect(Count.contentBody == 1)
        #expect(Count.subviewBody == 2)
    }

    @Test
    func observableMacroTrackedValue() async throws {
        defer {
            Count.contentBody = 0
            Count.subviewBody = 0
        }
        struct ContentView: View {
            @State private var model = Model2()
            var body: some View {
                let _ = {
                    Count.contentBody += 1
                }()
                VStack {
                    Subview(condition: model.t1)
                    Subview(condition: model.t2)
                }.onAppear {
                    model.t1.toggle()
                }
            }
        }
        try await triggerLayoutWithWindow(expectedCount: 0) { _ in
            PlatformHostingController(
                rootView: ContentView()
            )
        }
        #expect(Count.contentBody == 2)
        #expect(Count.subviewBody == 3)
    }

    @Test
    func observableMacroIgnoredValue() async throws {
        defer {
            Count.contentBody = 0
            Count.subviewBody = 0
        }
        struct ContentView: View {
            @State private var model = Model2()
            var body: some View {
                let _ = {
                    Count.contentBody += 1
                }()
                VStack {
                    Subview(condition: model.t1)
                    Subview(condition: model.t2)
                }.onAppear {
                    model.t2.toggle()
                }
            }
        }
        try await triggerLayoutWithWindow(expectedCount: 0) { _ in
            PlatformHostingController(
                rootView: ContentView()
            )
        }
        #expect(Count.contentBody == 1)
        #expect(Count.subviewBody == 2)
    }
}
