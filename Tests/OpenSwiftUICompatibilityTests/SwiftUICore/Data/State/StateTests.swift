//
//  StateTests.swift
//  OpenSwiftUICompatibilityTests

import Testing

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
