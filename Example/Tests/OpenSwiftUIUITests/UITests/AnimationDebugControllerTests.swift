//
//  AnimationDebugControllerTests.swift
//  OpenSwiftUIUITests

#if os(macOS)
import AppKit
import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
struct AnimationDebugControllerTests {
    @Test
    func captureDoesNotAdvanceAnimationTime() throws {
        let controller = AnimationDebugController(
            MatchedGeometryEffectModifierExample(initialToggle: true)
        )
        let strategy: Snapshotting<NSViewController, NSImage> = .image(
            size: CGSize(width: 300, height: 150)
        )

        func capture() throws -> NSImage {
            var image: NSImage?
            controller.withFixedTime {
                strategy.snapshot(controller).run { image = $0 }
            }
            return try #require(image)
        }

        _ = try capture()
        controller.advance(interval: .zero)
        controller.advance(interval: .zero)
        controller.advance(interval: .zero)
        controller.advance(interval: 0.5)
        let initial = try capture()

        // Capture cost must not advance the animation's test clock.
        Thread.sleep(forTimeInterval: 0.2)
        let delayed = try capture()
        #expect(strategy.diffing.diff(initial, delayed) == nil)

        controller.advance(interval: 0.5)
        let advanced = try capture()
        #expect(strategy.diffing.diff(delayed, advanced) != nil)
    }
}
#endif
