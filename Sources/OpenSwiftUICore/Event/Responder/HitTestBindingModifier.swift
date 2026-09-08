//
//  HitTestBindingModifier.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: D16C83991EAE21A87411739F6DC01498 (SwiftUICore)

package import Foundation
import OpenAttributeGraphShims

// MARK: - PlatformHitTestableEvent

package typealias PlatformHitTestableEvent = HitTestableEvent

// MARK: - HitTestBindingModifier

package struct HitTestBindingModifier: ViewModifier, MultiViewModifier, PrimitiveViewModifier {
    nonisolated package static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        if inputs.preferences.requiresViewResponders {
            let filter = HitTestBindingFilter(
                children: outputs.viewResponders(),
                responder: HitTestBindingResponder(inputs: inputs)
            )
            outputs.preferences.viewResponders = Attribute(filter)
        }
        return outputs
    }
}

// MARK: - HitTestBindingResponder

private class HitTestBindingResponder: DefaultLayoutViewResponder {
    override func bindEvent(_ event: any EventType) -> ResponderNode? {
        guard let event = PlatformHitTestableEvent(event),
              let responder = hitTest(
                globalPoint: event.hitTestLocation,
                radius: event.hitTestRadius
              ) else {
            return super.bindEvent(event)
        }
        return responder
    }
}

// MARK: - HitTestBindingFilter

private struct HitTestBindingFilter: StatefulRule {
    @Attribute var children: [ViewResponder]
    let responder: HitTestBindingResponder

    typealias Value = [ViewResponder]

    mutating func updateValue() {
        let (children, changed) = $children.changedValue()
        if changed {
            responder.children = children
        }
        if !hasValue {
            value = [responder]
        }
    }
}

// MARK: - ViewResponder + Hit Testing

extension ViewResponder {
    /// The shared counter for hit-testing cache keys.
    package private(set) static var hitTestKey: UInt32 = 0

    /// Advances the shared hit-testing cache key.
    ///
    /// - Returns: The updated cache key.
    package static func nextHitTestKey() -> UInt32 {
        hitTestKey.unsafeIncrement()
        return hitTestKey
    }

    /// The minimum opacity required to participate in hit testing.
    package static let minOpacityForHitTest: Double = 0.001

    /// Selects a hit-testing target near a global point.
    ///
    /// - Parameters:
    ///   - globalPoint: The point to test, in global coordinates.
    ///   - radius: The sampling radius around `globalPoint`.
    ///   - cacheKey: An optional key for reusing containment results.
    ///   - options: Options that control hit testing.
    /// - Returns: The selected responder, or `nil` if no target is found.
    package func hitTest(
        globalPoint: PlatformPoint,
        radius: CGFloat,
        cacheKey: UInt32? = nil,
        options: ContainsPointsOptions = .platformDefault
    ) -> ViewResponder? {
        let cacheKey = options.contains(.uncached) ? nil : (cacheKey ?? Self.nextHitTestKey())
        if options.contains(.disablePointCloudHitTesting) {
            return singlePointHitTest(
                globalPoint: globalPoint,
                cacheKey: cacheKey,
                options: options
            )?.0
        } else {
            let (points, weights) = hitPoints(point: globalPoint, radius: radius)
            return hitTest(
                globalPoints: points,
                weights: weights,
                mask: [],
                cacheKey: cacheKey,
                options: options
            )?.0
        }
    }

    /// Selects a hit-testing target at a single global point.
    ///
    /// - Parameters:
    ///   - globalPoint: The point to test, in global coordinates.
    ///   - cacheKey: An optional key for reusing containment results.
    ///   - options: Options for containment testing.
    /// - Returns: The selected responder and its hit priority, or `nil` if
    ///   no target is found.
    private func singlePointHitTest(
        globalPoint: PlatformPoint,
        cacheKey: UInt32?,
        options: ContainsPointsOptions
    ) -> (ViewResponder, Double)? {
        guard opacity >= Self.minOpacityForHitTest else {
            return nil
        }
        let result = containsGlobalPoints([globalPoint], cacheKey: cacheKey, options: options)
        guard result.mask[0] else {
            return nil
        }
        var currentHit: ViewResponder? = nil
        var currentPriority: Double = 0.0
        for child in result.children.reversed() where child.allowsHitTesting {
            guard let candidate = child.singlePointHitTest(
                globalPoint: globalPoint,
                cacheKey: cacheKey,
                options: options
            ), currentPriority < candidate.1 else {
                continue
            }
            currentPriority = currentHit === candidate.0 ? currentPriority : candidate.1
            currentHit = currentHit === candidate.0 ? currentHit : candidate.0
        }
        if let currentHit, currentPriority > 0.0 {
            return (currentHit, currentPriority)
        }
        return allowsHitTesting ? (self, result.priority) : nil
    }

