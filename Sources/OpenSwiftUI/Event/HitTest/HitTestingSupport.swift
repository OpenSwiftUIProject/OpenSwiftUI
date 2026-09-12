//
//  HitTestingSupport.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 289E697C76A45E2F2E3A5EE8124A4DEF (SwiftUI)

import Foundation
import COpenSwiftUI
@_spi(DisplayList_ViewSystem)
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
#if os(macOS)
import AppKit
#elseif os(iOS) || os(visionOS)
import UIKit
#endif

// MARK: - RecursiveIgnoreHitTestCustomizing

protocol RecursiveIgnoreHitTestCustomizing: PlatformView {
    #if os(macOS)
    var recursiveIgnoreHitTest: Bool { get set }
    #endif
}

// MARK: - AcceptsFirstMouseCustomizing

protocol AcceptsFirstMouseCustomizing: PlatformView {
    #if os(macOS)
    var customAcceptsFirstMouse: Bool? { get set }
    #endif
}

// MARK: - HitTestsAsOpaqueCustomizing

protocol HitTestsAsOpaqueCustomizing: PlatformView {
    #if os(macOS)
    var hitTestsAsOpaque: Bool { get set }
    #endif
}

// MARK: - HitTestingLeafPlatformView

protocol HitTestingLeafPlatformView: PlatformView {
    var usesResponderForHitTesting: Bool { get }

    var responderForHitTesting: ViewResponder? { get }

    var foreignSubviewsForHitTesting: [PlatformView] { get }

    var isTransparentForHitTesting: Bool { get }

    #if os(macOS)
    func hitTest(_ point: PlatformPoint, cacheKey: UInt32?) -> PlatformView?
    #endif
}

extension HitTestingLeafPlatformView where Self: AnyPlatformViewHost {
    var responderForHitTesting: ViewResponder? {
        responder
    }
}

extension HitTestingLeafPlatformView where Self: EventGraphHost {
    var responderForHitTesting: ViewResponder? {
        responderNode as? ViewResponder
    }
}

#if os(macOS)
extension AcceptsFirstMouseCustomizing {
    var effectiveAcceptsFirstMouse: Bool? {
        if let value = customAcceptsFirstMouse {
            return value
        }
        var current: NSView? = superview
        while let view = current {
            if let customizing = view as? AcceptsFirstMouseCustomizing {
                return customizing.effectiveAcceptsFirstMouse
            } else if view is HostingViewProtocol {
                return nil
            } else {
                current = view.superview
            }
        }
        return nil
    }
}

extension HitTestingLeafPlatformView {
    var isTransparentForHitTesting: Bool {
        ignoreHitTest
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

    func defaultAcceptsFirstMouse(for event: NSEvent?, super: () -> Bool) -> Bool {
        guard usesResponderForHitTesting else { return `super`() }
        guard let event else { return false }
        var point = event.locationInWindow
        if _SemanticFeature_v3.isEnabled {
            point.y = (window?.frame.height ?? 0) - point.y
        }
        return Update.perform {
            guard let hit = responderForHitTesting?.hitTest(globalPoint: point, radius: 1) else {
                return false
            }
            if let value = hit.effectiveAllowsWindowActivationEvents {
                return value
            }
            return hit.effectiveIsDraggable || `super`()
        }
    }

    func defaultShouldDelayWindowOrdering(for event: NSEvent, super: () -> Bool) -> Bool {
        guard usesResponderForHitTesting else { return `super`() }
        var point = event.locationInWindow
        if _SemanticFeature_v3.isEnabled {
            point.y = (window?.frame.height ?? 0) - point.y
        }
        return Update.perform {
            guard let hit = responderForHitTesting?.hitTest(globalPoint: point, radius: 1) else {
                return false
            }
            return hit.effectiveIsDraggable || `super`()
        }
    }

    private func responderBasedHitTest(
        _ point: CGPoint,
        radius: CGFloat,
        cacheKey: UInt32?,
        super: () -> NSView?
    ) -> NSView? {
        if isLinkedOnOrAfter(.v6), pointContainmentHitTest(point) == nil {
            return nil
        }
        let cacheKey = cacheKey ?? ViewResponder.nextHitTestKey()
        lazy var viewBasedResult: NSView? = {
            let isTransparent = isTransparentForHitTesting
            let result = `super`()
            return isTransparent && result === self ? nil : result
        }()
        if isLinkedOnOrAfter(.v6),
           !foreignSubviewsForHitTesting.isEmpty,
           let hit = viewBasedResult {
            for subview in foreignSubviewsForHitTesting {
                if hit.isDescendant(of: subview) {
                    return hit
                }
            }
        }
        var globalPoint = superview?.convert(point, to: nil) ?? point
        if _SemanticFeature_v3.isEnabled {
            globalPoint.y = (window?.frame.height ?? 0) - globalPoint.y
        }
        return Update.perform {
            guard let responder = responderForHitTesting else {
                return isTransparentForHitTesting ? nil : self
            }
            if responder is NSViewResponder {
                return viewBasedResult
            }
            guard let hit = responder.hitTest(
                globalPoint: globalPoint,
                radius: radius,
                cacheKey: cacheKey
            ) else {
                return isTransparentForHitTesting ? nil : self
            }
            for node in hit.sequence {
                if node === responder.nextResponder {
                    break
                }
                guard let platformResponder = node as? NSViewResponder else { continue }
                if let result = platformResponder.lastResult, result.key == cacheKey {
                    return result.hitView
                }
                guard let hostView = platformResponder.hostView, hostView.window != nil else {
                    continue
                }
                var hostPoint = globalPoint
                if _SemanticFeature_v3.isEnabled {
                    hostPoint.y = (hostView.window?.frame.height ?? 0) - hostPoint.y
                }
                hostPoint = hostView.superview?.convert(hostPoint, from: nil) ?? hostPoint
                let view: NSView?
                if let hostView = hostView as? HitTestingLeafPlatformView {
                    view = hostView.hitTest(hostPoint, cacheKey: cacheKey)
                } else {
                    view = hostView.hitTest(hostPoint)
                }
                if let view {
                    return view
                }
            }
            return self
        }
    }
}

extension ResponderNode {
    fileprivate var effectiveAllowsWindowActivationEvents: Bool? {
        if let responder = self as? AllowsWindowActivationEventsResponder,
           let value = responder.value {
            return value
        }
        return nextResponder?.effectiveAllowsWindowActivationEvents
    }

    fileprivate var effectiveIsDraggable: Bool {
        if let responder = self as? AnyDragResponder {
            return responder.isDragEnabled
        }
        return nextResponder?.effectiveIsDraggable ?? false
    }
}
#endif
