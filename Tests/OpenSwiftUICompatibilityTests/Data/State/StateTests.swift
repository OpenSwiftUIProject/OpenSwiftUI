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
        await confirmation { @MainActor confirmation in
            let vc = PlatformHostingController(rootView: ContentView(confirmation: confirmation))
            vc.triggerLayout()
            workaroundIssue87(vc)
        }
    }
}
#endif
