//
//  PlatformViewResponderBase.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if canImport(Darwin)
import Foundation
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#elseif os(iOS) || os(visionOS)
import UIKit
#endif

class PlatformViewResponderBase: ViewResponder {
    weak var hostView: PlatformView?
    weak var representedView: PlatformView?
    var helper: ContentResponderHelper<TrivialContentResponder> = .init()
    var lastResult: PlatformHitTestResult?

    var hitTestingHostView: PlatformView? {
        hostView
    }

    weak var preferredFocusableView: PlatformView?

    var platformViewIsEnabled: Bool {
        hostView != nil
    }

    func platformViewHitTest(globalPoint: CGPoint, cacheKey: UInt32?) -> PlatformView? {
        nil
    }

    struct PlatformHitTestResult {
        var key: UInt32
        var globalPoint: CGPoint
        weak var hitView: PlatformView?
    }

    override func containsGlobalPoints(
        _ points: [CGPoint],
        cacheKey: UInt32?,
        options: ContainsPointsOptions
    ) -> ContainsPointsResult {
        guard UnifiedHitTestingFeature.isEnabled else {
            return super.containsGlobalPoints(points, cacheKey: cacheKey, options: options)
        }
        var result = ContainsPointsResult.passthrough(to: children)
        let globalPoint = points[0]
        let isEnabled = platformViewIsEnabled || options.contains(.allowDisabledViews)
        let hitView: PlatformView?
        if let lastResult, let cacheKey, lastResult.key == cacheKey {
            hitView = lastResult.hitView
        } else if isEnabled {
            hitView = platformViewHitTest(globalPoint: globalPoint, cacheKey: cacheKey)
        } else {
            hitView = nil
        }
        if let hitView {
            result = helper.containsGlobalPoints(
                points,
                cacheKey: cacheKey,
                options: options,
                children: children
            )
            if !result.children.isEmpty {
                if let hitTestingHostView, !hitView.isDescendant(of: hitTestingHostView) {
                    result.children = []
                }
            }
        }
        if !result.mask.isEmpty, !options.contains(.useZDistanceAsPriority) {
            result.priority = Self.gestureContainmentPriority
        }
        if let cacheKey {
            lastResult = PlatformHitTestResult(
                key: cacheKey,
                globalPoint: globalPoint,
                hitView: hitView
            )
        }
        return result
    }

    override func addContentPath(
        to path: inout Path,
        kind: ContentShapeKinds,
        in space: CoordinateSpace,
        observer: (any ContentPathObserver)?
    ) {
        super.addContentPath(to: &path, kind: kind, in: space, observer: observer)
        helper.addContentPath(to: &path, kind: kind, in: space, observer: observer)
    }

    override var descriptionName: String {
        guard let representedView else {
            return super.descriptionName
        }
        return "\(recursiveDescriptionName(Self.self))<\(_typeName(type(of: representedView), qualified: false))>"
    }

    override func extendPrintTree(string: inout String) {
        let position = helper.globalPosition
        string += "[\(helper.size.width), \(helper.size.height)] @\((position.x, position.y))"
    }
}
#endif
