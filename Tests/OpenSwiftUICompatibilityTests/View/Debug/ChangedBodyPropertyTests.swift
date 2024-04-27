//
//  ChangedBodyPropertyTests.swift
//  OpenSwiftUICompatibilityTests

import Testing

#if os(iOS)
import UIKit
#endif

@MainActor
struct ChangedBodyPropertyTests {
    @available(iOS 15, *)
    @Test
    func zeroPropertyView() throws {
        struct ContentView: View {
            var body: some View {
                let _ = Self._printChanges() // ChangedBodyPropertyTests.ContentView: @self changed.
                AnyView(EmptyView())
            }
        }
        #if os(iOS)
        let vc = UIHostingController(rootView: ContentView())
        vc.triggerLayout()
        #endif
    }
    
    @available(iOS 15, *)
    @Test
    func propertyView() throws {
        struct ContentView: View {
            var name = ""
            var body: some View {
                let _ = Self._printChanges() // ChangedBodyPropertyTests.ContentView: @self changed.
                AnyView(EmptyView())
            }
        }
        #if os(iOS)
        let vc = UIHostingController(rootView: ContentView())
        vc.triggerLayout()
        #endif
    }
    
    @available(iOS 15, *)
    @Test
    func statePropertyView() throws {
        struct ContentView: View {
            @State var name = ""
            var body: some View {
                let _ = Self._printChanges() // ChangedBodyPropertyTests.ContentView: @self, @identity, _name changed.
                AnyView(EmptyView())
            }
        }
        #if os(iOS)
        let vc = UIHostingController(rootView: ContentView())
        vc.triggerLayout()
        #endif
    }
}
