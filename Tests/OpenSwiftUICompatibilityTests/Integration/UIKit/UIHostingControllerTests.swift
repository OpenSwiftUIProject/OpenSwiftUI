//
//  UIHostingControllerTests.swift
//  OpenSwiftUICompatibilityTests

#if os(iOS)
import Testing
import UIKit

@MainActor
struct UIHostingControllerTests {
    @Test(
        "Attribute setter crash for basic AnyView",
        .bug("https://github.com/OpenSwiftUIProject/OpenGraph/issues/58", relationship: .verifiesFix)
    )
    func testBasicAnyView() throws {
        struct ContentView: View {
            var body: some View {
                AnyView(EmptyView())
            }
        }
        let vc = UIHostingController(rootView: ContentView())
        vc.triggerLayout()
        workaroundIssue87(vc)
    }

    @Test(
        "BodyAccessor crash for non empty View instance",
        .bug("#81", relationship: .verifiesFix)
    )
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
}
#endif