    /// Selects a hit-testing target using weighted sample points.
    ///
    /// The returned score and coverage belong to this responder, even when
    /// a descendant is selected.
    ///
    /// - Parameters:
    ///   - globalPoints: The sample points to test, in global coordinates.
    ///   - weights: The sample weights, in the same order as `globalPoints`.
    ///   - mask: A mask of sample points excluded from this subtree.
    ///   - cacheKey: An optional key for reusing containment results.
    ///   - options: Options for containment testing.
    /// - Returns: The selected responder, score, and coverage mask, or `nil`
    ///   if no target is found.
    private func hitTest(
        globalPoints: [PlatformPoint],
        weights: [Double],
        mask: BitVector64,
        cacheKey: UInt32?,
        options: ContainsPointsOptions
    ) -> (ViewResponder, Double, BitVector64)? {
        let opacity = opacity
        guard opacity >= Self.minOpacityForHitTest else {
            return nil
        }
        let result = containsGlobalPoints(globalPoints, cacheKey: cacheKey, options: options)
        var childMask = mask
        var coveredMask = mask
        var weight = 0.0
        for index in globalPoints.indices {
            if !mask[index], result.mask[index] {
                weight += weights[index]
                coveredMask[index] = opacity > 0.5
            } else {
                childMask[index] = true
            }
        }
        let priority = result.priority * (opacity * weight)
        guard priority != 0 else {
            return nil
        }
        var currentHit: ViewResponder? = nil
        var nextPriority: Double = 0.0
        var currentPriority: Double = 0.0
        for child in result.children.reversed() where child.allowsHitTesting {
            guard let candidate = child.hitTest(
                globalPoints: globalPoints,
                weights: weights,
                mask: childMask,
                cacheKey: cacheKey,
                options: options
            ) else {
                continue
            }
            childMask = candidate.2
            guard nextPriority < candidate.1 else {
                continue
            }
            if currentPriority >= candidate.1 {
                nextPriority = candidate.1
            } else {
                nextPriority = candidate.0 === currentHit ? nextPriority : currentPriority
                currentPriority = candidate.1
                currentHit = candidate.0
            }
        }
        if let currentHit, currentPriority >= max(nextPriority * 1.2, 8) {
            return (currentHit, priority, coveredMask)
        }
        return allowsHitTesting ? (self, priority, coveredMask) : nil
    }
}

// MARK: - hitPoints

/// Generates weighted sample points for hit testing near a global point.
///
/// - Parameters:
///   - point: The center of the sample cloud, in global coordinates.
///   - radius: The sampling radius around `point`.
/// - Returns: The sample points and their corresponding weights.
private func hitPoints(point: PlatformPoint, radius: CGFloat) -> ([PlatformPoint], [Double]) {
    let radius = min(max(abs(radius), 1), 60)
    let spacing = max(radius / 6.0, 4.0)
    let ringCount = min(Int(ceil(radius / spacing)), 6)
    var points = [point]
    var weights = [24.0]
    var distance = spacing
    for ring in 1 ..< ringCount {
        let count = ring * 4
        let weight = 24.0 / Double(count)
        let angle = 2 * Double.pi / Double(count)
        let sine = sin(angle)
        let cosine = cos(angle)
        var direction = CGPoint(x: 1, y: 0)
        for _ in 0..<count {
            points.append(CGPoint(
                x: point.x + direction.x * distance,
                y: point.y + direction.y * distance
            ))
            weights.append(weight)
            direction = CGPoint(
                x: direction.x * cosine - direction.y * sine,
                y: direction.y * cosine + direction.x * sine
            )
        }
        distance += spacing
    }
    return (points, weights)
}
