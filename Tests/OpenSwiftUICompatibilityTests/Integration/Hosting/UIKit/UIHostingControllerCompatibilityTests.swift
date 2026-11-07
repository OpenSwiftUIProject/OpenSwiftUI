//
//  UIHostingControllerCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

#if os(visionOS)
import Testing
import UIKit

@MainActor
struct UIHostingControllerCompatibilityTests {
    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func visionBackgroundIsTransparent(style: UIUserInterfaceStyle) {
        let controller = UIHostingController(rootView: EmptyView())
        controller.overrideUserInterfaceStyle = style
        controller.loadViewIfNeeded()

        #expect(controller.view.traitCollection.userInterfaceIdiom == .vision)
        #expect(controller.view.backgroundColor == nil)
    }
}
#endif
