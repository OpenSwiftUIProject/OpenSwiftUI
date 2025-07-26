//
//  AppearanceActionModifierCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

#if canImport(Darwin)
import Testing

import Foundation
import OpenSwiftUITestsSupport

@MainActor
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
        var vc: PlatformViewController!
        await confirmation { @MainActor confirmation in
            vc = PlatformHostingController(rootView: ContentView(confirmation: confirmation))
            vc.triggerLayout()
        }
        withExtendedLifetime(vc) {}
    }

    @Test
    func idTest() async throws {
        enum Helper {
            @MainActor
            static var result = ""
        }

        struct ContentView: View {
            @State private var toggle = false

            var body: some View {
                Color.red
                    .onAppear {
                        Helper.result += "A"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            toggle.toggle()
                        }
                    }
                    .onDisappear {
                        Helper.result += "D"
                    }
                    .id(toggle)
            }
        }
        let vc = PlatformHostingController(rootView: ContentView())
        vc.triggerLayout()
        #expect(Helper.result.hasPrefix("A"))
        var timeout = 5
        while !Helper.result.hasPrefix("AAD"), timeout > 0 {
            try await Task.sleep(for: .seconds(1))
            timeout -= 1
        }
        withExtendedLifetime(vc) {}
    }
}
#endif
