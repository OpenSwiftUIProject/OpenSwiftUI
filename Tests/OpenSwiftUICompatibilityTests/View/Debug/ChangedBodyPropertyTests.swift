//
//  ChangedBodyPropertyTests.swift
//  OpenSwiftUICompatibilityTests

#if canImport(Darwin) && !OPENSWIFTUI_SWIFT_LOG
import Testing
import OSLog
import OpenSwiftUITestsSupport

@MainActor
struct ChangedBodyPropertyTests {
    @available(iOS 15, macOS 12, *)
    private func verifyLog(expected: String) throws {
        let store = try OSLogStore(scope: .currentProcessIdentifier)
        let position = store.position(timeIntervalSinceLatestBoot: 0)
        let entries = try store
            .getEntries(at: position) // getEntries's with and at param is not respected on iOS, so I have to use last then.
            .compactMap { $0 as? OSLogEntryLog }
            #if OPENSWIFTUI
            .filter { $0.subsystem == "org.OpenSwiftUIProject.OpenSwiftUI" && $0.category == "Changed Body Properties" }
            #else
            .filter { $0.subsystem == "com.apple.SwiftUI" && $0.category == "Changed Body Properties" }
            #endif
            .map { $0.composedMessage }
        #expect(entries.last == expected)
    }
    
    #if !OPENSWIFTUI
    @available(iOS 17.1, macOS 14.1, *)
    #endif
    @Test
    func zeroPropertyView() throws {
        struct ContentView: View {
            var body: some View {
                let _ = Self._logChanges()
                AnyView(EmptyView())
            }
        }
        let vc = PlatformHostingController(rootView: ContentView())
        vc.triggerLayout()
        try verifyLog(expected: "ChangedBodyPropertyTests.ContentView: @self changed.")
        withExtendedLifetime(vc) {}
    }
    
    #if !OPENSWIFTUI
    @available(iOS 17.1, macOS 14.1, *)
    #endif
    @Test
    func propertyView() throws {
        struct ContentView: View {
            var name = ""
            var body: some View {
                let _ = Self._logChanges()
                AnyView(EmptyView())
            }
        }
        let vc = PlatformHostingController(rootView: ContentView())
        vc.triggerLayout()
        try verifyLog(expected: "ChangedBodyPropertyTests.ContentView: @self changed.")
        withExtendedLifetime(vc) {}
    }
    
    #if !OPENSWIFTUI
    @available(iOS 17.1, macOS 14.1, *)
    #endif
    @Test
    func statePropertyView() throws {
        struct ContentView: View {
            @State var name = ""
            var body: some View {
                let _ = Self._logChanges()
                AnyView(EmptyView())
            }
        }
        let vc = PlatformHostingController(rootView: ContentView())
        vc.triggerLayout()
        try verifyLog(expected: "ChangedBodyPropertyTests.ContentView: @self, @identity, _name changed.")
        withExtendedLifetime(vc) {}
    }
}
#endif
