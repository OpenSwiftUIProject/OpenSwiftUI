//
//  ContentShapeModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: DEE7A9A341D7A5DA4357011E578980C2 (SwiftUI)

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - _ContentShapeModifier

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _ContentShapeModifier<ContentShape>: ViewModifier, MultiViewModifier, PrimitiveViewModifier where ContentShape: Shape {
    public var shape: ContentShape
    public var eoFill: Bool

    @inlinable
    public init(shape: ContentShape, eoFill: Bool = false) {
        self.shape = shape
        self.eoFill = eoFill
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        if inputs.preferences.contains(ViewRespondersKey.self) {
            let filter = ContentShapeResponderFilter(
                modifier: modifier.value,
                position: inputs.animatedPosition(),
                size: inputs.animatedSize(),
                transform: inputs.transform,
                children: outputs.viewResponders(),
                inputs: inputs,
                viewSubgraph: Subgraph.current!
            )
            outputs[ViewRespondersKey.self] = Attribute(filter)
            if inputs.preferences.requiresAccessibilityNodes {
                outputs.accessibilityNodes = makeAccessibilityGeometryTransform(
                    for: nil,
                    kind: nil,
                    inputs: inputs,
                    outputs: outputs
                )
            }
        }
        return outputs
    }
}

@available(*, unavailable)
extension _ContentShapeModifier: Sendable {}

// MARK: - View + contentShape

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Sets the shape used to test whether a point is inside this view.
    ///
    /// - Parameters:
    ///   - shape: The shape to use for hit testing.
    ///   - eoFill: Whether to use the even-odd fill rule.
    @inlinable
    nonisolated public func contentShape<S>(_ shape: S, eoFill: Bool = false) -> some View where S: Shape {
        modifier(_ContentShapeModifier(shape: shape, eoFill: eoFill))
    }
}

// MARK: - _ContentShapeModifier + ContentResponder

extension _ContentShapeModifier: ContentResponder {
    package func contains(points: UnsafeBufferPointer<PlatformPoint>, size: CGSize) -> BitVector64 {
        shape.effectivePath(in: CGRect(origin: .zero, size: size))
            .contains(points: points, eoFill: eoFill)
    }

    package func contentPath(size: CGSize) -> Path {
        shape.effectivePath(in: CGRect(origin: .zero, size: size))
    }
}

// MARK: - ContentShapeResponder

private class ContentShapeResponder<ContentShape>: DefaultLayoutViewResponder where ContentShape: Shape {
    var helper = ContentResponderHelper<_ContentShapeModifier<ContentShape>>()

    override func containsGlobalPoints(
        _ points: [PlatformPoint],
        cacheKey: UInt32?,
        options: ContainsPointsOptions
    ) -> ContainsPointsResult {
        let priority = isLinkedOnOrAfter(.v6)
            ? super.containsGlobalPoints(points, cacheKey: cacheKey, options: options).priority
            : -1
        var result = helper.containsGlobalPoints(
            points,
            cacheKey: cacheKey,
            options: options,
            children: children
        )
        result.priority.formMax(priority)
        return result
    }

    override func addContentPath(
        to path: inout Path,
        kind: ContentShapeKinds,
        in space: CoordinateSpace,
        observer: (any ContentPathObserver)?
    ) {
        helper.addContentPath(to: &path, kind: kind, in: space, observer: observer)
    }

    override var descriptionName: String {
        let size = helper.size
        return "ContentShapeResponder<\(ContentShape.self)> (\(size.width), \(size.height))\""
    }

    override func extendPrintTree(string: inout String) {
        let position = helper.globalPosition
        string += "[\(helper.size.width), \(helper.size.height)] @\((position.x, position.y))"
    }
}

// MARK: - ContentShapeResponderFilter

private struct ContentShapeResponderFilter<ContentShape>: StatefulRule where ContentShape: Shape {
    @Attribute var modifier: _ContentShapeModifier<ContentShape>
    @Attribute var position: CGPoint
    @Attribute var size: ViewSize
    @Attribute var transform: ViewTransform
    @Attribute var children: [ViewResponder]
    var inputs: _ViewInputs
    var viewSubgraph: Subgraph
    lazy var responder: ContentShapeResponder<ContentShape> = {
        viewSubgraph.apply {
            ContentShapeResponder(inputs: inputs)
        }
    }()

    typealias Value = [ViewResponder]

    mutating func updateValue() {
        responder.helper.update(
            data: $modifier.changedValue(),
            size: $size.changedValue(),
            position: $position.changedValue(),
            transform: $transform.changedValue(),
            parent: responder
        )
        responder.updateChildren($children.changedValue())
        if !hasValue {
            value = [responder]
        }
    }
}
