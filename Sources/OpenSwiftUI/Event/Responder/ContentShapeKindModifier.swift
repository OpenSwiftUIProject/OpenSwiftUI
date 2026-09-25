//
//  ContentShapeKindModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 14064F4AE362A5AD4C34ADD19A80790A (SwiftUI)

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - View + contentShape

@available(OpenSwiftUI_v3_0, *)
extension View {
    /// Sets the content shape for the specified kinds of interactions.
    ///
    /// - Parameters:
    ///   - kind: The interactions that use this shape.
    ///   - shape: The shape to use for those interactions.
    ///   - eoFill: Whether to use the even-odd fill rule.
    @inlinable
    nonisolated public func contentShape<S>(
        _ kind: ContentShapeKinds,
        _ shape: S,
        eoFill: Bool = false
    ) -> some View where S: Shape {
        modifier(
            _ContentShapeKindModifier(
                shape: shape,
                eoFill: eoFill,
                kind: kind
            )
        )
    }
}

// MARK: - _ContentShapeKindModifier

/// A modifier that defines the content shape for a view.
@available(OpenSwiftUI_v3_0, *)
@frozen
public struct _ContentShapeKindModifier<ContentShape>: ViewModifier, MultiViewModifier, PrimitiveViewModifier where ContentShape: Shape {
    /// The content shape.
    public var shape: ContentShape

    /// If true, the shape is interpreted using the even-odd winding
    /// number rule, otherwise using the non-zero winding number rule.
    public var eoFill: Bool

    /// The kind assigned for the given shape.
    public var kind: ContentShapeKinds

    @inlinable
    public init(shape: ContentShape, eoFill: Bool = false, kind: ContentShapeKinds) {
        self.shape = shape
        self.eoFill = eoFill
        self.kind = kind
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        if inputs.preferences.requiresViewResponders {
            outputs[ViewRespondersKey.self] = Attribute(ContentShapeKindResponderFilter(
                modifier: modifier.value,
                position: inputs.animatedPosition(),
                size: inputs.animatedSize(),
                transform: inputs.transform,
                children: outputs.viewResponders(),
                responder: ContentShapeKindResponder(inputs: inputs)
            ))
            if inputs.preferences.requiresAccessibilityNodes {
                outputs.accessibilityNodes = makeAccessibilityGeometryTransform(
                    for: nil,
                    kind: modifier[offset: { .of(&$0.kind) }].value,
                    inputs: inputs,
                    outputs: outputs
                )
            }
        }
        return outputs
    }
}

@available(*, unavailable)
extension _ContentShapeKindModifier: Sendable {}

extension _ContentShapeKindModifier: ContentResponder {
    package func contains(points: UnsafeBufferPointer<PlatformPoint>, size: CGSize) -> BitVector64 {
        shape.effectivePath(in: CGRect(origin: .zero, size: size))
            .contains(points: points, eoFill: eoFill)
    }

    package func contentPath(size: CGSize) -> Path {
        kind.contains(.interaction)
            ? shape.effectivePath(in: CGRect(origin: .zero, size: size))
            : Path()
    }

    package func contentPath(size: CGSize, kind: ContentShapeKinds) -> Path {
        !kind.intersection(self.kind).isEmpty
            ? shape.effectivePath(in: CGRect(origin: .zero, size: size))
            : Path()
    }
}

// MARK: - ContentShapeKindResponder

private class ContentShapeKindResponder<ContentShape>: DefaultLayoutViewResponder where ContentShape: Shape {
    var kind: ContentShapeKinds = .interaction
    var helper = ContentResponderHelper<_ContentShapeKindModifier<ContentShape>>()

    override func containsGlobalPoints(
        _ points: [PlatformPoint],
        cacheKey: UInt32?,
        options: ContainsPointsOptions
    ) -> ContainsPointsResult {
        guard kind.contains(.interaction) else {
            return super.containsGlobalPoints(points, cacheKey: cacheKey, options: options)
        }
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
        var remaining = kind
        if !self.kind.intersection(kind).isEmpty {
            helper.addContentPath(
                to: &path,
                kind: self.kind.intersection(kind),
                in: space,
                observer: observer
            )
            remaining.remove(self.kind)
        }
        if remaining != [] {
            super.addContentPath(to: &path, kind: remaining, in: space, observer: observer)
        }
    }

    override var descriptionName: String {
        let size = helper.size
        return "ContentShapeKindResponder<\(ContentShape.self)>\(kind.description) (\(size.width), \(size.height))\""
    }

    override func extendPrintTree(string: inout String) {
        let position = helper.globalPosition
        string += "[\(helper.size.width), \(helper.size.height)] @\((position.x, position.y))"
    }
}

// MARK: - ContentShapeKindResponderFilter

private struct ContentShapeKindResponderFilter<ContentShape>: StatefulRule where ContentShape: Shape {
    @Attribute var modifier: _ContentShapeKindModifier<ContentShape>
    @Attribute var position: CGPoint
    @Attribute var size: ViewSize
    @Attribute var transform: ViewTransform
    @Attribute var children: [ViewResponder]
    let responder: ContentShapeKindResponder<ContentShape>

    typealias Value = [ViewResponder]

    func updateValue() {
        responder.helper.update(
            data: $modifier.changedValue(),
            size: $size.changedValue(),
            position: $position.changedValue(),
            transform: $transform.changedValue(),
            parent: responder
        )
        responder.kind = modifier.kind
        responder.updateChildren($children.changedValue())
        if !hasValue {
            value = [responder]
        }
    }
}
