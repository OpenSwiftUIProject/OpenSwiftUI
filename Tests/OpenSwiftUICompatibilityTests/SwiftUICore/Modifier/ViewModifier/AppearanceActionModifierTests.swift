//
//  AppearanceActionModifierTests.swift
//  OpenSwiftUICompatibilityTests

#if canImport(Darwin)
import Testing

import Foundation
#if os(iOS)
import UIKit
#endif

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

        #if os(iOS)
        await confirmation { @MainActor confirmation in
            let vc = UIHostingController(rootView: ContentView(confirmation: confirmation))
            vc.triggerLayout()
            workaroundIssue87(vc)
        }
        #endif
    }

    #if !DEBUG || compiler(>=6.1)
    // For Xcode 16.3-/Swift 6.1-, Xcode will infer OpaqueTypeErasure to be true which will make some difference to the result.
    // And there is no way to opt-out it for package yet.
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            toggle.toggle()
                        }
                    }
                    .onDisappear {
                        Helper.result += "D"
                    }
                    .id(toggle)
            }
        }
        #if os(iOS)
        let vc = UIHostingController(rootView: ContentView())
        vc.triggerLayout()
        workaroundIssue87(vc)
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        #expect(Helper.result.hasPrefix("AAD"))
        #endif
    }
    #endif
}
#endif
