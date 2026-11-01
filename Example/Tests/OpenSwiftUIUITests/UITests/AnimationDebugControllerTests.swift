//
//  AnimationDebugControllerTests.swift
//  OpenSwiftUIUITests

#if os(macOS)
import SnapshotTesting
import Testing
@testable import TestingHost
import XCTest

@MainActor
struct AnimationDebugControllerTests {
    @Test(arguments: [GradientExample.Kind.linear, .radial, .elliptical, .angular])
    func detachedCaptureDoesNotAdvanceGradientAnimationTime(kind: GradientExample.Kind) throws {
        struct ContentView: View {
            var kind: GradientExample.Kind
            @State private var alternate = false

            var body: some View {
                GradientExample(kind: kind, alternate: alternate)
                    .animation(.linear(duration: 1), value: alternate)
                    .onAppear { alternate = true }
            }
        }

        let controller = AnimationDebugController(ContentView(kind: kind))
        let strategy: Snapshotting<NSViewController, NSImage> = .image(size: defaultSize)

        func capture() throws -> NSImage {
            try #require(controller.view.window == nil)
            var image: NSImage?
            controller.withFixedTime {
                let captured = XCTestExpectation(description: "Captured animation frame")
                strategy.snapshot(controller).run {
                    image = $0
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.02) {
                        captured.fulfill()
                    }
                }
                #expect(XCTWaiter.wait(for: [captured], timeout: 5) == .completed)
            }
            return try #require(image)
        }

        _ = try capture()
        controller.advance(interval: .zero)
        controller.advance(interval: .zero)
        controller.advance(interval: .zero)
        controller.advance(interval: 0.25)
        _ = try capture()
        controller.advance(interval: 0.25)
        let initial = try capture()

        // Let background display callbacks run while the test clock stays fixed.
        Thread.sleep(forTimeInterval: 0.05)
        let delayed = try capture()
        #expect(strategy.diffing.diffV2(initial, delayed) == nil)

        controller.advance(interval: 0.25)
        let advanced = try capture()
        #expect(strategy.diffing.diffV2(delayed, advanced) != nil)
    }

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
