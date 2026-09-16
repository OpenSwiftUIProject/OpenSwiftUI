//
//  UIHostingViewGestureContainerTests.swift
//  OpenSwiftUITests

#if os(iOS) || os(visionOS)
import COpenSwiftUI
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
@testable import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing
import UIKit

@MainActor
@Suite(.disabled(if: attributeGraphVendor == .oag), .tags(.aigc))
struct UIHostingViewGestureContainerTests {
    @Test
    func disabledFeatureKeepsViewRecognizerAndClearsCurrentEvent() throws {
        try withFeature(enabled: false) {
            let host = _UIHostingView(rootView: EmptyView())
            let recognizer = try #require(host.eventBridge.gestureRecognizer)
            #expect(recognizer.view === host)
            host.currentEvent = UIEvent()

            #expect(host._hitTest(with: nil) == nil)
            #expect(host.currentEvent == nil)
        }
    }

    @Test
    func hitContainerRegistersRecognizerAndDeliversTapAction() throws {
        try withFeature {
            var tapCount = 0
            let fixture = Fixture(rootView: Color.red.onTapGesture { tapCount += 1 })
            let context = fixture.context()
            fixture.host.currentEvent = UIEvent()
            let container = try #require(fixture.host._hitTest(with: context) as? UIKitGestureContainer)
            #expect(fixture.host.currentEvent == nil)
            #expect(fixture.host.eventBridge.gestureRecognizer == nil)
            #expect(container._proxyView === fixture.host)
            #expect(fixture.host._childContainers.contains { $0 === container })
            let recognizer = try #require(container.gestureRecognizers.first as? UIKitResponderGestureRecognizer)
            let bridge = try #require(recognizer.eventBridge as? UIKitResponderEventBindingBridge)
            #expect(recognizer.responder === container.responder)

            var event = TouchEvent(
                timestamp: Time(seconds: 1),
                phase: .began,
                location: .zero,
                globalLocation: context.point,
                radius: 1,
                force: 1,
                maximumPossibleForce: 1,
                modifiers: [],
                altitude: .zero,
                azimuth: .zero,
                touchType: .direct
            )
            let eventID = EventID(type: TouchEvent.self, serial: 0)
            Update.perform {
                bridge.send([eventID: event], source: recognizer)
                event.timestamp = Time(seconds: 1.1)
                event.phase = .ended
                bridge.send([eventID: event], source: recognizer)
                bridge.flushActions()
            }
            #expect(tapCount == 1)
        }
    }

    @Test
    func nestedGestureContainersPreserveParentAndChildTraversal() throws {
        try withFeature {
            let fixture = Fixture(rootView: Color.red.onTapGesture {}.onTapGesture {})
            let inner = try #require(fixture.host._hitTest(with: fixture.context()) as? UIKitGestureContainer)
            let outer = try #require(inner._parentContainer as? UIKitGestureContainer)

            #expect(outer._parentContainer === fixture.host)
            #expect(outer._childContainers.contains { $0 === inner })
            let roots = fixture.host._childContainers
            #expect(roots.count == 1)
            #expect(roots.first === outer)
        }
    }

    @Test
    func ancestorMovementRefreshesGlobalHitCoordinates() throws {
        try withFeature {
            let fixture = Fixture(rootView: Color.red.onTapGesture {})
            let oldContext = fixture.context()
            let container = try #require(fixture.host._hitTest(with: oldContext) as? UIKitGestureContainer)

            fixture.parent.frame.origin.x += 250
            #expect(fixture.host._hitTest(with: oldContext) === fixture.host)
            #expect(fixture.host._hitTest(with: fixture.context()) === container)
        }
    }

    @Test
    func rootTransformIncludesBoundsOriginAndScale() {
        withFeature {
            let fixture = Fixture(rootView: EmptyView())
            fixture.host.bounds.origin = CGPoint(x: 10, y: 5)
            fixture.host.transform = CGAffineTransform(scaleX: 2, y: 1.5)
            let transform = fixture.host.rootTransform()

            #expect(transform.convert(.globalToSpace(.local), point: CGPoint(x: 110, y: 105)) == CGPoint(x: 20, y: 15))
            #expect(transform.convert(.localToSpace(.global), point: CGPoint(x: 20, y: 15)) == CGPoint(x: 110, y: 105))
        }
    }

    @Test
    func foreignSubviewsKeepTheirUIKitHitTarget() {
        withFeature {
            let fixture = Fixture(rootView: EmptyView())
            let control = UIControl(frame: fixture.host.bounds)
            fixture.host.addSubview(control)

            #expect(fixture.host.hitTest(CGPoint(x: 20, y: 15), with: nil) === control)
        }
    }

    @Test
    func emptyContentFallsBackToHostAndClearsCurrentEvent() {
        withFeature {
            let fixture = Fixture(rootView: EmptyView())
            fixture.host.currentEvent = UIEvent()

            #expect(fixture.host._hitTest(with: fixture.context()) === fixture.host)
            #expect(fixture.host.currentEvent == nil)
            #expect(fixture.host._childContainers.isEmpty)
        }
    }

    private func withFeature<T>(enabled: Bool = true, _ body: () throws -> T) rethrows -> T {
        let wasTesting = CoreTesting.isRunning
        let oldOverride = GestureContainerFeature.isEnabledOverride
        CoreTesting.isRunning = true
        GestureContainerFeature.isEnabledOverride = enabled
        defer {
            GestureContainerFeature.isEnabledOverride = oldOverride
            CoreTesting.isRunning = wasTesting
        }
        return try Semantics.v6.test(body)
    }

    @MainActor
    private struct Fixture<Content: View> {
        let window: UIWindow
        let parent: UIView
        let host: _UIHostingView<Content>

        init(rootView: Content) {
            window = UIWindow(frame: CGRect(x: 0, y: 0, width: 600, height: 400))
            parent = UIView(frame: CGRect(x: 100, y: 80, width: 400, height: 260))
            window.addSubview(parent)
            host = _UIHostingView(rootView: rootView)
            host.frame = CGRect(x: 40, y: 30, width: 100, height: 80)
            parent.addSubview(host)
            host.updateViewGraph { $0.instantiateIfNeeded() }
        }

        func context() -> _UIHitTestContext {
            _UIHitTestContext(point: host.convert(CGPoint(x: 20, y: 15), to: nil), radius: 1)
        }
    }
}
#endif
