//
//  UIKitPrivateTests.swift
//  OpenSwiftUI_SPITests

#if canImport(UIKit)
import COpenSwiftUI
import UIKit
import Testing

@MainActor
struct UIKitPrivateTests {
    @Test
    func application() {
        let app = UIApplication.shared
        let name = "ATest"
        app.startedTest(name)
        app.finishedTest(name)
        app.failedTest(name, withFailure: nil)
        #expect(app._launchTestName() == nil)
    }

    @Test
    func view() {
        let view = UIView()
        #expect(view._shouldAnimateProperty(withKey: "frame") == false)
        #expect(view._shouldAnimateProperty(withKey: "alpha") == false)

        view._setFocusInteractionEnabled(true)
    }

    @Test
    func viewController() {
        let controller = UIViewController()
        #expect(controller._canShowWhileLocked == true)
    }
}
#endif
