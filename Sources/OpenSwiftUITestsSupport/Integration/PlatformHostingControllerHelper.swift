//
//  PlatformHostingControllerHelper.swift
//  OpenSwiftUITestsSupport

#if canImport(Darwin)
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension PlatformViewController {
    package func triggerLayout() {
        #if os(iOS)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.rootViewController = self
        window.makeKeyAndVisible()
        view.layoutIfNeeded()
        #else
        let window = NSWindow(
            contentRect: CGRect(x: 0, y: 0, width: 100, height: 100),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.contentViewController = self
        window.makeKeyAndOrderFront(nil)
        view.layoutSubtreeIfNeeded()
        #endif
    }
}
#endif
