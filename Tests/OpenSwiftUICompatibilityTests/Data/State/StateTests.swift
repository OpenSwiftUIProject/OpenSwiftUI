//
//  StateTests.swift
//  OpenSwiftUICompatibilityTests

import Testing
import OpenSwiftUITestsSupport

#if canImport(Darwin)
struct StateTests {
    @Test
    func appear() async throws {
        struct ContentView: View {
            var confirmation: Confirmation

            @State private var toggle = false
            
            var body: some View {
                AnyView(EmptyView())
                    .onAppear {
                        toggle.toggle()
                        if toggle {
                            confirmation()
                        }
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
}
#endif
