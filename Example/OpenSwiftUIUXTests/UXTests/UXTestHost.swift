//
//  UXTestHost.swift
//  OpenSwiftUIUXTests

#if os(macOS)
import AppKit
#elseif os(iOS)
import Hammer
import UIKit
#endif
import Foundation
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
    let previousKeyWindow = NSApp.keyWindow
    let previousWindows = NSApp.orderedWindows.filter(\.isVisible)
    // Hide the host app's placeholder windows during the interaction test.
    previousWindows.forEach { $0.orderOut(nil) }
    let controller = TestingHost.PlatformHostingController(rootView: content)
    // Keep the test surface fixed instead of adopting the content's ideal size.
    controller.sizingOptions = []
    let size = NSSize(width: 400, height: 400)
    // A nonactivating panel can receive events while the test host is in the background.
    let window = NSPanel(
        contentRect: NSRect(origin: .zero, size: size),
        styleMask: [.titled, .nonactivatingPanel],
        backing: .buffered,
        defer: false
    )
    window.isReleasedWhenClosed = false
    // Synthetic events must use the final window coordinates during presentation.
    window.animationBehavior = .none
    window.contentViewController = controller
    // Installing the controller adopts its initial view size, which can be zero.
    window.setContentSize(size)
    window.center()
    defer {
        window.close()
        previousWindows.reversed().forEach { $0.orderFront(nil) }
        previousKeyWindow?.makeKey()
    }

    window.makeKeyAndOrderFront(nil)
    let host = UXTestHost(window: window, view: controller.view)
    do {
        try await host.waitUntil(window.isKeyWindow && window.isVisible && !controller.view.bounds.isEmpty)
    } catch UXTestError.conditionTimedOut {
        throw UXTestError.windowNotReady
    }
    controller.view.layoutSubtreeIfNeeded()
    window.displayIfNeeded()
    try await body(host)
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
    do {
        try await body(UXTestHost(events: events))
    } catch {
        // Release a finger left down if an interaction throws.
        try? await onMainRunLoop { try events.fingerUp() }
        throw error
    }
    try? await onMainRunLoop { try events.fingerUp() }
    #endif
}

@MainActor
struct UXTestHost {
    #if os(macOS)
    fileprivate let window: NSWindow
    fileprivate let view: NSView
    private static var eventNumber = 0
    #else
    fileprivate let events: EventGenerator
    #endif

    func tap() async throws {
        #if os(macOS)
        try Task.checkCancellation()
        let location = view.convert(
            NSPoint(x: view.bounds.midX, y: view.bounds.midY),
            to: nil
        )
        Self.eventNumber &+= 1
        let timestamp = ProcessInfo.processInfo.systemUptime
        guard let down = NSEvent.mouseEvent(
            with: .leftMouseDown,
            location: location,
            modifierFlags: [],
            timestamp: timestamp,
            windowNumber: window.windowNumber,
            context: nil,
            eventNumber: Self.eventNumber,
            clickCount: 1,
            pressure: 1
        ), let up = NSEvent.mouseEvent(
            with: .leftMouseUp,
            location: location,
            modifierFlags: [],
            timestamp: timestamp + 0.05,
            windowNumber: window.windowNumber,
            context: nil,
            eventNumber: Self.eventNumber,
            clickCount: 1,
            pressure: 0
        ) else {
            throw UXTestError.couldNotCreateMouseEvent
        }
        // Use AppKit's event dispatcher for hit testing and gesture recognition.
        // Queued events can have incorrect coordinates while a new window is being presented.
        NSApp.sendEvent(down)
        defer { NSApp.sendEvent(up) }
        try await Task.sleep(for: .milliseconds(50))
        #else
        try await onMainRunLoop { try events.fingerTap() }
        #endif
    }

    func waitUntil(
        _ condition: @autoclosure @escaping () -> Bool,
        timeout: TimeInterval = 3
    ) async throws {
        #if os(macOS)
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: .seconds(timeout))
        while !condition() {
            guard clock.now < deadline else {
                throw UXTestError.conditionTimedOut(timeout)
            }
            try await Task.sleep(for: .milliseconds(10))
        }
        #else
        try await onMainRunLoop {
            try events.waitUntil(condition(), timeout: timeout)
        }
        #endif
    }
}

#if os(macOS)
private enum UXTestError: Error {
    case couldNotCreateMouseEvent
    case conditionTimedOut(TimeInterval)
    case windowNotReady
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
