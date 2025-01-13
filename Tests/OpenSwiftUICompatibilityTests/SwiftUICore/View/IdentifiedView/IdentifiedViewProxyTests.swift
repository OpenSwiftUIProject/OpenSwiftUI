//
//  IdentifiedViewProxyTests.swift
//  OpenSwiftUICompatibilityTests

import Testing
#if os(iOS)
import UIKit
#endif

@MainActor
struct IdentifiedViewProxyTests {
    @Test
    func boundingRect() async {
        #if os(iOS) && OPENSWIFTUI_COMPATIBILITY_TEST // FIXME: add _identified modifier
        let identifier = "Test"
        let hosting = UIHostingController(rootView: AnyView(EmptyView())._identified(by: identifier))
        await confirmation { @MainActor confirmation in
            hosting._forEachIdentifiedView { proxy in
                confirmation()
                #expect(proxy.identifier == AnyHashable(identifier))
                #expect(proxy.boundingRect == .zero)
            }
        }
        #endif
    }
}
