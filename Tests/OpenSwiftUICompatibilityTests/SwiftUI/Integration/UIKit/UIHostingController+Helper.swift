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

// FIXME: A workaround to bypass the Issue #87
func workaroundIssue87(_ vc: UIViewController) {
    if compatibilityTestEnabled {
        return
    } else {
        // TODO: Use swift-test exist test feature to detect the crash instead or sliently workaroun it
        CrashWorkaround.shared.objects.append(vc)
    }
}

private final class CrashWorkaround {
    private init() {}
    static let shared = CrashWorkaround()
    var objects: [Any?] = []
}

#endif
