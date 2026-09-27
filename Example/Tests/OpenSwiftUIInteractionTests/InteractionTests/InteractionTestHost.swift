//
//  InteractionTestHost.swift
//  OpenSwiftUIInteractionTests

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
import SnapshotTesting
import Testing
import TestingHost

@MainActor
func withInteractionTestHost<Content: View>(
    of content: Content,
    size: CGSize = defaultSize,
    _ body: @MainActor (InteractionTestHost) async throws -> Void
) async throws {
    #if os(macOS)
    let window = InteractionTestWindow.shared(size: size)
    let rightEdge = window.frame.maxX
    defer {
        window.makeFirstResponder(nil)
        window.contentViewController = nil
        window.contentView = nil
    }

    // Keep the test surface fixed instead of adopting the content's ideal size.
    let controller = TestingHost.PlatformHostingController(
        rootView: content.frame(width: size.width, height: size.height)
    )
    controller.sizingOptions = []
    window.contentViewController = controller
    // Installing the controller adopts its initial view size, which can be zero.
    window.setContentSize(size)
    // Keep a hidden window outside all screens when its width changes.
    window.setFrameOrigin(NSPoint(x: rightEdge - window.frame.width, y: window.frame.minY))

    let events = try EventGenerator(viewController: controller)
    try await events.waitUntilWindowIsReady()
    let host = InteractionTestHost(events: events, view: controller.view)
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
    let host = try await onMainRunLoop {
        let controller = TestingHost.PlatformHostingController(
            rootView: content.frame(width: size.width, height: size.height)
        )
        let container = UIViewController()
        let view = controller.view!
        container.addChild(controller)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.view.addSubview(view)
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: size.width),
            view.heightAnchor.constraint(equalToConstant: size.height),
            view.centerXAnchor.constraint(equalTo: container.view.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: container.view.centerYAnchor),
        ])
        controller.didMove(toParent: container)

        // Hammer fills the screen with its controller. Keep the captured view at the requested size.
        let events = try EventGenerator(viewController: container)
        events.showTouches = false
        try events.waitUntilWindowIsReady()
        return InteractionTestHost(events: events, view: view)
    }
    #endif
    try #require(host.view.bounds.size == size, "The hosted view must use the requested size.")
    do {
        try await body(host)
    } catch {
        try? await host.release()
        throw error
    }
    try? await host.release()
}

@MainActor
struct InteractionTestHost {
    fileprivate let events: EventGenerator
    fileprivate let view: PlatformView

    func tap(count: Int = 1) async throws {
        #if os(macOS)
        try await events.mouseClick(numberOfTimes: count)
        #else
        try await onMainRunLoop { try events.fingerTap(numberOfTimes: count) }
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

    private func screenshot() async throws -> PlatformImage {
        // Capture the existing view without moving it out of Hammer's window.
        #if os(macOS)
        try await events.waitUntilWindowIsReady()
        let bitmap = try #require(
            view.bitmapImageRepForCachingDisplay(in: view.bounds),
            "Unable to create a bitmap for the hosted view."
        )
        view.cacheDisplay(in: view.bounds, to: bitmap)
        let image = NSImage(size: view.bounds.size)
        image.addRepresentation(bitmap)
        return image
        #else
        return try await onMainRunLoop {
            try events.waitUntilWindowIsReady()
            try #require(!view.bounds.isEmpty, "The hosted view has no drawable bounds.")
            let renderer = UIGraphicsImageRenderer(
                bounds: view.bounds,
                format: .init(for: view.traitCollection)
            )
            var didDraw = false
            let image = renderer.image { _ in
                didDraw = view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            }
            try #require(didDraw, "Unable to draw the hosted view.")
            return image
        }
        #endif
    }

    func assertSnapshot(
        precision: Float = 1,
        perceptualPrecision: Float = 1,
        named name: String? = nil,
        record recording: SnapshotTestingConfiguration.Record? = shouldRecord,
        timeout: TimeInterval = 5,
        fileID: StaticString = #fileID,
        file filePath: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) async throws {
        let image = try await screenshot()
        #if os(macOS)
        let snapshotting = Snapshotting<PlatformImage, PlatformImage>.image(
            precision: precision, perceptualPrecision: perceptualPrecision
        )
        #else
        let snapshotting = Snapshotting<PlatformImage, PlatformImage>.image(
            precision: precision, perceptualPrecision: perceptualPrecision, scale: image.scale
        )
        #endif
        openSwiftUIAssertSnapshotValue(
            of: image,
            as: snapshotting,
            named: (name.map { "\($0)." } ?? "") + "\(Int(image.size.width))x\(Int(image.size.height))",
            record: recording,
            timeout: timeout,
            fileID: fileID,
            file: filePath,
            testName: testName,
            line: line,
            column: column
        )
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
private enum InteractionTestWindow {
    private static var window: HammerWindow?

    static func shared(size: CGSize) -> HammerWindow {
        if let window { return window }
        // Hide the scene's placeholder once. Each test replaces only the test window's content.
        for window in NSApp.windows where window.canBecomeMain && window.isVisible {
            window.orderOut(nil)
        }
        let window = HammerWindow(size: size)
        self.window = window
        return window
    }
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
