//
//  AppearanceActionModifierCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import Testing

import Foundation
import OpenSwiftUITestsSupport

struct AppearanceActionModifierCompatibilityTests {
    @Test
    func appear() async throws {
        struct ContentView: View {
            var confirmation: Confirmation

            var body: some View {
                AnyView(EmptyView())
                    .onAppear {
                        confirmation()
                    }
            }
        }
        
        try await triggerLayoutWithWindow { confirmation in
            PlatformHostingController(
                rootView: ContentView(
                    confirmation: confirmation
                )
            )
        }
    }

    @Test
    func idTest() async throws {
        enum Helper {
            @MainActor
            static var result = ""
        }

        struct ContentView: View {
            @State private var toggle = false
            var continuation: UnsafeContinuation<Void, Never>

            var body: some View {
                Color.red
                    .onAppear {
                        if Helper.result.isEmpty {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                toggle.toggle()
                            }
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                continuation.resume()
                            }
                        }
                        Helper.result += "A"
                        Helper.result += toggle ? "T" : "F"
                    }
                    .onDisappear {
                        Helper.result += "D"
                        Helper.result += toggle ? "T" : "F"
                    }
                    .id(toggle)
            }
        }

        try await triggerLayoutWithWindow { continuation in
            PlatformHostingController(
                rootView: ContentView(
                    continuation: continuation
                )
            )
        }
        await #expect(Helper.result == "AFATDTDT")
    }

    @Test("idTest with identity transition")
    func idTestWithIdentityTransition() async throws {
        enum Helper {
            @MainActor
            static var result = ""
        }

        struct ContentView: View {
            @State private var toggle = false
            var continuation: UnsafeContinuation<Void, Never>

            var body: some View {
                Color.red
                    .onAppear {
                        if Helper.result.isEmpty {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                toggle.toggle()
                            }
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                continuation.resume()
                            }
                        }
                        Helper.result += "A"
                        Helper.result += toggle ? "T" : "F"
                    }
                    .onDisappear {
                        Helper.result += "D"
                        Helper.result += toggle ? "T" : "F"
                    }
                    .transition(.identity)
                    .id(toggle)
            }
        }

        try await triggerLayoutWithWindow { continuation in
            PlatformHostingController(
                rootView: ContentView(
                    continuation: continuation
                )
            )
        }
        await #expect(Helper.result == "AFDTATDT")
    }
}
