//
//  UIHostingControllerTests.swift
//  OpenSwiftUICompatibilityTests

#if os(iOS)
import Testing
import UIKit

@MainActor
struct UIHostingControllerTests {
    @Test("BodyAccessor crash for non empty View instance", .bug("#81", relationship: .verifiesFix))
    func testBasicAnyViewWithProperty() throws {
        struct ContentView: View {
            var name = ""
            var body: some View {
                AnyView(EmptyView())
            }
        }
        let vc = UIHostingController(rootView: ContentView())
        vc.triggerLayout()
        workaroundIssue87(vc)
    }
    
    @Test("BodyAccessor crash for non empty View instance", .bug("#81", relationship: .verifiesFix))
    func basicAnyViewWithProperty() throws {
        struct ContentView: View {
            var name = ""
            var body: some View {
                AnyView(EmptyView())
            }
        }
        let vc = UIHostingController(rootView: ContentView())
        vc.triggerLayout()
        workaroundIssue87(vc)
    }
}
#endif
