//
//  IdentifiedViewProxyTests.swift
//  OpenSwiftUICompatibilityTests

import Testing
#if os(iOS)
import UIKit
#endif

struct IdentifiedViewProxyTests {
    static var expectedSize: Int { 0x128 }
    
    @Test
    func layout() {
        #expect(MemoryLayout<_IdentifiedViewProxy>.size == Self.expectedSize)
    }
    
    @Test
    @MainActor
    func boundingRect() async {
        #if os(iOS)
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
