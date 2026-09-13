//
//  NSViewResponder.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete (Blocked by FocusResponder)

#if os(macOS)
import AppKit
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

class NSViewResponder: PlatformViewResponderBase {
    weak var focusAccessibilityNode: AccessibilityNode?
    var keyPressHandlers: [KeyPress.Handler]
    weak var firstKeyViewInSubtree: NSView?
    weak var lastKeyViewInSubtree: NSView?
    var effectiveLayoutDirection: LayoutDirection?
    var evaluateDefaultFocus: EvaluateDefaultFocusAction?
    var delegatesFocusEffect: Bool
    var isEnabled: Bool?

    override init() {
        keyPressHandlers = []
        delegatesFocusEffect = false
        super.init()
    }

    override var platformViewIsEnabled: Bool {
        if ResponderBasedHitTesting.isEnabled {
            return isEnabled ?? super.platformViewIsEnabled
        } else if let hostView = hostView as? any RecursiveIgnoreHitTestCustomizing {
            return !hostView.recursiveIgnoreHitTest
        } else {
            return super.platformViewIsEnabled
        }
    }

    override func platformViewHitTest(globalPoint: CGPoint, cacheKey: UInt32?) -> NSView? {
        guard let hostView, hostView.window != nil else {
            return nil
        }
        var point = globalPoint
        if _SemanticFeature_v3.isEnabled {
            point.y = (hostView.window?.frame.height ?? 0) - point.y
        }
        if let superview = hostView.superview {
            point = superview.convert(point, from: nil)
        }
        if let hostView = hostView as? any HitTestingLeafPlatformView {
            return hostView.hitTest(point, cacheKey: cacheKey)
        } else {
            return hostView.hitTest(point)
        }
    }

    override func containsGlobalPoints(
        _ points: [CGPoint],
        cacheKey: UInt32?,
        options: ContainsPointsOptions
    ) -> ContainsPointsResult {
        guard !UnifiedHitTestingFeature.isEnabled else {
            return super.containsGlobalPoints(points, cacheKey: cacheKey, options: options)
        }
        var mask = BitVector64()
        var priority = 0.0
        if hostView != nil,
           options.contains(.allowDisabledViews) || (isEnabled ?? true),
           platformViewHitTest(globalPoint: points[0], cacheKey: cacheKey) != nil,
           !options.contains(.useZDistanceAsPriority) {
            mask = BitVector64(rawValue: .max)
            priority = Self.gestureContainmentPriority
        }
        let result = super.containsGlobalPoints(points, cacheKey: cacheKey, options: options)
        mask.formUnion(result.mask)
        priority = max(priority, result.priority)
        return ContainsPointsResult(mask: mask, priority: priority, children: children)
    }

    var focusItem: FocusItem? {
        _openSwiftUIUnimplementedFailure()
    }

    var isInVisibleRect: Bool {
        _openSwiftUIUnimplementedFailure()
    }

    var focusRingView: (NSView & FocusRingDelegate)? {
        _openSwiftUIUnimplementedFailure()
    }
}

// TODO: FocusResponder
#endif
