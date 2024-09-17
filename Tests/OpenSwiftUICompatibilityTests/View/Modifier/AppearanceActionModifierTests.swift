//
//  AppearanceActionModifierTests.swift
//  OpenSwiftUICompatibilityTests

import Testing

#if canImport(Darwin)
struct AppearanceActionModifierTests {
    @Test
    func appear() async throws {
        guard #unavailable(iOS 18) else {
            withKnownIssue {
                Issue.record("Known crash issue on iOS 18")
            }
            return
        }
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
    
    // TODO: Add disappear support and test case
}
#endif
