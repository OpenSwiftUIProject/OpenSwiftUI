//
//  UXTestHost.swift
//  OpenSwiftUIUXTests

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import Foundation
import Hammer
#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif
import TestingHost

@MainActor
func withUXTestHost<Content: View>(
    of content: Content,
    _ body: @MainActor (UXTestHost) async throws -> Void
) async throws {
    #if os(macOS)
    let window = UXTestWindow.shared
    defer {
        window.makeFirstResponder(nil)
        window.contentViewController = nil
        window.contentView = nil
    }

    let controller = TestingHost.PlatformHostingController(rootView: content)
    // Keep the test surface fixed instead of adopting the content's ideal size.
    controller.sizingOptions = []
    let size = NSSize(width: 400, height: 400)
    window.contentViewController = controller
    // Installing the controller adopts its initial view size, which can be zero.
    window.setContentSize(size)

    let events = try EventGenerator(viewController: controller)
    try await events.waitUntilWindowIsReady()
    #else
    let previousSettings = EventGenerator.settings
    let previousKeyWindow = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap(\.windows)
        .first(where: \.isKeyWindow)
    defer {
        EventGenerator.settings = previousSettings
        previousKeyWindow?.makeKey()
    }

    // These tests locate the hosting view directly, so accessibility activation is unnecessary.
    EventGenerator.settings.forceActivateAccessibilityEngine = false
    let events = try await onMainRunLoop {
        let controller = TestingHost.PlatformHostingController(rootView: content)
        return try EventGenerator(viewController: controller)
    }
    events.showTouches = false
    #endif
    let host = UXTestHost(events: events)
    do {
        try await body(host)
    } catch {
        try? await host.release()
        throw error
    }
    try? await host.release()
}

@MainActor
struct UXTestHost {
    fileprivate let events: EventGenerator

    func tap() async throws {
        #if os(macOS)
        try await events.mouseClick()
        #else
        try await onMainRunLoop { try events.fingerTap() }
        #endif
    }

    func waitUntil(
        _ condition: @autoclosure @escaping () -> Bool,
        timeout: TimeInterval = 3
    ) async throws {
        #if os(macOS)
        try await events.waitUntil(condition(), timeout: timeout)
        #else
        try await onMainRunLoop {
            try events.waitUntil(condition(), timeout: timeout)
        }
        #endif
    }

    fileprivate func release() async throws {
        #if os(macOS)
        try await events.mouseUp()
        #else
        try await onMainRunLoop { try events.fingerUp() }
        #endif
    }
}

#if os(macOS)
@MainActor
private enum UXTestWindow {
    static let shared: HammerWindow = {
        // Hide the scene's placeholder once. Each test replaces only the test window's content.
        for window in NSApp.windows where window.canBecomeMain && window.isVisible {
            window.orderOut(nil)
        }
        return HammerWindow(size: NSSize(width: 400, height: 400))
    }()
}
#else
@MainActor
private func onMainRunLoop<Value>(
    _ body: @escaping @MainActor () throws -> Value
) async throws -> Value {
    // Hammer's synchronous waits must allow UIKit callbacks on the main queue to run.
    // Suspend the test task and run Hammer from the run loop instead of a main queue job.
    try await withCheckedThrowingContinuation { continuation in
        RunLoop.main.perform {
            MainActor.assumeIsolated {
                continuation.resume(with: Result { try body() })
            }
        }
    }
}
#endif
