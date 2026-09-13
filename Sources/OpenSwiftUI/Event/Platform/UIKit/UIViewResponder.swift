//
//  UIViewResponder.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete (Blocked by FocusResponder)

#if os(iOS) || os(visionOS)
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import UIKit

class UIViewResponder: PlatformViewResponderBase {
    weak var focusAccessibilityNode: AccessibilityNode?
    var keyPressHandlers: [KeyPress.Handler]

    override init() {
        keyPressHandlers = []
        super.init()
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
        if let hostView,
           options.contains(.allowDisabledViews) || hostView.isUserInteractionEnabled {
            let result = helper.containsGlobalPoints(
                points,
                cacheKey: cacheKey,
                options: options,
                children: children
            )
            mask = result.mask
            priority = result.priority
            if !mask.isEmpty, !options.contains(.useZDistanceAsPriority) {
                priority = max(priority, Self.gestureContainmentPriority)
            }
        }
        let result = super.containsGlobalPoints(points, cacheKey: cacheKey, options: options)
        mask.formUnion(result.mask)
        priority = max(priority, result.priority)
        return ContainsPointsResult(mask: mask, priority: priority, children: children)
    }

    override func extendPrintTree(string: inout String) {
        string += "[\(helper.size.width), \(helper.size.height)]"
    }

    override var platformViewIsEnabled: Bool {
        hostView?.isUserInteractionEnabled ?? super.platformViewIsEnabled
    }

    override func platformViewHitTest(globalPoint: CGPoint, cacheKey: UInt32?) -> UIView? {
        guard let hostView, hostView.window != nil else {
            return nil
        }
        let point = hostView.convert(globalPoint, from: nil)
        let event = host?.as((any CurrentEventProvider).self)?.currentEvent
        return hostView.hitTest(point, with: event)
    }

    var wantsOpenSwiftUIFocusItem: Bool {
        _openSwiftUIUnimplementedFailure()
    }

    var focusItem: FocusItem? {
        _openSwiftUIUnimplementedFailure()
    }
}

// TODO: FocusResponder conformance

#endif
