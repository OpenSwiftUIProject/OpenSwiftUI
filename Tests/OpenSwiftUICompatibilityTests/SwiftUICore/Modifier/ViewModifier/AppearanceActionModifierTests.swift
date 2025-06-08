//
//  AppearanceActionModifierTests.swift
//  OpenSwiftUICompatibilityTests

#if canImport(Darwin)
import Testing

import Foundation
import OpenSwiftUITestsSupport

@MainActor
struct AppearanceActionModifierTests {
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
        await confirmation { @MainActor confirmation in
            let vc = PlatformHostingController(rootView: ContentView(confirmation: confirmation))
            vc.triggerLayout()
            workaroundIssue87(vc)
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
        workaroundIssue87(vc)
        #expect(Helper.result.hasPrefix("A"))
        var timeout = 5
        while !Helper.result.hasPrefix("AAD") && timeout > 0{
            try await Task.sleep(for: .seconds(1))
            timeout -= 1
        }
        #expect(Helper.result.hasPrefix("AAD"))
    }
}
#endif
