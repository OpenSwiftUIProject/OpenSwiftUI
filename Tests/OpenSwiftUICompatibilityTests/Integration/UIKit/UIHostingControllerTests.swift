//
//  UIHostingControllerTests.swift
//  OpenSwiftUICompatibilityTests

#if os(iOS)
import Testing
import UIKit

@MainActor
struct UIHostingControllerTests {
    @Test(
        .bug(
            "https://github.com/OpenSwiftUIProject/OpenGraph/issues/",
            id: 58,
            "[verifiesFix]: Attribute setter crash for basic AnyView"
        )
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
        .bug(
            "https://github.com/OpenSwiftUIProject/OpenGraph/issues/",
            id: 81,
            "[verifiesFix]: BodyAccessor crash for non empty View instance"
        )
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
