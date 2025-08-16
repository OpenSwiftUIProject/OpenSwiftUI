//
//  PlatformHostingControllerHelper.swift
//  OpenSwiftUITestsSupport

#if canImport(Darwin)
#if os(iOS)
package import UIKit
#elseif os(macOS)
package import AppKit
#endif

package import Testing

extension PlatformViewController {
    // NOTE: Remember to withExtendedLifetime for window to ensure it is not deallocated duration animation or update.
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

@MainActor
package func triggerLayoutWithWindow(
    expectedCount: Int = 1,
    _ body: @escaping @MainActor (Confirmation) -> PlatformViewController
) async throws {
    var window: PlatformWindow!
    await confirmation(expectedCount: expectedCount) { confirmation in
        let vc = body(confirmation)
        vc.triggerLayout()
        window = vc.view.window
    }
    #if os(macOS)
    window.isReleasedWhenClosed = false
    window.close()
    #endif
    withExtendedLifetime(window) {}
}

@MainActor
package func triggerLayoutWithWindow(
    _ body: @escaping @MainActor (UnsafeContinuation<Void, Never>) -> PlatformViewController
) async throws {
    var window: PlatformWindow!
    await withUnsafeContinuation { continuation in
        let vc = body(continuation)
        vc.triggerLayout()
        window = vc.view.window
    }
    #if os(macOS)
    window.isReleasedWhenClosed = false
    window.close()
    #endif
    withExtendedLifetime(window) {}
}

@MainActor
package func triggerLayoutWithWindow(
    expectedCount: Int = 1,
    _ body: @escaping @MainActor (Confirmation, UnsafeContinuation<Void, Never>) -> PlatformViewController
) async throws {
    var window: PlatformWindow!
    await confirmation(expectedCount: expectedCount) { @MainActor confirmation in
        await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
            let vc = body(confirmation, continuation)
            vc.triggerLayout()
            window = vc.view.window
        }
    }
    #if os(macOS)
    window.isReleasedWhenClosed = false
    window.close()
    #endif
    withExtendedLifetime(window) {}
}

@MainActor
package func triggerLayoutWithWindow(
    expectedCount: some RangeExpression<Int> & Sendable & Sequence<Int>,
    _ body: @escaping @MainActor (Confirmation, UnsafeContinuation<Void, Never>) -> PlatformViewController
) async throws {
    var window: PlatformWindow!
    await confirmation(expectedCount: expectedCount) { @MainActor confirmation in
        await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
            let vc = body(confirmation, continuation)
            vc.triggerLayout()
            window = vc.view.window
        }
    }
    #if os(macOS)
    window.isReleasedWhenClosed = false
    window.close()
    #endif
    withExtendedLifetime(window) {}
}

#endif
