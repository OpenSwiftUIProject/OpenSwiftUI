//
//  UXTestHost.swift
//  OpenSwiftUIUXTests

import Foundation
import Hammer
#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif
import TestingHost
import UIKit

@MainActor
func withUXTestHost<Content: View>(
    of content: Content,
    _ body: @MainActor (UXTestHost) async throws -> Void
) async throws {
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
}

@MainActor
struct UXTestHost {
    fileprivate let events: EventGenerator

    func tap() async throws {
        try await onMainRunLoop { try events.fingerTap() }
    }

    func waitUntil(
        _ condition: @autoclosure @escaping () -> Bool,
        timeout: TimeInterval = 3
    ) async throws {
        try await onMainRunLoop {
            try events.waitUntil(condition(), timeout: timeout)
        }
    }
}

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
