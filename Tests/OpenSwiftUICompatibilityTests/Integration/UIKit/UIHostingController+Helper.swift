//
//  UIHostingController+Helper.swift
//  OpenSwiftUICompatibilityTests

#if os(iOS)
import UIKit

extension UIHostingController {
    func triggerLayout() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.rootViewController = self
        window.makeKeyAndVisible()
        view.layoutSubviews()
    }
}
#endif
