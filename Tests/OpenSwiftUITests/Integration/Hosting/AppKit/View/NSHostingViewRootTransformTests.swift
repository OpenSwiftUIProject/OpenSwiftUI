//
//  NSHostingViewRootTransformTests.swift
//  OpenSwiftUITests

#if os(macOS)
import AppKit
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
@testable import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

@MainActor
@Suite(.disabled(if: attributeGraphVendor == .oag), .tags(.aigc))
struct NSHostingViewRootTransformTests {
    @Test
    func detachedHostProvidesIdentityTransform() throws {
        let host = NSHostingView(rootView: EmptyView())
        let provider = try #require(host.as(RootTransformProvider.self))
        let transform = provider.rootTransform()
        #expect(transform.convert(.globalToSpace(.local), point: CGPoint(x: 20, y: 15)) == CGPoint(x: 20, y: 15))
    }

    @Test(arguments: [
        (Semantics.v2, CGPoint(x: 160, y: 175)),
        (Semantics.v3, CGPoint(x: 160, y: 225)),
        (Semantics.v6, CGPoint(x: 160, y: 225)),
    ])
    func windowCoordinatesReachHost(semantics: Semantics, globalPoint: CGPoint) throws {
        try semantics.test {
            let fixture = Fixture(rootView: EmptyView())
            defer { fixture.window.close() }
            _ = try #require(fixture.host.as(RootTransformProvider.self))
            let transform = fixture.host.updateViewGraph { $0.transform }
            #expect(transform.convert(.globalToSpace(.local), point: globalPoint) == CGPoint(x: 20, y: 15))
            #expect(transform.convert(.localToSpace(.global), point: CGPoint(x: 20, y: 15)) == globalPoint)
        }
    }

    @Test
    func geometryChangesInvalidateRootTransform() throws {
        try Semantics.v6.test {
            let fixture = Fixture(rootView: EmptyView())
            defer { fixture.window.close() }
            _ = try #require(fixture.host.as(RootTransformProvider.self))
            let initial = fixture.host.updateViewGraph { $0.transform }
            #expect(initial.convert(.localToSpace(.global), point: .zero) == CGPoint(x: 140, y: 210))

            fixture.host.setFrameOrigin(CGPoint(x: 60, y: 40))
            #expect(fixture.host.propertiesNeedingUpdate.contains(.transform))
            let moved = fixture.host.updateViewGraph { $0.transform }
            #expect(moved.convert(.localToSpace(.global), point: .zero) == CGPoint(x: 160, y: 200))

            fixture.parent.setFrameOrigin(CGPoint(x: 150, y: 100))
            #expect(fixture.host.propertiesNeedingUpdate.contains(.transform))
            let ancestorMoved = fixture.host.updateViewGraph { $0.transform }
            #expect(ancestorMoved.convert(.localToSpace(.global), point: .zero) == CGPoint(x: 210, y: 180))

            fixture.host.removeFromSuperview()
            let detached = fixture.host.updateViewGraph { $0.transform }
            #expect(detached.convert(.localToSpace(.global), point: CGPoint(x: 20, y: 15)) == CGPoint(x: 20, y: 15))
        }
    }

    @Test
    func windowMouseEventBindsAfterAncestorMovement() throws {
        try Semantics.v6.test {
            let fixture = Fixture(rootView: Color.red.onTapGesture {})
            defer { fixture.window.close() }
            let root = try #require(fixture.host.updateViewGraph {
                $0.instantiateIfNeeded()
                return $0.responderNode
            })
            let event = MouseEvent(
                timestamp: .zero,
                button: .primary,
                phase: .began,
                location: .zero,
                globalLocation: CGPoint(x: 160, y: 225),
                modifiers: []
            )
            #expect(root.bindEvent(event) != nil)

            fixture.parent.setFrameOrigin(CGPoint(x: 300, y: 100))
            let movedRoot = try #require(fixture.host.updateViewGraph { $0.responderNode })
            #expect(movedRoot.bindEvent(event) == nil)
            var movedEvent = event
            movedEvent.globalLocation = CGPoint(x: 360, y: 205)
            #expect(movedRoot.bindEvent(movedEvent) != nil)
        }
    }

    @Test
    func geometryObserverDoesNotRetainHost() throws {
        weak var weakHost: NSHostingView<EmptyView>?
        try autoreleasepool {
            let host = NSHostingView(rootView: EmptyView())
            weakHost = host
            let provider = try #require(host.as(RootTransformProvider.self))
            _ = provider.rootTransform()
        }
        #expect(weakHost == nil)
    }

    @Test(arguments: [NSWindow.StyleMask.borderless, .titled])
    func nativeMouseClickRunsTapAction(styleMask: NSWindow.StyleMask) throws {
        try Semantics.v6.test {
            var tapCount = 0
            let fixture = Fixture(rootView: Color.red.onTapGesture { tapCount += 1 }, styleMask: styleMask)
            defer { fixture.window.close() }
            fixture.host.updateViewGraph { $0.instantiateIfNeeded() }
            let recognizer = try #require(fixture.host.gestureRecognizers.first as? AppKitGestureRecognizer)
            let location = fixture.host.convert(CGPoint(x: 20, y: 15), to: nil)
            let down = try #require(NSEvent.mouseEvent(
                with: .leftMouseDown,
                location: location,
                modifierFlags: [],
                timestamp: 1,
                windowNumber: fixture.window.windowNumber,
                context: nil,
                eventNumber: 1,
                clickCount: 1,
                pressure: 1
            ))
            let up = try #require(NSEvent.mouseEvent(
                with: .leftMouseUp,
                location: location,
                modifierFlags: [],
                timestamp: 1.1,
                windowNumber: fixture.window.windowNumber,
                context: nil,
                eventNumber: 2,
                clickCount: 1,
                pressure: 0
            ))
            Update.perform {
                recognizer.mouseDown(with: down)
                recognizer.mouseUp(with: up)
            }
            #expect(tapCount == 1)
        }
    }

    @MainActor
    private struct Fixture<Content: View> {
        let window: NSWindow
        let parent: NSView
        let host: NSHostingView<Content>

        init(rootView: Content, styleMask: NSWindow.StyleMask = .borderless) {
            _ = NSApplication.shared
            window = NSWindow(
                contentRect: CGRect(x: 0, y: 0, width: 600, height: 400),
                styleMask: styleMask,
                backing: .buffered,
                defer: false
            )
            window.isReleasedWhenClosed = false
            let container = NSView(frame: CGRect(x: 0, y: 0, width: 600, height: 400))
            window.contentView = container
            parent = NSView(frame: CGRect(x: 100, y: 80, width: 400, height: 260))
            container.addSubview(parent)
            host = NSHostingView(rootView: rootView)
            host.sizingOptions = []
            host.frame = CGRect(x: 40, y: 30, width: 100, height: 80)
            parent.addSubview(host)
        }
    }
}
#endif
