//
//  PlatformHostingControllerHelper.swift
//  OpenSwiftUITestsSupport

#if canImport(Darwin)
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension PlatformHostingController {
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

// FIXME: A workaround to bypass the Issue #87
package func workaroundIssue87(_ vc: PlatformViewController) {
    #if OPENSWIFTUI
    // TODO: Use swift-test exist test feature to detect the crash instead or sliently workaroun it
    CrashWorkaround.shared.objects.append(vc)
    #endif
}

private final class CrashWorkaround {
    private init() {}
    static let shared = CrashWorkaround()
    var objects: [Any?] = []
}
#endif
