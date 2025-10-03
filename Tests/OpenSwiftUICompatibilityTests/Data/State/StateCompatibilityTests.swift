//
//  StateCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import Testing
import OpenSwiftUITestsSupport

@MainActor
struct StateCompatibilityTests {
    @Test
    func appear() async throws {
        struct ContentView: View {
            var continuation: UnsafeContinuation<Void, Never>

            @State private var toggle = false
            
            var body: some View {
                AnyView(EmptyView())
                    .onAppear {
                        toggle.toggle()
                        if toggle {
                            continuation.resume()
                        }
                    }
            }
        }
        
        try await triggerLayoutWithWindow { continuation in
            PlatformHostingController(
                rootView: ContentView(
                    continuation: continuation
                )
            )
        }
    }

    @Test("StoredLocationBase.BeginUpdate.removeLast verify")
    func nestedStateUpdate() async throws {
        @MainActor
        enum Helper {
            static var values: [Int] = []
            static var valueChanges: [[Int]] = []
        }

        struct ContentView: View {
            @State private var value = 0

            var body: some View {
                let _ = Helper.values.append(value)
                Color.white
                    .onAppear {
                        value = 1
                        value = 2
                        withAnimation {
                            value = 3
                            value = 4
                        }
                    }
                    .onChange(of: value) { oldValue, newValue in
                        Helper.valueChanges.append([oldValue, newValue])
                    }
            }
        }

        try await triggerLayoutWithWindow(expectedCount: 0) { _ in
            PlatformHostingController(
                rootView: ContentView()
            )
        }
        #expect(Helper.values == [0, 2, 4])
        #expect(Helper.valueChanges == [[0, 2], [2, 4]])
    }
}
