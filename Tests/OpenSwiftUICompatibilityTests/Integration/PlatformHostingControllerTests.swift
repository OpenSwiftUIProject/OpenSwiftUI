//
//  PlatformHostingControllerTests.swift
//  OpenSwiftUICompatibilityTests

#if canImport(Darwin)
import Testing
import OpenSwiftUITestsSupport

@MainActor
struct PlatformHostingControllerTests {
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
        let vc = PlatformHostingController(rootView: ContentView())
        vc.triggerLayout()
        withExtendedLifetime(vc) {}
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
        let vc = PlatformHostingController(rootView: ContentView())
        vc.triggerLayout()
        withExtendedLifetime(vc) {}
    }
}
#endif
