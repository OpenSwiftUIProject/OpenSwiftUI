//
//  AppKitHitTestCustomizing.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 289E697C76A45E2F2E3A5EE8124A4DEF

#if os(macOS)
import AppKit
import COpenSwiftUI
@_spi(DisplayList_ViewSystem)
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - RecursiveIgnoreHitTestCustomizing

protocol RecursiveIgnoreHitTestCustomizing: NSView {
    var recursiveIgnoreHitTest: Bool { get set }
}

// MARK: - AcceptsFirstMouseCustomizing

protocol AcceptsFirstMouseCustomizing: NSView {
    var customAcceptsFirstMouse: Bool? { get set }
}

extension AcceptsFirstMouseCustomizing {
    var effectiveAcceptsFirstMouse: Bool? {
        if let value = customAcceptsFirstMouse {
            return value
        }
        var current: NSView? = superview
        while let view = current {
            if let customizing = view as? AcceptsFirstMouseCustomizing {
                return customizing.effectiveAcceptsFirstMouse
            }
            if view is HostingViewProtocol {
                return nil
            }
            current = view.superview
        }
        return nil
    }
}

// MARK: - HitTestsAsOpaqueCustomizing

protocol HitTestsAsOpaqueCustomizing: NSView {
    var hitTestsAsOpaque: Bool { get set }
}

// MARK: - HitTestingLeafPlatformView

protocol HitTestingLeafPlatformView: NSView {
    var usesResponderForHitTesting: Bool { get }
    var responderForHitTesting: ViewResponder? { get }
    var foreignSubviewsForHitTesting: [NSView] { get }
    var isTransparentForHitTesting: Bool { get }
    func hitTest(_ point: CGPoint, cacheKey: UInt32?) -> NSView?
}

extension HitTestingLeafPlatformView {
    var isTransparentForHitTesting: Bool {
        ignoreHitTest
    }

    func pointContainmentHitTest(_ point: CGPoint) -> NSView? {
        guard !isHiddenOrHasHiddenAncestor else { return nil }
        if let customizing = self as? RecursiveIgnoreHitTestCustomizing,
           customizing.recursiveIgnoreHitTest {
            return nil
        }
        let localPoint = convert(point, from: superview)
        guard NSMouseInRect(localPoint, bounds, isFlipped) else { return nil }
        return self
    }

    func defaultHitTest(
        _ point: CGPoint,
        radius: CGFloat,
        cacheKey: UInt32?,
        super: () -> NSView?
    ) -> NSView? {
        if usesResponderForHitTesting {
            return responderBasedHitTest(
                point,
                radius: radius,
                cacheKey: cacheKey,
                super: `super`
            )
        } else {
            let isTransparent = isTransparentForHitTesting
            let result = `super`()
            if isTransparent, let result, result === self {
                return nil
            }
            return result
        }
    }

    func defaultAcceptsFirstMouse(for event: NSEvent?, super: () -> Bool) -> Bool {
        // TODO: Blocked by ViewResponder.hitTest
        _openSwiftUIUnimplementedWarning()
        return `super`()
    }

    func defaultShouldDelayWindowOrdering(for event: NSEvent, super: () -> Bool) -> Bool {
        // TODO: Blocked by ViewResponder.hitTest
        return `super`()
    }

    private func responderBasedHitTest(
        _ point: CGPoint,
        radius: CGFloat,
        cacheKey: UInt32?,
        super: () -> NSView?
    ) -> NSView? {
        _openSwiftUIUnimplementedWarning()
        return nil
    }
}

#endif
